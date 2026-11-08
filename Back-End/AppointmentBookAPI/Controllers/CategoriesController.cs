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
    public class CategoriesController : ControllerBase
    {
        private readonly ICategoriesService _categoriesData;

        private readonly IAuditLogsService _auditLogger;


        public CategoriesController(
            ICategoriesService categoriesData,
            IAuditLogsService auditLogger)
        {
            _categoriesData = categoriesData;

            _auditLogger = auditLogger;
        }


        // =========================
        // GET ALL
        // =========================

        [HttpGet(
            "AllCategories",
            Name = "GetAllCategories")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<
            List<categoriesDTO>>>
            GetAllCategories()
        {
            var categories =
                await CategoriesLogic
                    .GetAllCategoriesAsync(
                        _categoriesData);


            if (categories == null ||
                categories.Count == 0)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for select all categories",
                    "Warning",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return NotFound(new
                {
                    message = "No categories found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for select all categories",
                "Information",
                null,
                HttpContext.Connection
                    .RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(categories);
        }


        // =========================
        // GET BY ID
        // =========================

        [HttpGet(
            "FindCategoryById/{id:long}",
            Name = "GetCategoryById")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<categoriesDTO>>
            GetCategoryById(
                long id)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid Category id."
                });
            }


            var category =
                await CategoriesLogic.FindAsync(
                    _categoriesData,
                    id);


            if (category == null)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for find category by id",
                    "Warning",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return NotFound(new
                {
                    message = "Category not found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for select category by id",
                "Information",
                null,
                HttpContext.Connection
                    .RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(category.CDTO);
        }


        // =========================
        // CREATE
        // =========================

        [HttpPost(
            "CreateCategory",
            Name = "CreateCategory")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<categoriesDTO>>
            CreateCategory(
                [FromBody] categoriesDTO categoryDTO)
        {
            if (categoryDTO == null)
            {
                return BadRequest(new
                {
                    message = "Category data is required."
                });
            }


            if (string.IsNullOrWhiteSpace(
                categoryDTO.name))
            {
                return BadRequest(new
                {
                    message = "Category name is required."
                });
            }


            try
            {
                var category =
                    new CategoriesLogic(
                        categoryDTO);


                bool saved =
                    await category.SaveAsync(
                        _categoriesData);


                if (!saved)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for create category",
                        "Warning",
                        null,
                        HttpContext.Connection
                            .RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);


                    return BadRequest(new
                    {
                        message =
                            "Could not create category."
                    });
                }


                categoryDTO.id =
                    category.id;


                await Utilities.SaveLogs(
                    null,
                    "User action succeeded for create category",
                    "Information",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return CreatedAtRoute(
                    "GetCategoryById",
                    new { id = category.id },
                    category.CDTO);
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
            "UpdateCategory/{id:long}",
            Name = "UpdateCategory")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<categoriesDTO>>
            UpdateCategory(
                long id,
                [FromBody] categoriesDTO categoryDTO)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid Category id."
                });
            }


            if (categoryDTO == null)
            {
                return BadRequest(new
                {
                    message =
                        "Category data is required."
                });
            }


            if (string.IsNullOrWhiteSpace(
                categoryDTO.name))
            {
                return BadRequest(new
                {
                    message =
                        "Category name is required."
                });
            }


            try
            {
                var category =
                    await CategoriesLogic.FindAsync(
                        _categoriesData,
                        id);


                if (category == null)
                {
                    await Utilities.SaveLogs(
                        null,
                        "User action failed for update category - not found",
                        "Warning",
                        null,
                        HttpContext.Connection
                            .RemoteIpAddress?.ToString()
                            ?? "unknown",
                        _auditLogger);


                    return NotFound(new
                    {
                        message =
                            "Category not found."
                    });
                }


                // =========================
                // UPDATE PROPERTIES
                // =========================

                category.name =
                    categoryDTO.name;


                bool saved =
                    await category.SaveAsync(
                        _categoriesData);


                if (!saved)
                {
                    return BadRequest(new
                    {
                        message =
                            "Could not update category."
                    });
                }


                await Utilities.SaveLogs(
                    null,
                    "User action succeeded for update category",
                    "Information",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return Ok(category.CDTO);
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
            "DeleteCategory/{id:long}",
            Name = "DeleteCategory")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult>
            DeleteCategory(
                long id)
        {
            if (id < 1)
            {
                return BadRequest(new
                {
                    message =
                        "Invalid Category id."
                });
            }


            bool deleted =
                await CategoriesLogic
                    .DeleteCategoryAsync(
                        _categoriesData,
                        id);


            if (!deleted)
            {
                await Utilities.SaveLogs(
                    null,
                    "User action failed for delete category",
                    "Warning",
                    null,
                    HttpContext.Connection
                        .RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return NotFound(new
                {
                    message =
                        "Category not found."
                });
            }


            await Utilities.SaveLogs(
                null,
                "User action succeeded for delete category",
                "Information",
                null,
                HttpContext.Connection
                    .RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(new
            {
                message =
                    "Category deleted successfully."
            });
        }
    }
}