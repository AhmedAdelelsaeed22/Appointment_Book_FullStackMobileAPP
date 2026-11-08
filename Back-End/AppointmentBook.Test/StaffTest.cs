using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;
using AppointmentBookAPI.Controllers;
using FakeItEasy;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;


namespace AppointmentBook.Test
{
    public class StaffTest
    {
        private readonly IStaffService _staffData;

        private readonly IAuditLogsService _auditLogger;

        private readonly StaffController _controller;

        public StaffTest()
        {
            _staffData = A.Fake<IStaffService>();
            _auditLogger = A.Fake<IAuditLogsService>();
            _controller = new StaffController(_staffData, _auditLogger);

            // Configure HttpContext for controller actions
            _controller.ControllerContext = new ControllerContext
            {
                HttpContext = new DefaultHttpContext()
            };

            // Simulate a request from an IP address
            _controller.HttpContext.Connection.RemoteIpAddress =
                System.Net.IPAddress.Parse("127.0.0.1");
        }

        private static staffDTO CreateStaffDTO(long id, long businessId, string jobTitle, bool isAvailable)
        {
            return new staffDTO(id, businessId, jobTitle, isAvailable);
        }


        [Fact]
        public async Task GetAllStaff_ShouldReturnOk_WhenStaffExist()
        {

            // Arrange
            long businessId = 1;
            var staffList = new List<staffDTO>
            {
                CreateStaffDTO(1, businessId, "Manager", true),
                CreateStaffDTO(2, businessId, "Receptionist", false),
                CreateStaffDTO(3, businessId, "Consultation", true),
                CreateStaffDTO(4, businessId, "Assistant", false)
            };

            A.CallTo(() => _staffData.GetAllStaffAsync(businessId)).Returns(staffList);

            // Act
            var result = await _controller.GetAllStaff(businessId);

            // Assert
            result.Result.Should().BeOfType<OkObjectResult>();

            var okResult = result.Result as OkObjectResult;
            okResult!.StatusCode.Should().Be(StatusCodes.Status200OK);

            var returnedStaffList = okResult.Value as List<staffDTO>;

            returnedStaffList.Should().NotBeNull();
            returnedStaffList.Count.Should().Be(staffList.Count);
            returnedStaffList[0].job_title.Should().Be(staffList[0].job_title);

            A.CallTo(() => _staffData.GetAllStaffAsync(businessId)).MustHaveHappenedOnceExactly();
        }


        [Fact]
        public async Task GetAllStaff_ShouldHandleEmptyList_WhenNoStaffExist()
        {
            //Arrange
            long businessId = 1;

            A.CallTo(() => _staffData.GetAllStaffAsync(businessId)).Returns(new List<staffDTO>());

            // Act
            var result = await _controller.GetAllStaff(businessId);

            // Assert
            result.Result.Should().BeOfType<NotFoundObjectResult>();
            A.CallTo(() => _staffData.GetAllStaffAsync(businessId)).MustHaveHappenedOnceExactly();
        }


        [Fact]
        public async Task GetStaffById_ShouldReturnOk_WhenStaffIsExist()
        {
            // Arrange
            long id = 1;
            var staff = CreateStaffDTO(1, 1, "Manager", true);

            A.CallTo(() => _staffData.GetStaffByIdAsync(id)).Returns(staff);

            // Act
            var result = await _controller.GetStaffById(id);


            // Assert
            var response =
                  result.Result.Should().BeOfType<OkObjectResult>().Subject;

            response.StatusCode.Should().Be(200);

            A.CallTo(() => _staffData.GetStaffByIdAsync(id)).MustHaveHappenedOnceExactly();
        }


