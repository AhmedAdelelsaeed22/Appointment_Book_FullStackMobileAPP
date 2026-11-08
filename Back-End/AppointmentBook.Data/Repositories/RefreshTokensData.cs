using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AppointmentBook.Data.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Repositories
{

    public class RefreshTokensData : IRefreshTokenService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public RefreshTokensData(
            ApplicationDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }


        public async Task<RefreshTokensDTO?> GetRefreshTokenAsync(long userId)
        {
            var refreshToken = await _context.refresh_tokens
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.user_id == userId && x.revoked_at == null);

            if (refreshToken == null)
            {
                return null;
            }

            var refreshTokenDto = _mapper.Map<RefreshTokensDTO>(refreshToken);

            return refreshTokenDto;
        }


        public async Task<long> InsertRefreshTokenAsync(
            RefreshTokensDTO refreshToken)
        {


            // DTO -> Entity
            var refreshTokenEntity = _mapper.Map<refresh_token>(refreshToken);



            // Add to database
            await _context.refresh_tokens.AddAsync(refreshTokenEntity);

            await _context.SaveChangesAsync();


            return refreshTokenEntity.id;
        }


        public async Task<RefreshTokensDTO?> UpdateRefreshTokenAsync(
            long userId,
            RefreshTokensDTO refreshToken)
        {
            // Get tracked entity
            var refreshTokenEntity = await _context.refresh_tokens
                .FirstOrDefaultAsync(x => x.user_id == userId && x.revoked_at == null);


            if (refreshTokenEntity == null)
            {
                return null;
            }

            // Update Entity from DTO
            _mapper.Map(refreshToken, refreshTokenEntity);

            // Save changes
            await _context.SaveChangesAsync();


            // Entity -> DTO
            var resultDto = _mapper.Map<RefreshTokensDTO>(refreshTokenEntity);

            return resultDto;
        }



        public async Task<bool> DeleteRefreshTokenAsync(long userId)
        {
            var refreshToken = await _context.refresh_tokens
                .FirstOrDefaultAsync(x => x.user_id == userId);

            if (refreshToken == null)
            {
                return false;
            }


            _context.refresh_tokens.Remove(refreshToken);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}
