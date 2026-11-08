using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{
    public interface IFavoriteBusinessService
    {
        // =========================
        // GET
        // =========================

        Task<List<FavoriteBusinessWithDetailsDTO>>
            GetAllFavoriteBusinessesAsync(long userId);


        // =========================
        // INSERT
        // =========================

        Task<long> AddFavoriteBusinessAsync(
            long userId,
            long businessId);


        // =========================
        // DELETE
        // =========================

        Task<bool> RemoveFavoriteBusinessAsync(
            long userId,
            long businessId);
    }
}
