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
    public class AvailableTimeController : ControllerBase
    {
        private readonly IAvailableTimeService _availableTimesData;

        private readonly IAuditLogsService _auditLogger;


        public AvailableTimeController(
            IAvailableTimeService availableTimesData,
            IAuditLogsService auditLogger)
        {
            _availableTimesData = availableTimesData;
            _auditLogger = auditLogger;
        }


        // =========================
        // GET ALL
        // =========================

        [HttpGet("AllAvailableTimes/{businessId:long}", Name = "GetAllAvailableTimes")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<List<AvailableTimeDTO>>>
            GetAllAvailableTimes(long businessId)
        {
            var availableTimes =
                await AvailableTimeLogic
                    .GetAllAvailableTimesAsync(
                        _availableTimesData,
                        businessId);

            if (availableTimes == null ||
                availableTimes.Count == 0)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for select all available times",
                    "Warning",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "No available times found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for select all available times",
                "Information",
                null,
                HttpContext.Connection
                    .RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(availableTimes);
        }


        // =========================
        // GET BY ID
        // =========================

        [HttpGet(
            "FindAvailableTimeById/{id:long}",
            Name = "GetAvailableTimeById")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<AvailableTimeDTO>>
            GetAvailableTimeById(long id)
        {
            var availableTime =
                await AvailableTimeLogic.FindAsync(
                    _availableTimesData,
                    id);

            if (availableTime == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action blocked for find available time by id",
                    "Warning",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "Available time not found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for select available time by id",
                "Information",
                null,
                HttpContext.Connection
                    .RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(availableTime.ATDTO);
        }


        // =========================
        // CREATE
        // =========================

        [HttpPost("CreateAvailableTime")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<AvailableTimeDTO>>
            CreateAvailableTime(
                [FromBody] AvailableTimeDTO availableTimeDTO)
        {
            if (availableTimeDTO == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for create available time - null data",
                    "Warning",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return BadRequest(new
                {
                    message = "Available time data is required."
                });
            }


            if (availableTimeDTO.business_id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid business id."
                });
            }


            try
            {
                // Create Logic Object
                var availableTime =
                    new AvailableTimeLogic(
                        availableTimeDTO);


                // Save
                bool saved =
                    await availableTime.SaveAsync(
                        _availableTimesData);


                if (!saved)
                {
                    await Utilities.SaveLogs(
                        availableTimeDTO.business_id,
                        "User action failed for create available time",
                        "Warning",
                        null,
                        HttpContext.Connection
                            .RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return BadRequest(new
                    {
                        message = "Could not create available time."
                    });
                }


                // Put generated ID into DTO
                availableTimeDTO.id =
                    availableTime.id;


                await Utilities.SaveLogs(
                    availableTimeDTO.business_id,
                    "User action succeeded for create available time",
                    "Information",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return CreatedAtRoute(
                    "GetAvailableTimeById",
                    new { Id = availableTime.id },
                    availableTimeDTO);
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
            "UpdateAvailableTime/{id:long}",
            Name = "UpdateAvailableTime")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<AvailableTimeDTO>>
            UpdateAvailableTime(
                long id,
                [FromBody] AvailableTimeDTO availableTimeDTO)
        {
            if (availableTimeDTO == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for update available time - null data",
                    "Warning",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return BadRequest(new
                {
                    message = "Available time data is required."
                });
            }


            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid available time id."
                });
            }


            if (availableTimeDTO.business_id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid business id."
                });
            }


            try
            {
                // Find existing available time
                var availableTime =
                    await AvailableTimeLogic.FindAsync(
                        _availableTimesData,
                        id);


                if (availableTime == null)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for update available time - not found",
                        "Warning",
                        null,
                        HttpContext.Connection
                            .RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return NotFound(new
                    {
                        message = "Available time not found."
                    });
                }


                // =========================
                // UPDATE PROPERTIES
                // =========================

                availableTime.business_id =
                    availableTimeDTO.business_id;

                availableTime.available_time =
                    availableTimeDTO.available_time;


                // Save
                bool saved =
                    await availableTime.SaveAsync(
                        _availableTimesData);


                if (!saved)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for update available time",
                        "Warning",
                        null,
                        HttpContext.Connection
                            .RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return BadRequest(new
                    {
                        message = "Could not update available time."
                    });
                }


                await Utilities.SaveLogs(
                    availableTime.business_id,
                    "User action succeeded for update available time",
                    "Information",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return Ok(availableTime.ATDTO);
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
            "DeleteAvailableTime/{id:long}",
            Name = "DeleteAvailableTime")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult>
            DeleteAvailableTime(long id)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid available time id."
                });
            }


            bool deleted =
                await AvailableTimeLogic
                    .DeleteAvailableTimeAsync(
                        _availableTimesData,
                        id);


            if (!deleted)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for delete available time",
                    "Warning",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "Available time not found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for delete available time",
                "Information",
                null,
                HttpContext.Connection
                    .RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok("Delete successful.");
        }
    }
}