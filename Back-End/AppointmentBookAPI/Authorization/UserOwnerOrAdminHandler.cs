using AppointmentBookAPI.Authorization;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

public class UserOwnerOrAdminHandler
    : AuthorizationHandler<UserOwnerOrAdminRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        UserOwnerOrAdminRequirement requirement)
    {
        // =========================
        // ADMIN CAN ACCESS ANY USER
        // =========================

        if (context.User.IsInRole("Admin"))
        {
            context.Succeed(requirement);

            return Task.CompletedTask;
        }


        // =========================
        // GET LOGGED-IN USER ID
        // =========================

        var userIdClaim =
            context.User.FindFirst(
                ClaimTypes.NameIdentifier);


        if (userIdClaim == null)
        {
            return Task.CompletedTask;
        }


        // =========================
        // GET REQUESTED USER ID
        // =========================

        if (context.Resource is not long requestedUserId)
        {
            return Task.CompletedTask;
        }


        // =========================
        // OWNER CHECK
        // =========================

        if (long.TryParse(
                userIdClaim.Value,
                out long loggedInUserId)
            &&
            loggedInUserId == requestedUserId)
        {
            context.Succeed(requirement);
        }


        return Task.CompletedTask;
    }
}