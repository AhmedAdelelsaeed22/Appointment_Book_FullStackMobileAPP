using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Logic
{
    public class FavoriteBusinessLogic
    {
        // =========================
        // PROPERTIES
        // =========================

        public long id { get; set; }

        public long user_id { get; set; }

        public long business_id { get; set; }

        public DateTime created_at { get; set; }


        // =========================
        // DTO
        // =========================

        public FavoriteBusinessDTO FBDTO
        {
            get
            {
                return new FavoriteBusinessDTO(
                    this.id,
                    this.user_id,
                    this.business_id,
                    this.created_at
                );
            }
        }


        // =========================
        // CONSTRUCTOR
        // =========================

        public FavoriteBusinessLogic(
            FavoriteBusinessDTO favoriteBusinessDTO)
        {
            this.id = favoriteBusinessDTO.id;
            this.user_id = favoriteBusinessDTO.user_id;
            this.business_id = favoriteBusinessDTO.business_id;
            this.created_at = favoriteBusinessDTO.created_at;
        }


        // =========================
        // GET ALL
        // =========================

        public static async Task<List<FavoriteBusinessWithDetailsDTO>>
            GetAllFavoriteBusinessesAsync(
                IFavoriteBusinessService favoriteBusinessData,
                long userId)
        {
            return await favoriteBusinessData
                .GetAllFavoriteBusinessesAsync(userId);
        }


        // =========================
        // INSERT
        // =========================

        public static async Task<long>
            AddFavoriteBusinessAsync(
                IFavoriteBusinessService favoriteBusinessData,
                long userId,
                long businessId)
        {
            return await favoriteBusinessData
                .AddFavoriteBusinessAsync(
                    userId,
                    businessId);
        }


        // =========================
        // DELETE
        // =========================

        public static async Task<bool>
            RemoveFavoriteBusinessAsync(
                IFavoriteBusinessService favoriteBusinessData,
                long userId,
                long businessId)
        {
            return await favoriteBusinessData
                .RemoveFavoriteBusinessAsync(
                    userId,
                    businessId);
        }
    }
}