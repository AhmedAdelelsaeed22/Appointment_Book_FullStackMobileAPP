using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{
    public interface IStaffService
    {
        // =========================
        // GET
        // =========================

        Task<List<staffDTO>> GetAllStaffAsync(long businessId);

        Task<staffDTO?> GetStaffByIdAsync(
            long staffId);


        // =========================
        // CREATE
        // =========================

        Task<long> CreateStaffAsync(
            staffDTO createStaffDto);


        // =========================
        // UPDATE
        // =========================

        Task<staffDTO?> UpdateStaffAsync(
            long staffId,
            staffDTO updateStaffDto);


        // =========================
        // DELETE
        // =========================

        Task<bool> DeleteStaffAsync(
            long staffId);
    }
}