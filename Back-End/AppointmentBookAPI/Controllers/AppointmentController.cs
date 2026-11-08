using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;
using AppointmentBook.Data.Logic;
using AppointmentBookAPI.Helper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AppointmentBook.Api.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class AppointmentsController : ControllerBase
    {
        private readonly IAppointmentService _appointmentService;
        private readonly IAuditLogsService _auditLogger;

        public AppointmentsController(
            IAppointmentService appointmentService,
            IAuditLogsService auditLogger)
        {
            _appointmentService = appointmentService;
            _auditLogger = auditLogger;
        }

        // =========================================================
        // GET APPOINTMENT BY ID
        // =========================================================

        [HttpGet("GetAppointmentById/{appointmentId:long}", Name = "GetAppointmentById")]
        [ProducesResponseType(
            typeof(AppointmentDetailsDTO),
            StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<AppointmentDetailsDTO>>
            GetAppointmentById(long appointmentId)
        {
            try
            {
                AppointmentDetailsDTO? appointment =
                    await AppointmentLogic.GetAppointmentByIdAsync(
                        _appointmentService,
                        appointmentId);

                if (appointment == null)
                {
                    return NotFound(new
                    {
                        message = "Appointment not found."
                    });
                }

                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Get appointment {appointmentId}",
                    "Information",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return Ok(appointment);
            }
            catch (Exception ex)
            {
                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Error getting appointment {appointmentId}",
                    "Error",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new
                    {
                        message =
                            "An error occurred while getting the appointment."
                    });
            }
        }

        // =========================================================
        // GET ALL APPOINTMENTS BY USER ID
        // =========================================================

        [HttpGet("GetAllAppointmentsByUserId/{userId:long}")]
        [ProducesResponseType(
            typeof(List<AppointmentListDTO>),
            StatusCodes.Status200OK)]
        public async Task<ActionResult<List<AppointmentListDTO>>>
            GetAllAppointmentsByUserId(long userId)
        {
            try
            {
                List<AppointmentListDTO> appointments =
                    await AppointmentLogic
                        .GetAllAppointmentsByUserIdAsync(
                            _appointmentService,
                            userId);

                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Get all appointments for user {userId}",
                    "Information",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return Ok(appointments);
            }
            catch (Exception ex)
            {
                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Error getting appointments for user {userId}",
                    "Error",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new
                    {
                        message =
                            "An error occurred while getting appointments."
                    });
            }
        }

        // =========================================================
        // CREATE APPOINTMENT
        // =========================================================

        [HttpPost("CreateAppointment")]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status201Created)]
        public async Task<ActionResult<AppointmentDetailsDTO>> CreateAppointment(appointmentDTO appointmentDto)
        {
            try
            {
                AppointmentLogic appointment =
                    new AppointmentLogic(
                        appointmentDto,
                        AppointmentLogic.enMode.Insert);

                bool saved =
                    await appointment.SaveAsync(
                        _appointmentService,
                        GetUserId() ?? appointmentDto.customer_id);

                if (!saved)
                {
                    await Utilities.SaveLogs(
                        GetUserId(),
                        "Failed to create appointment",
                        "Warning",
                        GetUserEmail(),
                        GetIpAddress(),
                        _auditLogger);

                    return BadRequest(new
                    {
                        message = "Failed to create appointment."
                    });
                }

                AppointmentDetailsDTO? createdAppointment =
                    await AppointmentLogic.GetAppointmentByIdAsync(
                        _appointmentService,
                        appointment.id);

                if (createdAppointment == null)
                {
                    return StatusCode(
                        StatusCodes.Status500InternalServerError,
                        new
                        {
                            message =
                                "Appointment was created but could not be retrieved."
                        });
                }

                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Appointment {appointment.id} created",
                    "Information",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return CreatedAtRoute(
                    "GetAppointmentById",
                    new
                    {
                        appointmentId = appointment.id
                    },
                    createdAppointment);
            }
            catch (Exception ex)
            {
                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Error creating appointment",
                    "Error",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return BadRequest(new
                {
                    message = ex.Message
                });
            }
        }

        // =========================================================
        // UPDATE APPOINTMENT
        // =========================================================

        [HttpPut("UpdateAppointment/{appointmentId:long}")]
        [ProducesResponseType(
            typeof(AppointmentDetailsDTO),
            StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<AppointmentDetailsDTO>>
            UpdateAppointment(
                long appointmentId,
                appointmentDTO appointmentDto,
                [FromQuery] string? reason = null)
        {
            try
            {
                AppointmentLogic? appointment =
                    await AppointmentLogic.FindAsync(
                        _appointmentService,
                        appointmentId);

                if (appointment == null)
                {
                    await Utilities.SaveLogs(
                        GetUserId(),
                        $"Appointment {appointmentId} not found",
                        "Information",
                        GetUserEmail(),
                        GetIpAddress(),
                        _auditLogger);

                    return NotFound(new
                    {
                        message = "Appointment not found."
                    });
                }

                appointment.business_id =
                    appointmentDto.business_id;

                appointment.customer_id =
                    appointmentDto.customer_id;

                appointment.service_id =
                    appointmentDto.service_id;

                appointment.start_datetime =
                    appointmentDto.start_datetime;

                appointment.end_datetime =
                    appointmentDto.end_datetime;

                appointment.customer_notes =
                    appointmentDto.customer_notes;

                appointment.staff_id =
                    appointmentDto.staff_id;

                long changedByUserId =
                    GetUserId() ?? appointmentDto.customer_id;

                bool updated =
                    await appointment.SaveAsync(
                        _appointmentService,
                        changedByUserId,
                        reason);

                if (!updated)
                {
                    await Utilities.SaveLogs(
                        GetUserId(),
                        $"Failed to update appointment {appointmentId}",
                        "Warning",
                        GetUserEmail(),
                        GetIpAddress(),
                        _auditLogger);

                    return BadRequest(new
                    {
                        message =
                            "Failed to update appointment."
                    });
                }

                AppointmentDetailsDTO? updatedAppointment =
                    await AppointmentLogic.GetAppointmentByIdAsync(
                        _appointmentService,
                        appointmentId);

                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Appointment {appointmentId} updated",
                    "Information",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return Ok(updatedAppointment);
            }
            catch (Exception ex)
            {
                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Error updating appointment {appointmentId}",
                    "Error",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return BadRequest(new
                {
                    message = ex.Message
                });
            }
        }

        // =========================================================
        // CONFIRM APPOINTMENT
        // =========================================================

        [HttpPost("ConfirmAppointment/{appointmentId:long}")]
        [ProducesResponseType(
            typeof(AppointmentDetailsDTO),
            StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<AppointmentDetailsDTO>>
            ConfirmAppointment(
                long appointmentId,
                [FromQuery] string? reason = null)
        {
            try
            {
                AppointmentDetailsDTO? appointment =
                    await AppointmentLogic.GetAppointmentByIdAsync(
                        _appointmentService,
                        appointmentId);

                if (appointment == null)
                {
                    return NotFound(new
                    {
                        message = "Appointment not found."
                    });
                }

                long changedByUserId = GetUserId() ?? 0;

                if (changedByUserId <= 0)
                {
                    return Unauthorized();
                }

                bool confirmed =
                    await AppointmentLogic.ConfirmAppointmentAsync(
                        _appointmentService,
                        appointmentId,
                        changedByUserId,
                        reason);

                if (!confirmed)
                {
                    return BadRequest(new
                    {
                        message =
                            "Failed to confirm appointment."
                    });
                }

                AppointmentDetailsDTO? updatedAppointment =
                    await AppointmentLogic.GetAppointmentByIdAsync(
                        _appointmentService,
                        appointmentId);

                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Appointment {appointmentId} confirmed",
                    "Information",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return Ok(updatedAppointment);
            }
            catch (Exception ex)
            {
                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Error confirming appointment {appointmentId}",
                    "Error",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return BadRequest(new
                {
                    message = ex.Message
                });
            }
        }

        // =========================================================
        // CANCEL APPOINTMENT
        // =========================================================

        [HttpPost("CancelAppointment/{appointmentId:long}")]
        [ProducesResponseType(
            typeof(AppointmentDetailsDTO),
            StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<AppointmentDetailsDTO>>
            CancelAppointment(
                long appointmentId,
                [FromQuery] string reason)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(reason))
                {
                    return BadRequest(new
                    {
                        message =
                            "A cancellation reason is required."
                    });
                }

                AppointmentDetailsDTO? appointment =
                    await AppointmentLogic.GetAppointmentByIdAsync(
                        _appointmentService,
                        appointmentId);

                if (appointment == null)
                {
                    return NotFound(new
                    {
                        message = "Appointment not found."
                    });
                }

                long changedByUserId = GetUserId() ?? 0;

                if (changedByUserId <= 0)
                {
                    return Unauthorized();
                }

                bool cancelled =
                    await AppointmentLogic.CancelAppointmentAsync(
                        _appointmentService,
                        appointmentId,
                        changedByUserId,
                        reason);

                if (!cancelled)
                {
                    return BadRequest(new
                    {
                        message =
                            "Failed to cancel appointment."
                    });
                }

                AppointmentDetailsDTO? updatedAppointment =
                    await AppointmentLogic.GetAppointmentByIdAsync(
                        _appointmentService,
                        appointmentId);

                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Appointment {appointmentId} cancelled",
                    "Information",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return Ok(updatedAppointment);
            }
            catch (Exception ex)
            {
                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Error cancelling appointment {appointmentId}",
                    "Error",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return BadRequest(new
                {
                    message = ex.Message
                });
            }
        }

        // =========================================================
        // COMPLETE APPOINTMENT
        // =========================================================

        [HttpPost("CompleteAppointment/{appointmentId:long}")]
        [ProducesResponseType(
            typeof(AppointmentDetailsDTO),
            StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<AppointmentDetailsDTO>>
            CompleteAppointment(
                long appointmentId,
                [FromQuery] string? reason = null)
        {
            try
            {
                AppointmentDetailsDTO? appointment =
                    await AppointmentLogic.GetAppointmentByIdAsync(
                        _appointmentService,
                        appointmentId);

                if (appointment == null)
                {
                    return NotFound(new
                    {
                        message = "Appointment not found."
                    });
                }

                long changedByUserId = GetUserId() ?? 0;

                if (changedByUserId <= 0)
                {
                    return Unauthorized();
                }

                bool completed =
                    await AppointmentLogic.CompleteAppointmentAsync(
                        _appointmentService,
                        appointmentId,
                        changedByUserId,
                        reason);

                if (!completed)
                {
                    return BadRequest(new
                    {
                        message =
                            "Failed to complete appointment."
                    });
                }

                AppointmentDetailsDTO? updatedAppointment =
                    await AppointmentLogic.GetAppointmentByIdAsync(
                        _appointmentService,
                        appointmentId);

                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Appointment {appointmentId} completed",
                    "Information",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return Ok(updatedAppointment);
            }
            catch (Exception ex)
            {
                await Utilities.SaveLogs(
                    GetUserId(),
                    $"Error completing appointment {appointmentId}",
                    "Error",
                    GetUserEmail(),
                    GetIpAddress(),
                    _auditLogger);

                return BadRequest(new
                {
                    message = ex.Message
                });
            }
        }

        // =========================================================
        // HELPER METHODS
        // =========================================================

        private long? GetUserId()
        {
            string? userId =
                User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? User.FindFirstValue("sub");

            if (long.TryParse(userId, out long id))
                return id;

            return null;
        }

        private string? GetUserEmail()
        {
            return User.FindFirstValue(ClaimTypes.Email)
                ?? User.FindFirstValue("email");
        }

        private string GetIpAddress()
        {
            return HttpContext.Connection.RemoteIpAddress?
                       .ToString()
                   ?? "Unknown";
        }
    }
}