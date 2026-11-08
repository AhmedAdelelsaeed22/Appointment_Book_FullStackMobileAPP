using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Logic
{
    public class RefreshTokensLogic
    {

        // =========================
        // MODE
        // =========================

        public enum enMode
        {
            Insert = 0,
            Update = 1
        }

        public enMode Mode { get; private set; }

        // =========================
        // PROPERTIES
        // =========================

        public long id { get; set; }

        public long user_id { get; set; }

        public string token_hash { get; set; } = null!;

        public DateTime? expires_at { get; set; }

        public DateTime? revoked_at { get; set; }


        public RefreshTokensDTO RDTO
        {
            get
            {
                return new RefreshTokensDTO
                (
                    this.id,
                    this.user_id,
                    this.token_hash,
                    this.expires_at,
                    this.revoked_at

                );
            }
        }


        // =========================
        // CONSTRUCTOR
        // =========================

        public RefreshTokensLogic(RefreshTokensDTO refreshTokenDTO, enMode mode = enMode.Insert)
        {

            this.id = refreshTokenDTO.id;
            this.user_id = refreshTokenDTO.user_id;
            this.token_hash = refreshTokenDTO.token_hash;
            this.expires_at = refreshTokenDTO.expires_at;
            this.revoked_at = refreshTokenDTO.revoked_at;

            this.Mode = mode;
        }


        public static async Task<RefreshTokensLogic?> FindAsync(
            IRefreshTokenService refreshTokenData,
            long userId)
        {
            RefreshTokensDTO? refreshTokenDTO =
                await refreshTokenData.GetRefreshTokenAsync(userId);

            if (refreshTokenDTO == null)
            {
                return null;
            }

            return new RefreshTokensLogic(refreshTokenDTO, enMode.Update);
        }


        private async Task<bool> InsertAsync(IRefreshTokenService refreshTokenData)
        {
            long newRefreshTokenId =
                await refreshTokenData.InsertRefreshTokenAsync(RDTO);

            if (newRefreshTokenId == 0)
            {
                return false;
            }

            return true;
        }


        private async Task<bool> UpdateAsync(IRefreshTokenService refreshTokenData)
        {
            RefreshTokensDTO? refreshTokensDTO =
                await refreshTokenData.UpdateRefreshTokenAsync(this.user_id, RDTO);

            if (refreshTokensDTO == null)
            {
                return false;
            }

            return true;
        }


        public static async Task<bool> DeleteAsync(
            IRefreshTokenService refreshTokenData,
            long userId)
        {
            return await refreshTokenData.DeleteRefreshTokenAsync(userId);
        }


        public async Task<bool> Save(IRefreshTokenService refreshTokenData)
        {
            switch (Mode)
            {
                case enMode.Insert:

                    if (await InsertAsync(refreshTokenData))
                    {
                        Mode = enMode.Update;

                        return true;
                    }

                    return false;


                case enMode.Update:

                    return await UpdateAsync(refreshTokenData);
            }

            return false;
        }

    }
}
