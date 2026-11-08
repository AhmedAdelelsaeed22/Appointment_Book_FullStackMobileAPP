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
    public class StaffController : ControllerBase
    {
        private readonly IStaffService _staffData;

        private readonly IAuditLogsService _auditLogger;


        public StaffController(
            IStaffService staffData,
            IAuditLogsService auditLogger)
        {
            _staffData = staffData;
            _auditLogger = auditLogger;
        }


        // =========================
        // GET ALL
        // =========================

        [HttpGet(
            "AllStaff/{businessId:long}",
            Name = "GetAllStaff")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<List<staffDTO>>>
            GetAllStaff(long businessId)
        {
            var staff =
                await StaffLogic
                    .GetAllStaffAsync(
                        _staffData,
                        businessId);


            if (staff == null || staff.Count == 0)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for select all staff",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "No staff found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for select all staff",
                "Information",
                null,
                HttpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(staff);
        }


        // =========================
        // GET BY ID
        // =========================

        [HttpGet(
            "FindStaffById/{id:long}",
            Name = "GetStaffById")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<staffDTO>>
            GetStaffById(long id)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid staff id."
                });
            }


            var staff =
                await StaffLogic.FindAsync(
                    _staffData,
                    id);


            if (staff == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action blocked for find staff by id",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "Staff not found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for select staff by id",
                "Information",
                null,
                HttpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(staff.StaffDTO);
        }


        // =========================
        // CREATE
        // =========================

        [HttpPost("CreateStaff")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<staffDTO>>
            CreateStaff(
                [FromBody] staffDTO staffDTO)
        {
            if (staffDTO == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for create staff - null data",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return BadRequest(new
                {
                    message = "Staff data is required."
                });
            }


            try
            {
                // Create Logic Object
                var staff =
                    new StaffLogic(staffDTO);


                // Save
                bool saved =
                    await staff.SaveAsync(
                        _staffData);


                if (!saved)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for create staff",
                        "Warning",
                        null,
                        HttpContext.Connection.RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return BadRequest(new
                    {
                        message = "Could not create staff."
                    });
                }


                // Put generated ID into DTO
                staffDTO.id = staff.id;


                await Utilities.SaveLogs(
                    null,
                    "User action succeeded for create staff",
                    "Information",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return CreatedAtRoute(
                    "GetStaffById",
                    new { Id = staff.id },
                    staffDTO);
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
        // UPDATE
        // =========================

        [HttpPut(
            "UpdateStaff/{id:long}",
            Name = "UpdateStaff")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<staffDTO>>
            UpdateStaff(
                long id,
                [FromBody] staffDTO staffDTO)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid staff id."
                });
            }


            if (staffDTO == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for update staff - null data",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return BadRequest(new
                {
                    message = "Staff data is required."
                });
            }


            try
            {
                // Find existing staff
                var staff =
                    await StaffLogic.FindAsync(
                        _staffData,
                        id);


                if (staff == null)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for update staff - not found",
                        "Warning",
                        null,
                        HttpContext.Connection.RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return NotFound(new
                    {
                        message = "Staff not found."
                    });
                }


                // =========================
                // UPDATE PROPERTIES
                // =========================

                staff.business_id =
                    staffDTO.business_id;

                staff.job_title =
                    staffDTO.job_title;

                staff.is_avilable =
                    staffDTO.is_avilable;


                // Save
                bool saved =
                    await staff.SaveAsync(
                        _staffData);


                if (!saved)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for update staff",
                        "Warning",
                        null,
                        HttpContext.Connection.RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return BadRequest(new
                    {
                        message = "Could not update staff."
                    });
                }


                await Utilities.SaveLogs(
                    null,
                    "User action succeeded for update staff",
                    "Information",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return Ok(staff.StaffDTO);
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
        // DELETE
        // =========================

        [HttpDelete(
            "DeleteStaff/{id:long}",
            Name = "DeleteStaff")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult>
            DeleteStaff(long id)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid staff id."
                });
            }


            bool deleted =
                await StaffLogic
                    .DeleteStaffAsync(
                        _staffData,
                        id);


            if (!deleted)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for delete staff",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "Staff not found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for delete staff",
                "Information",
                null,
                HttpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok("Delete successful.");
        }
    }
}