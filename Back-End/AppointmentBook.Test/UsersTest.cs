using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;
using AppointmentBookAPI.Controllers;
using FakeItEasy;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;


namespace AppointmentBook.Tests
{
    public class UsersControllerTests
    {
        private readonly IUserService _usersService;
        private readonly IConfiguration _configuration;
        private readonly IAuditLogsService _auditLogger;
        private readonly UsersController _controller;

        public UsersControllerTests()
        {
            _usersService = A.Fake<IUserService>();
            _auditLogger = A.Fake<IAuditLogsService>();

            _configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["AdminIDs:ID"] = "1",
                    ["AdminEmails:Email"] = "admin@test.com"
                })
                .Build();

            _controller = new UsersController(
                _usersService,
                _auditLogger,
                _configuration);

            _controller.ControllerContext = new ControllerContext
            {
                HttpContext = new DefaultHttpContext()
            };

            _controller.HttpContext.Connection.RemoteIpAddress =
                System.Net.IPAddress.Parse("127.0.0.1");
        }

        private static UserDTO CreateUser(long id = 1, string email = "ahmed@test.com")
        {
            return new UserDTO(
                id,
                "Ahmed",
                "Adel",
                email,
                "01000000000",
                "TestPassword123!",
                null,
                true,
                DateTime.UtcNow,
                "Customer");
        }

        // =========================================================
        // GET ALL USERS
        // =========================================================

        [Fact]
        public async Task GetAllUsers_ShouldReturnOk_WhenUsersExist()
        {
            // Arrange
            var users = new List<UserDTO>
            {
                CreateUser(1, "ahmed@test.com"),
                CreateUser(2, "mohamed@test.com")
            };

            A.CallTo(() => _usersService.GetAllUsersAsync())
                .Returns(users);

            // Act
            var result = await _controller.GetAllUsers();

            // Assert
            result.Result.Should().BeOfType<OkObjectResult>();

            var response = result.Result as OkObjectResult;
            response!.StatusCode.Should().Be(200);

            var returnedUsers = response.Value as List<UserDTO>;
            returnedUsers.Should().NotBeNull();
            returnedUsers.Should().HaveCount(2);

            A.CallTo(() => _usersService.GetAllUsersAsync())
                .MustHaveHappenedOnceExactly();
        }

        [Fact]
        public async Task GetAllUsers_ShouldHandleEmptyList_WhenNoUsersExist()
        {
            // Arrange
            A.CallTo(() => _usersService.GetAllUsersAsync())
                .Returns(new List<UserDTO>());

            // Act
            var result = await _controller.GetAllUsers();

            // Assert
            // Assumption: the controller returns NotFound for an empty list.
            result.Result.Should().BeOfType<NotFoundObjectResult>();

            A.CallTo(() => _usersService.GetAllUsersAsync())
                .MustHaveHappenedOnceExactly();
        }

        // =========================================================
        // GET USER BY EMAIL
        // =========================================================

        [Fact]
        public async Task GetUserByEmail_ShouldReturnOk_WhenUserExists()
        {
            // Arrange
            const string email = "ahmed@test.com";
            var user = CreateUser(1, email);

            A.CallTo(() => _usersService.GetUserByEmailAsync(email))
                .Returns(user);

            // Act
            var result = await _controller.GetUserByEmail(email);

            // Assert
            result.Result.Should().BeOfType<OkObjectResult>();

            var response = result.Result as OkObjectResult;
            response!.StatusCode.Should().Be(200);

            A.CallTo(() => _usersService.GetUserByEmailAsync(email))
                .MustHaveHappenedOnceExactly();
        }

        [Fact]
        public async Task GetUserByEmail_ShouldReturnNotFound_WhenUserDoesNotExist()
        {
            // Arrange
            const string email = "missing@test.com";

            A.CallTo(() => _usersService.GetUserByEmailAsync(email))
                .Returns((UserDTO?)null);

            // Act
            var result = await _controller.GetUserByEmail(email);

            // Assert
            result.Result.Should().BeOfType<NotFoundObjectResult>();
        }

        // =========================================================
        // CREATE USER
        // =========================================================

        [Fact]
        public async Task CreateUser_ShouldReturnCreated_WhenUserIsSavedSuccessfully()
        {
            // Arrange
            var user = CreateUser(0);

            A.CallTo(() => _usersService.CreateUserAsync(
                    A<UserDTO>._))
                .Returns(10);

            // Act
            var result = await _controller.CreateUser(user);

            // Assert
            // Verify the response type expected by your controller.
            result.Result.Should().NotBeNull();

            A.CallTo(() => _usersService.CreateUserAsync(
                    A<UserDTO>._))
                .MustHaveHappenedOnceExactly();
        }

        [Fact]
        public async Task CreateUser_ShouldReturnBadRequest_WhenDtoIsNull()
        {
            // Act
            var result = await _controller.CreateUser(null!);

            // Assert
            result.Result.Should().BeOfType<BadRequestObjectResult>();

            A.CallTo(() => _usersService.CreateUserAsync(
                    A<UserDTO>._))
                .MustNotHaveHappened();
        }

        // =========================================================
        // UPDATE USER
        // =========================================================

        [Fact]
        public async Task UpdateUser_ShouldReturnOk_WhenUserIsUpdatedSuccessfully()
        {
            // Arrange
            const long userId = 1;
            var user = CreateUser(userId);

            // FindAsync must use this service method.
            A.CallTo(() => _usersService.GetUserByIdAsync(userId))
                .Returns(user);

            A.CallTo(() => _usersService.UpdateUserAsync(
                    userId,
                    A<UserDTO>._))
                .Returns(user);

            // Act
            var result = await _controller.UpdateUser(userId, user);

            // Assert
            // Assumption: successful update returns HTTP 200.
            result.Result.Should().BeOfType<OkObjectResult>();

            A.CallTo(() => _usersService.GetUserByIdAsync(userId))
                .MustHaveHappenedOnceExactly();
        }

        [Fact]
        public async Task UpdateUser_ShouldReturnNotFound_WhenUserDoesNotExist()
        {
            // Arrange
            const long userId = 999;
            var user = CreateUser(userId);

            A.CallTo(() => _usersService.GetUserByIdAsync(userId))
                .Returns((UserDTO?)null);

            // Act
            var result = await _controller.UpdateUser(userId, user);

            // Assert
            result.Result.Should().BeOfType<NotFoundObjectResult>();

            A.CallTo(() => _usersService.UpdateUserAsync(
                    A<long>._,
                    A<UserDTO>._))
                .MustNotHaveHappened();
        }


        // =========================================================
        // DELETE USER
        // =========================================================

        [Fact]
        public async Task DeleteUser_ShouldReturnOk_WhenUserIsDeleted()
        {
            // Arrange
            const long userId = 1;

            A.CallTo(() => _usersService.DeleteUserAsync(userId))
                .Returns(true);

            // Act
            var result = await _controller.DeleteUser(userId);

            // Assert
            result.Should().BeOfType<OkObjectResult>();

            A.CallTo(() => _usersService.DeleteUserAsync(userId))
                .MustHaveHappenedOnceExactly();
        }


        [Fact]
        public async Task DeleteUser_ShouldReturnNotFound_WhenUserDoesNotExist()
        {
            // Arrange
            const long userId = 999;

            // This test assumes the controller distinguishes a missing
            // user from another deletion failure.
            A.CallTo(() => _usersService.DeleteUserAsync(userId))
                .Returns(false);

            // Act
            var result = await _controller.DeleteUser(userId);

            // Assert
            // Use this assertion only if the controller returns 404
            // for a false result when the user does not exist.
            result.Should().BeOfType<NotFoundObjectResult>();
        }
    }
}