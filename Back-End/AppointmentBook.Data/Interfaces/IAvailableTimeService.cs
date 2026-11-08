using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{
    public interface IAvailableTimeService
    {
        // =========================
        // GET
        // =========================

        Task<List<AvailableTimeDTO>> GetAllAvailableTimesAsync(long businessId);

        Task<AvailableTimeDTO?> GetAvailableTimeByIdAsync(
            long availableTimeId);


        // =========================
        // CREATE
        // =========================

        Task<long> CreateAvailableTimeAsync(
            AvailableTimeDTO createAvailableTimeDto);


        // =========================
        // UPDATE
        // =========================

        Task<AvailableTimeDTO?> UpdateAvailableTimeAsync(
            long availableTimeId,
            AvailableTimeDTO updateAvailableTimeDto);


        // =========================
        // DELETE
        // =========================

        Task<bool> DeleteAvailableTimeAsync(
            long availableTimeId);
    }
}