using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;
using AppointmentBook.Logic;
using AppointmentBookAPI.Helper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AppointmentBookAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class FavoriteBusinessController : ControllerBase
    {
        private readonly IFavoriteBusinessService _favoriteBusinessData;

        private readonly IAuditLogsService _auditLogger;


        public FavoriteBusinessController(
            IFavoriteBusinessService favoriteBusinessData,
            IAuditLogsService auditLogger)
        {
            _favoriteBusinessData = favoriteBusinessData;
            _auditLogger = auditLogger;
        }


        // =========================
        // GET ALL FAVORITES
        // =========================

        [HttpGet("AllFavorites", Name = "GetAllFavoriteBusinesses")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<List<FavoriteBusinessWithDetailsDTO>>> GetAllFavoriteBusinesses()
        {
            long userId = GetUserId();


            var favorites =
                await FavoriteBusinessLogic
                    .GetAllFavoriteBusinessesAsync(
                        _favoriteBusinessData,
                        userId);


            if (favorites == null || favorites.Count == 0)
            {
                await Utilities.SaveLogs(
                    userId,
                    "User action failed for select all favorite businesses",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return NotFound(new
                {
                    message = "No favorite businesses found."
                });
            }


            await Utilities.SaveLogs(
                userId,
                "User action succeeded for select all favorite businesses",
                "Information",
                null,
                HttpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(favorites);
        }


        // =========================
        // ADD FAVORITE
        // =========================

        [HttpPost("AddFavorite/{businessId:long}",
            Name = "AddFavoriteBusiness")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult> AddFavoriteBusiness(
            long businessId)
        {
            if (businessId < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid Business id."
                });
            }


            long userId = GetUserId();


            try
            {
                long favoriteId =
                    await FavoriteBusinessLogic
                        .AddFavoriteBusinessAsync(
                            _favoriteBusinessData,
                            userId,
                            businessId);


                await Utilities.SaveLogs(
                    userId,
                    "User action succeeded for adding favorite business",
                    "Information",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return CreatedAtRoute(
                    "GetAllFavoriteBusinesses",
                    null,
                    new
                    {
                        id = favoriteId,
                        user_id = userId,
                        business_id = businessId,
                        message = "Business added to favorites."
                    });
            }
            catch (InvalidOperationException ex)
            {
                if (ex.Message == "Business not found.")
                {
                    return NotFound(new
                    {
                        message = ex.Message
                    });
                }


                return Conflict(new
                {
                    message = ex.Message
                });
            }
        }


        // =========================
        // REMOVE FAVORITE
        // =========================

        [HttpDelete("RemoveFavorite/{businessId:long}",
            Name = "RemoveFavoriteBusiness")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> RemoveFavoriteBusiness(
            long businessId)
        {
            if (businessId < 1)
            {
                return BadRequest(new
                {
                    message = "Invalid Business id."
                });
            }


            long userId = GetUserId();


            bool deleted =
                await FavoriteBusinessLogic
                    .RemoveFavoriteBusinessAsync(
                        _favoriteBusinessData,
                        userId,
                        businessId);


            if (!deleted)
            {
                await Utilities.SaveLogs(
                    userId,
                    "User action failed for remove favorite business",
                    "Warning",
                    null,
                    HttpContext.Connection.RemoteIpAddress?.ToString()
                        ?? "unknown",
                    _auditLogger);


                return NotFound(new
                {
                    message =
                        "Favorite business was not found."
                });
            }


            await Utilities.SaveLogs(
                userId,
                "User action succeeded for remove favorite business",
                "Information",
                null,
                HttpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "unknown",
                _auditLogger);


            return Ok(new
            {
                message =
                    "Business removed from favorites."
            });
        }


        // =========================
        // GET USER ID FROM JWT
        // =========================

        private long GetUserId()
        {
            var userIdClaim =
                User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? User.FindFirst("sub")?.Value;


            if (!long.TryParse(userIdClaim, out long userId))
            {
                throw new UnauthorizedAccessException(
                    "Invalid user identity.");
            }


            return userId;
        }
    }
}