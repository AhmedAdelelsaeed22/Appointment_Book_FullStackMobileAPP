using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{
    public interface IServiceService
    {
        // =========================
        // GET
        // =========================

        Task<List<serviceDTO>> GetAllServicesAsync(long businessId);

        Task<serviceDTO?> GetServiceByIdAsync(
            long serviceId);


        // =========================
        // CREATE
        // =========================

        Task<long> CreateServiceAsync(
            serviceDTO createServiceDto);


        // =========================
        // UPDATE
        // =========================

        Task<serviceDTO?> UpdateServiceAsync(
            long serviceId,
            serviceDTO updateServiceDto);


        // =========================
        // DELETE
        // =========================

        Task<bool> DeleteServiceAsync(
            long serviceId);
    }
}