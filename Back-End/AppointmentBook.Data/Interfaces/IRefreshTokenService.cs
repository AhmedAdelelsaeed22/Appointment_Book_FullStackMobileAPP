using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{
    public interface IRefreshTokenService
    {
        Task<RefreshTokensDTO?> GetRefreshTokenAsync(long userId);

        Task<long> InsertRefreshTokenAsync(RefreshTokensDTO refreshToken);

        Task<RefreshTokensDTO?> UpdateRefreshTokenAsync(
            long userId,
            RefreshTokensDTO refreshToken);

        Task<bool> DeleteRefreshTokenAsync(long userId);

    }
}
