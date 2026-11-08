using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AppointmentBook.Data.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Repositories
{
    public class FavoriteBusinessData : IFavoriteBusinessService
    {
        private readonly ApplicationDbContext _context;

        public FavoriteBusinessData(
            ApplicationDbContext context)
        {
            _context = context;
        }


        // =========================
        // GET ALL
        // =========================

        public async Task<List<FavoriteBusinessWithDetailsDTO>>
            GetAllFavoriteBusinessesAsync(long userId)
        {
            return await _context.user_favorite_businesses
                .AsNoTracking()
                .Where(f => f.user_id == userId)
                .Join(
                    _context.businesses,
                    favorite => favorite.business_id,
                    business => business.id,
                    (favorite, business) => new
                    {
                        favorite,
                        business
                    })
                .Select(x => new FavoriteBusinessWithDetailsDTO
                {
                    id = x.favorite.id,

                    business_id = x.business.id,

                    name = x.business.name,

                    description = x.business.description,

                    email = x.business.email,

                    phone = x.business.phone,

                    logo_url = x.business.logo_url,

                    timezone = x.business.timezone,

                    is_open = x.business.is_open,

                    rating = x.business.rating,

                    location = x.business.location,

                    created_at = x.favorite.created_at
                })
                .ToListAsync();
        }


        // =========================
        // INSERT
        // =========================

        public async Task<long> AddFavoriteBusinessAsync(
            long userId,
            long businessId)
        {
            // Check if business exists
            var businessExists = await _context.businesses
                .AnyAsync(x => x.id == businessId);

            if (!businessExists)
            {
                throw new InvalidOperationException(
                    "Business not found.");
            }


            // Check if already favorite
            var alreadyFavorite = await _context
                .user_favorite_businesses
                .AnyAsync(x =>
                    x.user_id == userId &&
                    x.business_id == businessId);

            if (alreadyFavorite)
            {
                throw new InvalidOperationException(
                    "Business is already in favorites.");
            }


            var favorite = new user_favorite_business
            {
                user_id = userId,
                business_id = businessId,
                created_at = DateTime.UtcNow
            };


            await _context.user_favorite_businesses
                .AddAsync(favorite);

            await _context.SaveChangesAsync();


            return favorite.id;
        }


        // =========================
        // DELETE
        // =========================

        public async Task<bool> RemoveFavoriteBusinessAsync(
            long userId,
            long businessId)
        {
            var favorite = await _context
                .user_favorite_businesses
                .FirstOrDefaultAsync(x =>
                    x.user_id == userId &&
                    x.business_id == businessId);


            if (favorite == null)
            {
                return false;
            }


            _context.user_favorite_businesses
                .Remove(favorite);

            await _context.SaveChangesAsync();


            return true;
        }
    }
}