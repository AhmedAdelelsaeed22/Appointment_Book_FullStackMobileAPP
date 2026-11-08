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
    public class BusinessController : ControllerBase
    {


        private readonly IBusinessService _businessesData;


        private readonly IAuditLogsService _auditLogger;

        public BusinessController(IBusinessService businessesData, IAuditLogsService auditLogger)
        {
            _businessesData = businessesData;
            _auditLogger = auditLogger;
        }





        [HttpGet("AllBusinesses", Name = "GetAllBusinesses")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<List<BusinessWithCategoryDTO>>> GetAllBusinesses()
        {

            var businesses = await BusinessLogic.GetAllBusinessesAsync(_businessesData);

            if (businesses == null || businesses.Count == 0)
            {
                await Utilities.SaveLogs(null, "User action failed for select all businesses", "Warning", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return NotFound(new
                {
                    message = "No businesses found."
                });
            }




            await Utilities.SaveLogs(null, "User action succeeded for select all businesses", "Information", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

            return Ok(businesses);
        }



        [HttpGet("FindBusinessById/{id:long}", Name = "GetBusinessById")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<businessDTO>> GetBusinessById(long id)
        {
            var business = await BusinessLogic.FindAsync(
                _businessesData,
                id);

            if (business == null)
            {
                await Utilities.SaveLogs(null, "User action blocked for find business by id", "Warning", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);
                return NotFound(new
                {
                    message = "Business not found."
                });
            }



            await Utilities.SaveLogs(null, "User action succeeded for select business by id", "Information", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

            return Ok(business.BDTO);
        }



        [HttpPost("CreateBusiness")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<businessDTO>> CreateBusiness(
         [FromBody] businessDTO businessDTO)
        {

            if (businessDTO == null)
            {
                await Utilities.SaveLogs(null, "user action failed for create business - null data", "Warning", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);
                return BadRequest(new
                {
                    message = "Business data is required."
                });
            }



            try
            {
                // Create Business Object
                var business = new BusinessLogic(businessDTO);

                // Save to database
                bool saved = await business.SaveAsync(_businessesData);

                if (!saved)
                {
                    await Utilities.SaveLogs(businessDTO.owner_id, "user action failed for create business", "Warning", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);
                    return BadRequest(new
                    {
                        message = "Could not create business."
                    });
                }

                // Put the generated database ID into the DTO
                businessDTO.id = business.id;

                await Utilities.SaveLogs(businessDTO.owner_id, "user action succeeded for create business", "Information", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return CreatedAtRoute(
                    "GetBusinessById",
                    new { Id = business.id },
                    businessDTO
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
        // UPDATE BUSINESS
        // =========================
        [HttpPut("UpdateBusiness/{id:long}", Name = "UpdateBusiness")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<businessDTO>> UpdateBusiness(
            long id,
            [FromBody] businessDTO businessDTO)
        {


            if (businessDTO == null)
            {

                await Utilities.SaveLogs(null, "user action failed for update business - null data", "Warning", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return BadRequest(new
                {
                    message = "Business data is required."
                });
            }


            try
            {
                // Find existing business
                var business = await BusinessLogic.FindAsync(
                    _businessesData,
                    id);

                if (business == null)
                {

                    await Utilities.SaveLogs(null, "user action failed for update business - not found", "Warning", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                    return NotFound(new
                    {
                        message = "Business not found."
                    });
                }


                // =========================
                // UPDATE PROPERTIES
                // =========================

                business.name = businessDTO.name;
                business.description = businessDTO.description;
                business.email = businessDTO.email;
                business.phone = businessDTO.phone;
                business.logo_url = businessDTO.logo_url;
                business.timezone = businessDTO.timezone;
                business.is_open = businessDTO.is_open;
                business.service_category_id = businessDTO.service_category_id;
                business.rating = businessDTO.rating;
                business.location = businessDTO.location;


                // Save
                bool saved = await business.SaveAsync(_businessesData);

                if (!saved)
                {

                    await Utilities.SaveLogs(null, "user action failed for update business", "Warning", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);


                    return BadRequest(new
                    {
                        message = "Could not update business."
                    });
                }

                await Utilities.SaveLogs(business.owner_id, "user action succeeded for update business", "Information", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return Ok(business.BDTO);
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
        [HttpDelete("DeleteBusiness/{id:long}", Name = "DeleteBusiness")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteBusiness(long id)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid Business id."
                });
            }




            bool deleted = await BusinessLogic.DeleteBusinessAsync(
                _businessesData,
                id);

            if (!deleted)
            {
                await Utilities.SaveLogs(null, "user action failed for delete business", "Warning", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

                return NotFound(new
                {
                    message = "Business not found."
                });
            }

            await Utilities.SaveLogs(null, "user action succeeded for delete business", "Information", null, HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown", _auditLogger);

            return Ok("Delete successful.");
        }
    }
}
