using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AppointmentBook.Data.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Repositories
{
    public class StaffData : IStaffService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public StaffData(
            ApplicationDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }


        // =========================
        // GET ALL
        // =========================

        public async Task<List<staffDTO>>
            GetAllStaffAsync(long businessId)
        {
            var staff = await _context.staff
                .Where(s => s.business_id == businessId)
                .AsNoTracking()
                .ToListAsync();

            return _mapper.Map<List<staffDTO>>(staff);
        }


        // =========================
        // GET BY ID
        // =========================

        public async Task<staffDTO?>
            GetStaffByIdAsync(long staffId)
        {
            var staff = await _context.staff
                .FirstOrDefaultAsync(x =>
                    x.id == staffId);

            if (staff == null)
            {
                return null;
            }

            return _mapper.Map<staffDTO>(staff);
        }


        // =========================
        // CREATE
        // =========================

        public async Task<long> CreateStaffAsync(
            staffDTO createStaffDto)
        {
            // =========================
            // Check business exists
            // =========================

            var businessExists = await _context.businesses
                .AnyAsync(x =>
                    x.id == createStaffDto.business_id);

            if (!businessExists)
            {
                throw new InvalidOperationException(
                    "Business not found.");
            }


            // =========================
            // DTO -> Entity
            // =========================

            var staff = _mapper.Map<staff>(
                createStaffDto);


            // =========================
            // Add to database
            // =========================

            await _context.staff.AddAsync(staff);

            await _context.SaveChangesAsync();


            return staff.id;
        }


        // =========================
        // UPDATE
        // =========================

        public async Task<staffDTO?>
            UpdateStaffAsync(
                long staffId,
                staffDTO updateStaffDto)
        {
            // =========================
            // Get tracked entity
            // =========================

            var staff = await _context.staff
                .FirstOrDefaultAsync(x =>
                    x.id == staffId);

            if (staff == null)
            {
                return null;
            }


            // =========================
            // Check business exists
            // =========================

            var businessExists = await _context.businesses
                .AnyAsync(x =>
                    x.id == updateStaffDto.business_id);

            if (!businessExists)
            {
                throw new InvalidOperationException(
                    "Business not found.");
            }


            // =========================
            // Update Entity
            // =========================

            _mapper.Map(
                updateStaffDto,
                staff);


            // =========================
            // Save changes
            // =========================

            await _context.SaveChangesAsync();


            // =========================
            // Entity -> DTO
            // =========================

            return _mapper.Map<staffDTO>(staff);
        }


        // =========================
        // DELETE
        // =========================

        public async Task<bool> DeleteStaffAsync(
            long staffId)
        {
            var staff = await _context.staff
                .FirstOrDefaultAsync(x =>
                    x.id == staffId);

            if (staff == null)
            {
                return false;
            }


            _context.staff.Remove(staff);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}