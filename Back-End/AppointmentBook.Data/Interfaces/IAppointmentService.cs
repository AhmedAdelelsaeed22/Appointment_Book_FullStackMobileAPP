using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{
    public interface IAppointmentService
    {
        // =========================
        // GET
        // =========================

        Task<AppointmentDetailsDTO?> GetAppointmentByIdAsync(
            long appointmentId);

        Task<List<AppointmentListDTO>> GetAllAppointmentsByUserIdAsync(
            long userId);


        // =========================
        // CREATE
        // =========================

        Task<long> CreateAppointmentAsync(
            appointmentDTO createAppointmentDto);


        // =========================
        // UPDATE
        // =========================

        Task<bool> UpdateAppointmentAsync(
            long appointmentId,
            long changedByUserId,
            appointmentDTO updateAppointmentDto,
            string? reason);


        // =========================
        // CONFIRM
        // =========================

        Task<bool> ConfirmAppointmentAsync(
            long appointmentId,
            long changedByUserId,
            string? reason);


        // =========================
        // CANCEL
        // =========================

        Task<bool> CancelAppointmentAsync(
            long appointmentId,
            long changedByUserId,
            string reason);


        // =========================
        // COMPLETE
        // =========================

        Task<bool> CompleteAppointmentAsync(
            long appointmentId,
            long changedByUserId,
            string? reason);
    }
}