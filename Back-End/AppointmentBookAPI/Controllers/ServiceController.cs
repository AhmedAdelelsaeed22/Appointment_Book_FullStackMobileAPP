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
    public class ServiceController : ControllerBase
    {
        private readonly IServiceService _servicesData;

        private readonly IAuditLogsService _auditLogger;


        public ServiceController(
            IServiceService servicesData,
            IAuditLogsService auditLogger)
        {
            _servicesData = servicesData;
            _auditLogger = auditLogger;
        }


        // =========================
        // GET ALL
        // =========================

        [HttpGet(
            "AllServices/{businessId:long}",
            Name = "GetAllServices")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<List<serviceDTO>>>
            GetAllServices(long businessId)
        {
            var services =
                await ServiceLogic
                    .GetAllServicesAsync(
                        _servicesData,
                        businessId);


            if (services == null || services.Count == 0)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for select all services",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "No services found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for select all services",
                "Information",
                null,
                HttpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(services);
        }


        // =========================
        // GET BY ID
        // =========================

        [HttpGet(
            "FindServiceById/{id:long}",
            Name = "GetServiceById")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<serviceDTO>>
            GetServiceById(long id)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid service id."
                });
            }


            var service =
                await ServiceLogic.FindAsync(
                    _servicesData,
                    id);


            if (service == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action blocked for find service by id",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "Service not found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for select service by id",
                "Information",
                null,
                HttpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(service.ServiceDTO);
        }


        // =========================
        // CREATE
        // =========================

        [HttpPost("CreateService")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<serviceDTO>>
            CreateService(
                [FromBody] serviceDTO serviceDTO)
        {
            if (serviceDTO == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for create service - null data",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return BadRequest(new
                {
                    message = "Service data is required."
                });
            }


            try
            {
                // Create Logic Object
                var service =
                    new ServiceLogic(serviceDTO);


                // Save
                bool saved =
                    await service.SaveAsync(
                        _servicesData);


                if (!saved)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for create service",
                        "Warning",
                        null,
                        HttpContext.Connection.RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return BadRequest(new
                    {
                        message = "Could not create service."
                    });
                }


                // Put generated ID into DTO
                serviceDTO.id = service.id;

                serviceDTO.created_at =
                    service.created_at;

                serviceDTO.updated_at =
                    service.updated_at;


                await Utilities.SaveLogs(
                    null,
                    "User action succeeded for create service",
                    "Information",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return CreatedAtRoute(
                    "GetServiceById",
                    new { Id = service.id },
                    serviceDTO);
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
            "UpdateService/{id:long}",
            Name = "UpdateService")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<serviceDTO>>
            UpdateService(
                long id,
                [FromBody] serviceDTO serviceDTO)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid service id."
                });
            }


            if (serviceDTO == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for update service - null data",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return BadRequest(new
                {
                    message = "Service data is required."
                });
            }


            try
            {
                // Find existing service
                var service =
                    await ServiceLogic.FindAsync(
                        _servicesData,
                        id);


                if (service == null)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for update service - not found",
                        "Warning",
                        null,
                        HttpContext.Connection.RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return NotFound(new
                    {
                        message = "Service not found."
                    });
                }


                // =========================
                // UPDATE PROPERTIES
                // =========================

                service.business_id =
                    serviceDTO.business_id;

                service.category_id =
                    serviceDTO.category_id;

                service.name =
                    serviceDTO.name;

                service.description =
                    serviceDTO.description;

                service.duration_minutes =
                    serviceDTO.duration_minutes;

                service.price =
                    serviceDTO.price;

                service.currency =
                    serviceDTO.currency;

                service.is_available =
                    serviceDTO.is_available;


                // Save
                bool saved =
                    await service.SaveAsync(
                        _servicesData);


                if (!saved)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for update service",
                        "Warning",
                        null,
                        HttpContext.Connection.RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);

                    return BadRequest(new
                    {
                        message = "Could not update service."
                    });
                }


                await Utilities.SaveLogs(
                    null,
                    "User action succeeded for update service",
                    "Information",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return Ok(service.ServiceDTO);
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
            "DeleteService/{id:long}",
            Name = "DeleteService")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult>
            DeleteService(long id)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid service id."
                });
            }


            bool deleted =
                await ServiceLogic
                    .DeleteServiceAsync(
                        _servicesData,
                        id);


            if (!deleted)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for delete service",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);

                return NotFound(new
                {
                    message = "Service not found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for delete service",
                "Information",
                null,
                HttpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok("Delete successful.");
        }
    }
}