using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Logic
{
    public class UsersLogic
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

        public long Id { get; set; }

        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string? Phone { get; set; }

        public string PasswordHash { get; set; } = null!;

        public string? ProfileImageUrl { get; set; }

        public bool IsActive { get; set; }

        public DateTime CreatedAt { get; set; }

        public string UserRole { get; set; } = null!;

        public UserDTO UDTO
        {
            get
            {
                return new UserDTO
                (
                    this.Id,
                    this.FirstName,
                    this.LastName,
                    this.Email,
                    this.Phone,
                    this.PasswordHash,
                    this.ProfileImageUrl,
                    this.IsActive,
                    this.CreatedAt,
                    this.UserRole

                );
            }
        }


        // =========================
        // CONSTRUCTOR
        // =========================

        public UsersLogic(
            UserDTO userDTO,
            enMode mode = enMode.Insert)
        {

            this.Id = userDTO.id;
            this.FirstName = userDTO.first_name;
            this.LastName = userDTO.last_name;
            this.Email = userDTO.email;
            this.Phone = userDTO.phone;
            this.PasswordHash = userDTO.password_hash;
            this.ProfileImageUrl = userDTO.profile_image_url;
            this.IsActive = userDTO.is_active;
            this.CreatedAt = userDTO.created_at;
            this.UserRole = userDTO.user_role;

            Mode = mode;
        }


        // =========================
        // GET ALL
        // =========================

        public static async Task<List<UserDTO>> GetAllUsersAsync(
            IUserService usersData)
        {
            return await usersData.GetAllUsersAsync();
        }

        public static async Task<long?> GetUserIdByEmailAsync(string email, IUserService usersData)
        {
            return await usersData.GetUserIdByEmailAsync(email);
        }


        // =========================
        // FIND BY ID
        // =========================

        public static async Task<UsersLogic?> FindAsync(
            IUserService usersData,
            long userId)
        {
            UserDTO? userDTO =
                await usersData.GetUserByIdAsync(userId);

            if (userDTO == null)
            {
                return null;
            }

            return new UsersLogic(
                userDTO,
                enMode.Update);
        }


        // =========================
        // FIND BY EMAIL
        // =========================

        public static async Task<UsersLogic?> FindByEmailAsync(
            IUserService usersData,
            string email)
        {
            UserDTO? userDTO =
                await usersData.GetUserByEmailAsync(email);

            if (userDTO == null)
            {
                return null;
            }

            return new UsersLogic(
                userDTO,
                enMode.Update);
        }




        // =========================
        // INSERT
        // =========================

        private async Task<bool> InsertNewUserAsync(IUserService usersData)
        {
            long newUserId =
                await usersData.CreateUserAsync(UDTO);

            if (newUserId == 0)
            {
                return false;
            }

            Id = newUserId;

            return true;
        }


        // =========================
        // UPDATE
        // =========================

        private async Task<bool> UpdateUserAsync(IUserService usersData)
        {
            UserDTO? updatedUser =
                await usersData.UpdateUserAsync(
                    UDTO.id,
                    UDTO);

            return updatedUser != null;
        }


        // =========================
        // SAVE
        // =========================

        public async Task<bool> SaveAsync(IUserService usersData)
        {
            switch (Mode)
            {
                case enMode.Insert:

                    if (await InsertNewUserAsync(usersData))
                    {
                        Mode = enMode.Update;

                        return true;
                    }

                    return false;


                case enMode.Update:

                    return await UpdateUserAsync(usersData);
            }

            return false;
        }


        // =========================
        // DELETE
        // =========================

        public static async Task<bool> DeleteUserAsync(
            IUserService usersData,
            long userId)
        {
            return await usersData.DeleteUserAsync(userId);
        }


        public static async Task<bool> ChangePasswordAsync(long userId, string newPassword, IUserService userService)
        {
            return await userService.ChangePasswordAsync(userId, newPassword);
        }

    }
}
