using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AppointmentBook.Data.Helper;
using AppointmentBook.Data.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Repositories
{
    public class UsersData : IUserService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public UsersData(
            ApplicationDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }



        // =========================
        // GET
        // =========================

        public async Task<List<UserDTO>> GetAllUsersAsync()
        {
            var users = await _context.users
                .AsNoTracking()
                .ToListAsync();

            var usersDto = _mapper.Map<List<UserDTO>>(users);

            return usersDto;
        }


        public async Task<UserDTO?> GetUserByIdAsync(long userId)
        {
            var user = await _context.users
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.id == userId);

            if (user == null)
            {
                return null;
            }

            var userDto = _mapper.Map<UserDTO>(user);

            return userDto;
        }


        public async Task<UserDTO?> GetUserByEmailAsync(string email)
        {
            var user = await _context.users
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.email == email);

            if (user == null)
            {
                return null;
            }

            var userDto = _mapper.Map<UserDTO>(user);

            return userDto;
        }


        public async Task<long?> GetUserIdByEmailAsync(string email)
        {
            var user = await _context.users
                .AsNoTracking()
                .Select(u => new { u.id, u.email })
                .FirstOrDefaultAsync(x => x.email == email);

            if (user == null)
            {
                return null;
            }

            return user.id;
        }



        // =========================
        // CREATE
        // =========================

        public async Task<long> CreateUserAsync(
            UserDTO createUserDto)
        {
            // Check if email already exists
            var emailExists = await _context.users
                .AnyAsync(x => x.email == createUserDto.email);

            if (emailExists)
            {
                throw new InvalidOperationException(
                    "A user with this email already exists.");
            }


            if (!Validator.IsValidEmail(createUserDto.email) || !Validator.PasswordValidator.IsValid(createUserDto.password_hash))
            {
                throw new InvalidOperationException(
                    "Invalid credentials format.");
            }

            // DTO -> Entity
            var user = _mapper.Map<user>(createUserDto);


            user.password_hash = Hasher.HashPassword(createUserDto.password_hash);


            // Add to database
            await _context.users.AddAsync(user);

            await _context.SaveChangesAsync();


            return user.id;
        }


        // =========================
        // UPDATE
        // =========================

        public async Task<UserDTO?> UpdateUserAsync(
            long userId,
            UserDTO updateUserDto)
        {
            // Get tracked entity
            var user = await _context.users
                .FirstOrDefaultAsync(x => x.id == userId);

            if (user == null)
            {
                return null;
            }


            // Check if another user already uses this email
            var emailExists = await _context.users
                .AnyAsync(x =>
                    x.email == updateUserDto.email &&
                    x.id != userId);

            if (emailExists)
            {
                throw new InvalidOperationException(
                    "Another user already uses this email.");
            }

            if (!Validator.IsValidEmail(updateUserDto.email) || !Validator.PasswordValidator.IsValid(updateUserDto.password_hash))
            {
                throw new InvalidOperationException(
                    "Invalid credentials format.");
            }


            // Update Entity from DTO
            _mapper.Map(updateUserDto, user);

            user.password_hash = Hasher.HashPassword(updateUserDto.password_hash);

            // Save changes
            await _context.SaveChangesAsync();


            // Entity -> DTO
            var resultDto = _mapper.Map<UserDTO>(user);

            return resultDto;
        }


        // =========================
        // DELETE
        // =========================

        public async Task<bool> DeleteUserAsync(long userId)
        {
            var user = await _context.users
                .FirstOrDefaultAsync(x => x.id == userId);

            if (user == null)
            {
                return false;
            }


            _context.users.Remove(user);

            await _context.SaveChangesAsync();

            return true;
        }


        public async Task<bool> ChangePasswordAsync(long userId, string newPassword)
        {
            var user = await _context.users
                .FirstOrDefaultAsync(x => x.id == userId);

            if (user == null)
            {
                return false;
            }

            if (!Validator.PasswordValidator.IsValid(newPassword))
            {
                throw new InvalidOperationException(
                    "Invalid password format.");
            }


            user.password_hash = Hasher.HashPassword(newPassword);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}
