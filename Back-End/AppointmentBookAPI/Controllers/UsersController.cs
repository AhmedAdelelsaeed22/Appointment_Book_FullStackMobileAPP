using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;
using AppointmentBook.Logic;
using AppointmentBookAPI.Helper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AppointmentBookAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _usersData;

        private readonly IConfiguration _configuration;

        private readonly IAuditLogsService _auditLogger;

        public UsersController(IUserService usersData, IAuditLogsService auditLogger, IConfiguration configuration)
        {
            _usersData = usersData;
            _auditLogger = auditLogger;
            _configuration = configuration;
        }





        [Authorize(Roles = "Admin")]
        [HttpGet("All", Name = "GetAllUsers")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<List<UserDTO>>> GetAllUsers()
        {

            var users = await UsersLogic.GetAllUsersAsync(_usersData);

            if (users == null || users.Count == 0)
            {
                await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action failed for select all users", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return NotFound(new
                {
                    message = "No users found."
                });
            }

            await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action succeeded for select all users", "Information", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

            return Ok(users);
        }


        [HttpGet("FindUserById/{id:long}", Name = "GetUserById")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<UserDTO>> GetUserById(long id, [FromServices] IAuthorizationService authorizationService)
        {

            if (id < 1)
            {
                await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action failed for select all users", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return BadRequest("Invalid user id.");
            }

            var user = await UsersLogic.FindAsync(
                _usersData,
                id);

            if (user == null)
            {
                await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action blocked for find user by id", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);
                return NotFound(new
                {
                    message = "User not found."
                });
            }

            var authResult = await authorizationService.AuthorizeAsync(
            User,
             id,
            "UserOwnerOrAdmin");

            if (!authResult.Succeeded)
            {
                await Utilities.SaveLogs(Convert.ToInt64(id), "Forbidden access.", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);
                return Forbid(); // 403
            }

            await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action succeeded for select user by id", "Information", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

            return Ok(user.UDTO);
        }




        [HttpGet("FindUserByEmail/{email}", Name = "GetUserByEmail")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<UserDTO>> GetUserByEmail(
            string email)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return BadRequest(new
                {
                    message = "Email is required."
                });
            }


            var user = await UsersLogic.FindByEmailAsync(
                _usersData,
                email);

            if (user == null)
            {
                await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action failed for find user by email", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);
                return NotFound(new
                {
                    message = "User not found."
                });
            }

            await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action succeeded for select user by email", "Information", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

            return Ok(user.UDTO);
        }


        [Authorize(Roles = "Admin")]
        [HttpPost("InsertUser")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<UserDTO>> CreateUser(
         [FromBody] UserDTO userDTO)
        {

            if (userDTO == null)
            {
                await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action failed for create user - null data", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);
                return BadRequest(new
                {
                    message = "User data is required."
                });
            }

            try
            {
                // Create Business Object
                var user = new UsersLogic(userDTO);

                // Save to database
                bool saved = await user.SaveAsync(_usersData);

                if (!saved)
                {
                    await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action failed for create user", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);
                    return BadRequest(new
                    {
                        message = "Could not create user."
                    });
                }

                // Put the generated database ID into the DTO
                userDTO.id = user.Id;

                await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action succeeded for create user", "Information", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return CreatedAtRoute(
                    "GetUserById",
                    new { Id = user.Id },
                    userDTO
                );
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new
                {
                    message = ex.Message
                });
            }
        }


        // =========================
        // UPDATE USER
        // =========================
        // PUT: api/users/5
        [Authorize(Roles = "Admin")]
        [HttpPut("UpdateUser/{id:long}", Name = "UpdateUser")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<UserDTO>> UpdateUser(
            long id,
            [FromBody] UserDTO userDTO)
        {


            if (id < 1)
            {
                await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action failed for select all users", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return BadRequest("Invalid user id.");
            }

            if (userDTO == null)
            {

                await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action failed for update user - null data", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return BadRequest(new
                {
                    message = "User data is required."
                });
            }


            try
            {
                // Find existing user
                var user = await UsersLogic.FindAsync(
                    _usersData,
                    id);

                if (user == null)
                {

                    await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action failed for update user - not found", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                    return NotFound(new
                    {
                        message = "User not found."
                    });
                }


                // =========================
                // UPDATE PROPERTIES
                // =========================

                user.FirstName = userDTO.first_name;
                user.LastName = userDTO.last_name;
                user.Email = userDTO.email;
                user.Phone = userDTO.phone;
                user.ProfileImageUrl = userDTO.profile_image_url;
                user.IsActive = userDTO.is_active;
                user.CreatedAt = userDTO.created_at;
                user.UserRole = userDTO.user_role;

                /*
                 * IMPORTANT:
                 *
                 * Only update PasswordHash if the client
                 * actually sends a new password.
                 */

                if (!string.IsNullOrWhiteSpace(
                        userDTO.password_hash))
                {
                    user.PasswordHash =
                        userDTO.password_hash;
                }


                // Save
                bool saved = await user.SaveAsync(_usersData);

                if (!saved)
                {

                    await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action failed for update user", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);


                    return BadRequest(new
                    {
                        message = "Could not update user."
                    });
                }

                await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action succeeded for update user", "Information", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return Ok(user.UDTO);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new
                {
                    message = ex.Message
                });
            }
        }


        // =========================
        // DELETE USER
        // =========================
        // DELETE: api/users/5
        [Authorize(Roles = "Admin")]
        [HttpDelete("DeleteUser/{id:long}", Name = "DeleteUser")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteUser(long id)
        {

            bool deleted = await UsersLogic.DeleteUserAsync(
                _usersData,
                id);

            if (!deleted)
            {
                await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action failed for delete user", "Warning", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return NotFound(new
                {
                    message = "User not found."
                });
            }

            await Utilities.SaveLogs(Convert.ToInt64(_configuration["AdminIDs:ID"]), "Admin action succeeded for delete user", "Information", _configuration["AdminEmails:Email"]!, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

            return Ok("Delete successful.");
        }
    }
}
