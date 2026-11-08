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
    public class AppointmentStatusController : ControllerBase
    {
        private readonly IAppointmentStatusService _appointmentStatusData;

        private readonly IAuditLogsService _auditLogger;


        public AppointmentStatusController(
            IAppointmentStatusService appointmentStatusData,
            IAuditLogsService auditLogger)
        {
            _appointmentStatusData = appointmentStatusData;
            _auditLogger = auditLogger;
        }


        // =========================
        // GET ALL
        // =========================

        [HttpGet(
            "AllAppointmentStatuses",
            Name = "GetAllAppointmentStatuses")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<List<appointmentStatusDTO>>>
            GetAllAppointmentStatuses()
        {
            var statuses =
                await AppointmentStatusLogic
                    .GetAllAppointmentStatusesAsync(
                        _appointmentStatusData);


            if (statuses == null || statuses.Count == 0)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for select all appointment statuses",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "No appointment statuses found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for select all appointment statuses",
                "Information",
                null,
                HttpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(statuses);
        }


        // =========================
        // GET BY ID
        // =========================

        [HttpGet(
            "FindAppointmentStatusById/{id:long}",
            Name = "GetAppointmentStatusById")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<appointmentStatusDTO>>
            GetAppointmentStatusById(long id)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid appointment status id."
                });
            }


            var status =
                await AppointmentStatusLogic.FindAsync(
                    _appointmentStatusData,
                    id);


            if (status == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action blocked for find appointment status by id",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "Appointment status not found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for select appointment status by id",
                "Information",
                null,
                HttpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(status.StatusDTO);
        }


        // =========================
        // CREATE
        // =========================

        [HttpPost("CreateAppointmentStatus")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<appointmentStatusDTO>>
            CreateAppointmentStatus(
                [FromBody] appointmentStatusDTO appointmentStatusDTO)
        {
            if (appointmentStatusDTO == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for create appointment status - null data",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return BadRequest(new
                {
                    message = "Appointment status data is required."
                });
            }


            try
            {
                // Create Logic Object
                var status =
                    new AppointmentStatusLogic(
                        appointmentStatusDTO);


                // Save to database
                bool saved =
                    await status.SaveAsync(
                        _appointmentStatusData);


                if (!saved)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for create appointment status",
                        "Warning",
                        null,
                        HttpContext.Connection.RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return BadRequest(new
                    {
                        message = "Could not create appointment status."
                    });
                }


                // Put generated ID into DTO
                appointmentStatusDTO.id = status.id;


                await Utilities.SaveLogs(
                    null,
                    "User action succeeded for create appointment status",
                    "Information",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return CreatedAtRoute(
                    "GetAppointmentStatusById",
                    new { Id = status.id },
                    appointmentStatusDTO);
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
            "UpdateAppointmentStatus/{id:long}",
            Name = "UpdateAppointmentStatus")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<appointmentStatusDTO>>
            UpdateAppointmentStatus(
                long id,
                [FromBody] appointmentStatusDTO appointmentStatusDTO)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid appointment status id."
                });
            }


            if (appointmentStatusDTO == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for update appointment status - null data",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return BadRequest(new
                {
                    message = "Appointment status data is required."
                });
            }


            try
            {
                // Find existing status
                var status =
                    await AppointmentStatusLogic.FindAsync(
                        _appointmentStatusData,
                        id);


                if (status == null)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for update appointment status - not found",
                        "Warning",
                        null,
                        HttpContext.Connection.RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return NotFound(new
                    {
                        message = "Appointment status not found."
                    });
                }


                // =========================
                // UPDATE PROPERTIES
                // =========================

                status.name =
                    appointmentStatusDTO.name;

                status.description =
                    appointmentStatusDTO.description;


                // Save
                bool saved =
                    await status.SaveAsync(
                        _appointmentStatusData);


                if (!saved)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for update appointment status",
                        "Warning",
                        null,
                        HttpContext.Connection.RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return BadRequest(new
                    {
                        message = "Could not update appointment status."
                    });
                }


                await Utilities.SaveLogs(
                    null,
                    "User action succeeded for update appointment status",
                    "Information",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return Ok(status.StatusDTO);
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
            "DeleteAppointmentStatus/{id:long}",
            Name = "DeleteAppointmentStatus")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult>
            DeleteAppointmentStatus(long id)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid appointment status id."
                });
            }


            bool deleted =
                await AppointmentStatusLogic
                    .DeleteAppointmentStatusAsync(
                        _appointmentStatusData,
                        id);


            if (!deleted)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for delete appointment status",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "Appointment status not found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for delete appointment status",
                "Information",
                null,
                HttpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok("Delete successful.");
        }
    }
}