using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{
    public interface ICategoriesService
    {
        // =========================
        // GET
        // =========================

        Task<List<categoriesDTO>> GetAllCategoriesAsync();

        Task<categoriesDTO?> GetCategoryByIdAsync(
            long categoryId);


        // =========================
        // CREATE
        // =========================

        Task<long> CreateCategoryAsync(
            categoriesDTO createCategoryDto);


        // =========================
        // UPDATE
        // =========================

        Task<categoriesDTO?> UpdateCategoryAsync(
            long categoryId,
            categoriesDTO updateCategoryDto);


        // =========================
        // DELETE
        // =========================

        Task<bool> DeleteCategoryAsync(
            long categoryId);
    }
}