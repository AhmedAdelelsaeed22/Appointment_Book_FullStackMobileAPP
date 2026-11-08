using AppointmentBook.Data.Data;
using AppointmentBook.Data.Helper;
using AppointmentBook.Data.Interfaces;
using AppointmentBook.Data.Repositories;
using AppointmentBook.Data.Services;
using AppointmentBookAPI.Authorization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Resend;
using System.Text;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);


// ===============================
// JWT Authentication Configuration
// ===============================


// Register authentication services in the dependency injection container.
// JwtBearerDefaults.AuthenticationScheme tells ASP.NET Core that
// JWT Bearer authentication will be the default authentication method.
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        // TokenValidationParameters define how incoming JWTs will be validated.
        options.TokenValidationParameters = new TokenValidationParameters
        {
            // Ensures the token was issued by a trusted issuer.
            ValidateIssuer = true,


            // Ensures the token is intended for this API (audience check).
            ValidateAudience = true,


            // Ensures the token has not expired.
            ValidateLifetime = true,


            // Ensures the token signature is valid and was signed by the API.
            ValidateIssuerSigningKey = true,


            // The expected issuer value (must match the issuer used when creating the JWT).
            ValidIssuer = builder.Configuration["Jwt:Issuer"],


            // The expected audience value (must match the audience used when creating the JWT).
            ValidAudience = builder.Configuration["Jwt:Audience"],


            // The secret key used to validate the JWT signature.
            // This must be the same key used when generating the token.
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(Environment.GetEnvironmentVariable(
        "JWT_SECRET")!))
        };
    });


// ==========================================
// EmailService Configuration
// ==========================================

builder.Services.AddOptions();

builder.Services.AddHttpClient<ResendClient>();

builder.Services.Configure<ResendClientOptions>(options =>
{
    options.ApiToken =
        builder.Configuration["EmailSettings:ApiKey"]!;
});

builder.Services.Configure<EmailSettings>(
    builder.Configuration.GetSection("EmailSettings"));

builder.Services.AddTransient<IResend, ResendClient>();


// ==========================================
// DATABASE
// ==========================================

builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    options.UseNpgsql(
        builder.Configuration.GetConnectionString(
            "DefaultConnection"));
});


// ==========================================
// AUTOMAPPER
// ==========================================

// Scan the assembly and find all AutoMapper Profiles
builder.Services.AddAutoMapper(
    _ => { },
    typeof(MappingProfiles).Assembly);


// ==========================================
// DATA LAYER SERVICES
// ==========================================

builder.Services.AddScoped<IUserService, UsersData>();

builder.Services.AddScoped<IRefreshTokenService, RefreshTokensData>();

builder.Services.AddScoped<IAuditLogsService, AuditLogsData>();

builder.Services.AddScoped<IEmailService, EmailService>();

builder.Services.AddScoped<IEmailVerificationOtp, EmailVerificationOtpData>();

builder.Services.AddScoped<IBusinessService, BusinessData>();

builder.Services.AddScoped<IFavoriteBusinessService, FavoriteBusinessData>();

builder.Services.AddScoped<ICategoriesService, CategoriesData>();

builder.Services.AddScoped<IAppointmentStatusService, AppointmentStatusData>();

builder.Services.AddScoped<IServiceService, ServiceData>();

builder.Services.AddScoped<IStaffService, StaffData>();

builder.Services.AddScoped<IAvailableTimeService, AvailableTimeData>();

builder.Services.AddScoped<IAppointmentService, AppointmentData>();

// ==========================================
// CONTROLLERS
// ==========================================

builder.Services.AddControllers();


// ==========================================
// SWAGGER
// ==========================================

builder.Services.AddEndpointsApiExplorer();

// Register Swagger generator and customize its behavior.
builder.Services.AddSwaggerGen(options =>
{
    // ===============================
    // 1) Define the JWT Bearer security scheme
    // ===============================
    //
    // This tells Swagger that our API uses JWT Bearer authentication
    // through the HTTP Authorization header.
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        // The name of the HTTP header where the token will be sent.
        Name = "Authorization",


        // Indicates this is an HTTP authentication scheme.
        Type = SecuritySchemeType.Http,


        // Specifies the authentication scheme name.
        // Must be exactly "Bearer" for JWT Bearer tokens.
        Scheme = "Bearer",


        // Optional metadata to describe the token format.
        BearerFormat = "JWT",


        // Specifies that the token is sent in the request header.
        In = ParameterLocation.Header,


        // Text shown in Swagger UI to guide the user.
        Description = "Enter: Bearer {your JWT token}"
    });


    // ===============================
    // 2) Require the Bearer scheme for secured endpoints
    // ===============================
    //
    // This tells Swagger that endpoints protected by [Authorize]
    // require the Bearer token defined above.
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                // Reference the previously defined "Bearer" security scheme.
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },


            // No scopes are required for JWT Bearer authentication.
            // This array is empty because JWT does not use OAuth scopes here.
            new string[] {}
        }
    });
});


builder.Services.AddSingleton<IAuthorizationHandler, UserOwnerOrAdminHandler>();

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("UserOwnerOrAdmin", policy =>
        policy.Requirements.Add(new UserOwnerOrAdminRequirement()));
});



builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

    options.AddPolicy("AuthLimiter", httpContext =>
    {
        var ip = httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

        return RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: ip,
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 20,
                Window = TimeSpan.FromMinutes(5),
                QueueLimit = 0
            });
    });
});




builder.Services.AddCors(options =>
{
    options.AddPolicy("AppointmentBookApiCorsPolicy", policy =>
    {
        policy
            .WithOrigins(
                "https://localhost:7008",
                "http://localhost:5246"
            )
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});



var app = builder.Build();

app.Use(async (context, next) =>
{
    await next();

    if (context.Response.StatusCode == StatusCodes.Status429TooManyRequests)
    {
        await context.Response.WriteAsync(
            "Too many login attempts. Please try again later.");
    }
});



// ==========================================
// HTTP PIPELINE
// ==========================================

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseRateLimiter();

app.UseCors("AppointmentBookApiCorsPolicy");

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();
