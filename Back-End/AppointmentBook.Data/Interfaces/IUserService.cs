using AppointmentBook.Data.Dto;

namespace AppointmentBook.Data.Interfaces
{
    public interface IUserService
    {
        // =========================
        // GET
        // =========================

        Task<List<UserDTO>> GetAllUsersAsync();


        Task<UserDTO?> GetUserByIdAsync(long userId);

        Task<UserDTO?> GetUserByEmailAsync(string email);

        Task<long?> GetUserIdByEmailAsync(string email);

        // =========================
        // CREATE
        // =========================

        Task<long> CreateUserAsync(UserDTO createUserDto);


        // =========================
        // UPDATE
        // =========================

        Task<UserDTO?> UpdateUserAsync(
            long userId,
            UserDTO updateUserDto);


        // =========================
        // DELETE
        // =========================

        Task<bool> DeleteUserAsync(long userId);

        Task<bool> ChangePasswordAsync(long userId, string newPassword);
    }
}
