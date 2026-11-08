using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Dto.Auth;
using AppointmentBook.Data.Helper;
using AppointmentBook.Data.Interfaces;
using AppointmentBook.Logic;
using AppointmentBookAPI.Helper;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace AppointmentBookAPI.Controllers
{

    // This controller is responsible for authentication-related actions,
    // such as logging in and issuing JWT tokens.
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {

        private readonly IEmailVerificationOtp _emailVerificationOtpService;

        private readonly IAuditLogsService _auditLogger;

        private readonly IUserService _usersData;

        private readonly IRefreshTokenService _refreshTokensData;

        private readonly IConfiguration _configuration;

        private readonly IEmailService _emailService;

        public AuthController(IUserService usersData, IRefreshTokenService refreshTokensData, IConfiguration configuration, IAuditLogsService auditLogger, IEmailService emailService, IEmailVerificationOtp emailVerificationOtpService)
        {
            _usersData = usersData;
            _refreshTokensData = refreshTokensData;
            _configuration = configuration;
            _auditLogger = auditLogger;
            _emailService = emailService;
            _emailVerificationOtpService = emailVerificationOtpService;

        }



        [HttpPost("SignUp")]
        [EnableRateLimiting("AuthLimiter")]
        public async Task<IActionResult> SignUp([FromBody] SignUpRequest request)
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var User = new UsersLogic
            (
                new UserDTO(
                  0,
                  request.first_name,
                  request.last_name,
                  request.email,
                  request.phone,
                  request.password,
                  request.profile_image_url,
                  true,
                  DateTime.UtcNow,
                  "Customer"
                  )
            );




            bool result = User.SaveAsync(_usersData).Result;


            if (!result)
            {
                await Utilities.SaveLogs(null, "sign up is Failed.", "Information", request.email, ip, _auditLogger);
                return BadRequest("Failed to sign up.");
            }

            await Utilities.SaveLogs(null, "sign up successfully.", "Information", request.email, ip, _auditLogger);

            return Ok(new
            {
                message = "Sign up successfully."
            });
        }



        [HttpPost("ChangePassword")]
        [EnableRateLimiting("AuthLimiter")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            var userId = await UsersLogic.GetUserIdByEmailAsync(request.email, _usersData);
            if (userId == null)
            {
                return NotFound("User not found please create account first.");
            }


            bool result = await UsersLogic.ChangePasswordAsync(userId.Value, request.NewPassword, _usersData);

            if (!result)
            {
                return BadRequest("Failed to change password.");
            }

            await Utilities.SaveLogs(userId.Value, "Password changed successfully.", "Information", request.email, ip, _auditLogger);

            return Ok(new
            {
                message = "Password changed successfully."
            });
        }




        [HttpPost("OTPVerification")]
        [EnableRateLimiting("AuthLimiter")]
        public async Task<IActionResult> OTPVerification([FromBody] OTPVerifyRequest request)
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            var userId = await UsersLogic.GetUserIdByEmailAsync(request.email, _usersData);
            if (userId == null)
            {
                return NotFound("User not found please create account first.");
            }


            bool isVerified = await EmailVerificationOtpLogic.OTPVerification(_emailVerificationOtpService, userId.Value, request.OTP);

            if (!isVerified)
            {
                await Utilities.SaveLogs(userId.Value, "Failed OTP verification attempt.", "Warning", _configuration["EmailSettings:MyEmail"]!, ip, _auditLogger);
                return Unauthorized("Invalid OTP");
            }

            await Utilities.SaveLogs(userId.Value, "OTP verification is successfully.", "Information", _configuration["EmailSettings:MyEmail"]!, ip, _auditLogger);

            return Ok(new
            {
                message = "OTP verification is successfully."
            });
        }



        [HttpPost("SendOTP")]
        [EnableRateLimiting("AuthLimiter")]
        public async Task<IActionResult> SendOTPToEmail([FromBody] SendOTPRequest request)
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            var userId = await UsersLogic.GetUserIdByEmailAsync(request.email, _usersData);
            if (userId == null)
            {
                return NotFound("User not found please create account first.");
            }

            string otp = Utilities.GenerateOtp();

            EmailVerificationOtpDTO emailVerificationOtpDTO = new EmailVerificationOtpDTO
            (
                0,
                userId.Value,
                otp,
                DateTime.UtcNow.AddMinutes(1),
                0,
                false,
                DateTime.UtcNow
            );

            EmailVerificationOtpLogic emailVerificationOtpLogic = new EmailVerificationOtpLogic(emailVerificationOtpDTO);
            await emailVerificationOtpLogic.SaveAsync(_emailVerificationOtpService);

            string body = $"""
                        Hello,

                        Thank you for login to AppointmentBook App.

                        Your email verification code is:

                        {otp}

                        This code will expire in 5 minutes.

                        For your security, please do not share this code with anyone.

                        If you did not request this code, you can safely ignore this email.

                        Best regards,
                        AppointmentBook Team
                        """;

            await _emailService.SendEmailAsync(
                _configuration["EmailSettings:MyEmail"]!,
                _configuration["EmailSettings:FromName"]!,
                body);


            await Utilities.SaveLogs(null, "Send OTP successfully.", "Information", request.email, ip, _auditLogger);

            return Ok(new
            {
                message = "Email sent successfully."
            });
        }



        [HttpPost("LoginUsingGoogle")]
        [EnableRateLimiting("AuthLimiter")]
        public async Task<IActionResult> LoginUsingGoogle([FromBody] LoginWithGoogleRequest request)
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var payload = await GoogleJsonWebSignature.ValidateAsync(
           request.IdToken
       );

            var user = await UsersLogic.FindByEmailAsync(_usersData, payload.Email);



            if (user == null)
            {
                await Utilities.SaveLogs(null, "Failed login with Google attempt (not found email).", "Warning", payload.Email, ip, _auditLogger);

                return Unauthorized("Invalid Login With Google");
            }


            // Step 3: Create claims that represent the authenticated user's identity.
            // These claims will be embedded inside the JWT.
            var claims = new[]
            {
                // Unique identifier for the student
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),


                // Student email address
                new Claim(ClaimTypes.Email, user.Email),


                // Role (Student or Admin) used later for authorization
                new Claim(ClaimTypes.Role, user.UserRole)
            };


            // Step 4: Create the symmetric security key used to sign the JWT.
            // This key must match the key used in JWT validation middleware.
            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(Environment.GetEnvironmentVariable(
        "JWT_SECRET")!));


            // Step 5: Define the signing credentials.
            // This specifies the algorithm used to sign the token.
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);


            // Step 6: Create the JWT token.
            // The token includes issuer, audience, claims, expiration, and signature.
            var token = new JwtSecurityToken(
                issuer: _configuration["JWT:Issuer"],
                audience: _configuration["JWT:Audience"],
                claims: claims,
                expires: DateTime.Now.AddMinutes(30),
                signingCredentials: creds
            );


            var accessToken = new JwtSecurityTokenHandler().WriteToken(token);

            // Create refresh token (random)
            var refreshToken = Utilities.GenerateRefreshToken();

            // Store refresh token securely (hash + expiry + not revoked)

            RefreshTokensDTO refreshTokensDTO = new RefreshTokensDTO
            (
                0,
                user.Id,
                BCrypt.Net.BCrypt.HashPassword(refreshToken),
                DateTime.UtcNow.AddDays(7),
                null
            );

            RefreshTokensLogic refreshTokensLogic = new RefreshTokensLogic
            (refreshTokensDTO);

            await refreshTokensLogic.Save(_refreshTokensData);


            await Utilities.SaveLogs(Convert.ToInt64(user.Id), "Successful login with Google.", "Information", payload.Email, ip, _auditLogger);


            return Ok(new TokenResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken
            });
        }




        // This endpoint handles user login.
        // It verifies credentials and returns a JWT token if login succeeds.
        [HttpPost("login")]
        [EnableRateLimiting("AuthLimiter")]
        public async Task<IActionResult> Login(AppointmentBook.Data.Dto.Auth.LoginRequest request)
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            var user = await UsersLogic.FindByEmailAsync(_usersData, request.Email);



            if (user == null)
            {
                await Utilities.SaveLogs(null, "Failed login attempt (not found email).", "Warning", request.Email, ip, _auditLogger);

                return Unauthorized("Invalid credentials");
            }




            // Step 2: Verify the provided password against the stored hash.
            // BCrypt handles hashing and salt internally.
            bool isValidPassword =
                Hasher.VerifyPassword(request.Password, user.PasswordHash);




            // If the password does not match the stored hash,
            // return 401 Unauthorized.
            if (!isValidPassword)
            {
                await Utilities.SaveLogs(user.Id, "Failed login attempt (not correct password).", "Warning", request.Email, ip, _auditLogger);
                return Unauthorized("Invalid credentials");
            }



            // Step 3: Create claims that represent the authenticated user's identity.
            // These claims will be embedded inside the JWT.
            var claims = new[]
            {
                // Unique identifier for the student
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),


                // Student email address
                new Claim(ClaimTypes.Email, user.Email),


                // Role (Student or Admin) used later for authorization
                new Claim(ClaimTypes.Role, user.UserRole)
            };


            // Step 4: Create the symmetric security key used to sign the JWT.
            // This key must match the key used in JWT validation middleware.
            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(Environment.GetEnvironmentVariable(
        "JWT_SECRET")!));


            // Step 5: Define the signing credentials.
            // This specifies the algorithm used to sign the token.
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);


            // Step 6: Create the JWT token.
            // The token includes issuer, audience, claims, expiration, and signature.
            var token = new JwtSecurityToken(
                issuer: _configuration["JWT:Issuer"],
                audience: _configuration["JWT:Audience"],
                claims: claims,
                expires: DateTime.Now.AddMinutes(30),
                signingCredentials: creds
            );


            var accessToken = new JwtSecurityTokenHandler().WriteToken(token);

            // Create refresh token (random)
            var refreshToken = Utilities.GenerateRefreshToken();

            // Store refresh token securely (hash + expiry + not revoked)

            RefreshTokensDTO refreshTokensDTO = new RefreshTokensDTO
            (
                0,
                user.Id,
                BCrypt.Net.BCrypt.HashPassword(refreshToken),
                DateTime.UtcNow.AddDays(7),
                null
            );

            RefreshTokensLogic refreshTokensLogic = new RefreshTokensLogic
            (refreshTokensDTO);

            await refreshTokensLogic.Save(_refreshTokensData);


            await Utilities.SaveLogs(Convert.ToInt64(user.Id), "Successful login.", "Information", request.Email, ip, _auditLogger);


            return Ok(new TokenResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken
            });
        }


        [HttpPost("refresh")]
        [EnableRateLimiting("AuthLimiter")]
        public async Task<IActionResult> Refresh([FromBody] RefreshRequest request)
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            var user = await UsersLogic.FindByEmailAsync(_usersData, request.Email);



            if (user == null)
            {

                await Utilities.SaveLogs(null, "Refresh attempt using revoked token", "Warning", request.Email, ip, _auditLogger);

                return Unauthorized("Invalid refresh request");
            }


            var RefreshToken = await RefreshTokensLogic.FindAsync(_refreshTokensData, user.Id);


            if (RefreshToken!.revoked_at != null)
            {
                await Utilities.SaveLogs(Convert.ToInt64(user.Id), "Refresh attempt using revoked token", "Warning", request.Email, ip, _auditLogger);

                return Unauthorized("Refresh token is revoked");
            }

            if (RefreshToken!.expires_at == null || RefreshToken!.expires_at <= DateTime.UtcNow)
            {
                await Utilities.SaveLogs(null, "Refresh attempt using revoked token", "Warning", request.Email, ip, _auditLogger);
                return Unauthorized("Refresh token expired");
            }

            bool refreshValid = BCrypt.Net.BCrypt.Verify(request.RefreshToken, RefreshToken!.token_hash);
            if (!refreshValid)
            {
                await Utilities.SaveLogs(Convert.ToInt64(user.Id), "Refresh attempt using revoked token", "Warning", request.Email, ip, _auditLogger);

                return Unauthorized("Invalid refresh token");
            }

            // Issue NEW access token (same claims & signing settings as login)
            var claims = new[]
            {
        new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
        new Claim(ClaimTypes.Email, user.Email),
        new Claim(ClaimTypes.Role, user.UserRole)
    };

            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(Environment.GetEnvironmentVariable(
        "JWT_SECRET")!));

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var jwt = new JwtSecurityToken(
                issuer: _configuration["JWT:Issuer"],
                audience: _configuration["JWT:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(30),
                signingCredentials: creds
            );

            var newAccessToken = new JwtSecurityTokenHandler().WriteToken(jwt);

            // Rotation: replace refresh token
            var newRefreshToken = Utilities.GenerateRefreshToken();

            RefreshToken.token_hash = BCrypt.Net.BCrypt.HashPassword(newRefreshToken);
            RefreshToken.expires_at = DateTime.UtcNow.AddDays(7);
            RefreshToken.revoked_at = null;

            await RefreshToken.Save(_refreshTokensData);

            await Utilities.SaveLogs(Convert.ToInt64(user.Id), "Refresh succeeded.", "Information", request.Email, ip, _auditLogger);

            return Ok(new TokenResponse
            {
                AccessToken = newAccessToken,
                RefreshToken = newRefreshToken
            });
        }



        [HttpPost("logout")]
        [EnableRateLimiting("AuthLimiter")]
        public async Task<IActionResult> Logout([FromBody] LogoutRequest request)
        {
            var user = await UsersLogic.FindByEmailAsync(_usersData, request.Email);

            if (user == null)
                return Ok(); // Do not reveal if user exists

            var RefreshToken = await RefreshTokensLogic.FindAsync(_refreshTokensData, user.Id);

            bool refreshValid = BCrypt.Net.BCrypt.Verify(request.RefreshToken, RefreshToken!.token_hash);
            if (!refreshValid)
                return Ok();

            RefreshToken.revoked_at = DateTime.UtcNow;
            await RefreshToken.Save(_refreshTokensData);
            return Ok("Logged out successfully");
        }


    }
}