        [Fact]
        public async Task GetStaffById_ShouldHandleEmptyValue_WhenStaffIsNotExist()
        {
            // Arrange
            long id = 1;


            A.CallTo(() => _staffData.GetStaffByIdAsync(id)).Returns((staffDTO?)null);

            // Act
            var result = await _controller.GetStaffById(id);


            // Assert
            result.Result.Should().BeOfType<NotFoundObjectResult>();
            var response = result.Result as NotFoundObjectResult;
            response!.StatusCode.Should().Be(404);

            A.CallTo(() => _staffData.GetStaffByIdAsync(id)).MustHaveHappenedOnceExactly();
        }


        [Fact]
        public async Task CreateStaff_ShouldReturnCreated_WhenCreateIsSuccessfully()
        {
            // Arrange
            var staffDTO = CreateStaffDTO(1, 1, "Manager", true);
            A.CallTo(() => _staffData.CreateStaffAsync(A<staffDTO>._)).Returns(10);

            // Act
            var result = await _controller.CreateStaff(staffDTO);

            // Assert
            result.Should().NotBeNull();

            A.CallTo(() => _staffData.CreateStaffAsync(
                    A<staffDTO>._))
                .MustHaveHappenedOnceExactly();
        }

        [Fact]
        public async Task CreateStaff_ShouldReturnBadRequest_WhenStaffDtoIsNull()
        {

            // Act
            var result = await _controller.CreateStaff(null!);

            // Assert
            result.Result.Should().BeOfType<BadRequestObjectResult>();

            A.CallTo(() => _staffData.CreateStaffAsync(
                    A<staffDTO>._))
                .MustNotHaveHappened();
        }

        [Fact]
        public async Task UpdateStaff_ShouldReturnOk_WhenStaffIsUpdate()
        {
            long id = 1;
            var staff = CreateStaffDTO(id, 1, "Manager", true);

            // A.CallTo(() => _staffData.GetStaffByIdAsync(id)).Returns(staff);
            A.CallTo(() => _staffData.UpdateStaffAsync(id, A<staffDTO>._))
                .Returns(staff);

            var result = await _controller.UpdateStaff(id, staff);

            result.Result.Should().BeOfType<OkObjectResult>();

            //A.CallTo(() => _staffData.GetStaffByIdAsync(
            //       id))
            //   .MustHaveHappenedOnceExactly();

            A.CallTo(() => _staffData.UpdateStaffAsync(
               A<long>._,
               A<staffDTO>._))
           .MustHaveHappenedOnceExactly();
        }


        [Fact]
        public async Task UpdateStaff_ShouldReturnNotFound_WhenStaffIsNotExist()
        {
            long id = 999;
            var staff = CreateStaffDTO(id, 1, "Manager", true);

            A.CallTo(() => _staffData.GetStaffByIdAsync(id)).Returns((staffDTO)null!);

            var result = await _controller.UpdateStaff(id, staff);

            result.Result.Should().BeOfType<NotFoundObjectResult>();

            A.CallTo(() => _staffData.UpdateStaffAsync(
                   A<long>._,
                   A<staffDTO>._))
               .MustNotHaveHappened();
        }


        [Fact]
        public async Task DeleteStaff_ShouldReturnOk_WhenStaffDoesDeleted()
        {
            long staffId = 2;

            A.CallTo(() => _staffData.DeleteStaffAsync(staffId)).Returns(true);

            var result = await _controller.DeleteStaff(staffId);

            result.Should().BeOfType<OkObjectResult>();

            A.CallTo(() => _staffData.DeleteStaffAsync(A<long>._))
                .MustHaveHappenedOnceExactly();
        }



        [Fact]
        public async Task DeleteStaff_ShouldReturnNotFound_WhenStaffDoesNotExist()
        {
            // Arrange
            const long staffId = 999;

            // This test assumes the controller distinguishes a missing
            // user from another deletion failure.
            A.CallTo(() => _staffData.DeleteStaffAsync(staffId))
                .Returns(false);

            // Act
            var result = await _controller.DeleteStaff(staffId);

            // Assert
            // Use this assertion only if the controller returns 404
            // for a false result when the user does not exist.
            result.Should().BeOfType<NotFoundObjectResult>();
        }
    }
}
