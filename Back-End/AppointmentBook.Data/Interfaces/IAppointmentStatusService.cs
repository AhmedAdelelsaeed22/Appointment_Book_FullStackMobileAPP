using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{
    public interface IAppointmentStatusService
    {
        // =========================
        // GET
        // =========================

        Task<List<appointmentStatusDTO>> GetAllAppointmentStatusesAsync();

        Task<appointmentStatusDTO?> GetAppointmentStatusByIdAsync(
            long statusId);


        // =========================
        // CREATE
        // =========================

        Task<long> CreateAppointmentStatusAsync(
            appointmentStatusDTO createAppointmentStatusDto);


        // =========================
        // UPDATE
        // =========================

        Task<appointmentStatusDTO?> UpdateAppointmentStatusAsync(
            long statusId,
            appointmentStatusDTO updateAppointmentStatusDto);


        // =========================
        // DELETE
        // =========================

        Task<bool> DeleteAppointmentStatusAsync(
            long statusId);
    }
}