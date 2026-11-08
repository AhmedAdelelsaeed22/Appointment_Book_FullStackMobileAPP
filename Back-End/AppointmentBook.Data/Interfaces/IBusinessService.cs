using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{

    public interface IBusinessService
    {
        // =========================
        // GET
        // =========================

        Task<List<BusinessWithCategoryDTO>> GetAllBusinessesAsync();



        Task<businessDTO?> GetBusinessByIdAsync(long businessId);

        // =========================
        // CREATE
        // =========================

        Task<long> CreateBusinessAsync(businessDTO createBusinessDto);


        // =========================
        // UPDATE
        // =========================

        Task<businessDTO?> UpdateBusinessAsync(
            long businessId,
            businessDTO updateBusinessDto);


        // =========================
        // DELETE
        // =========================

        Task<bool> DeleteBusinessAsync(long businessId);
    }
}
