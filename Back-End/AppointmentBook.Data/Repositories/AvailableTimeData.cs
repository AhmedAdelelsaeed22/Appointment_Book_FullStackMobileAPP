using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AppointmentBook.Data.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Repositories
{
    public class AvailableTimeData : IAvailableTimeService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public AvailableTimeData(
            ApplicationDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }


        // =========================
        // GET
        // =========================

        public async Task<List<AvailableTimeDTO>> GetAllAvailableTimesAsync(long businessId)
        {
            var availableTimes = await _context.business_availabilities
                .Where(x => x.business_id == businessId)
                .AsNoTracking()
                .ToListAsync();

            return _mapper.Map<List<AvailableTimeDTO>>(
                availableTimes);
        }


        public async Task<AvailableTimeDTO?> GetAvailableTimeByIdAsync(
            long availableTimeId)
        {
            var availableTime = await _context.business_availabilities
                .FirstOrDefaultAsync(x => x.id == availableTimeId);

            if (availableTime == null)
            {
                return null;
            }

            return _mapper.Map<AvailableTimeDTO>(
                availableTime);
        }


        // =========================
        // CREATE
        // =========================

        public async Task<long> CreateAvailableTimeAsync(
            AvailableTimeDTO createAvailableTimeDto)
        {
            // Check if business exists
            var businessExists = await _context.businesses
                .AnyAsync(x => x.id == createAvailableTimeDto.business_id);

            if (!businessExists)
            {
                throw new InvalidOperationException(
                    "Business does not exist.");
            }


            // Check duplicate available time
            var timeExists = await _context.business_availabilities
                .AnyAsync(x =>
                    x.business_id == createAvailableTimeDto.business_id &&
                    x.available_time == createAvailableTimeDto.available_time);

            if (timeExists)
            {
                throw new InvalidOperationException(
                    "This available time already exists for this business.");
            }


            // DTO -> Entity
            var availableTime = _mapper.Map<business_availability>(
                createAvailableTimeDto);


            // Add to database
            await _context.business_availabilities.AddAsync(
                availableTime);

            await _context.SaveChangesAsync();


            return availableTime.id;
        }


        // =========================
        // UPDATE
        // =========================

        public async Task<AvailableTimeDTO?> UpdateAvailableTimeAsync(
            long availableTimeId,
            AvailableTimeDTO updateAvailableTimeDto)
        {
            // Get tracked entity
            var availableTime = await _context.business_availabilities
                .FirstOrDefaultAsync(x => x.id == availableTimeId);

            if (availableTime == null)
            {
                return null;
            }


            // Check if business exists
            var businessExists = await _context.businesses
                .AnyAsync(x => x.id == updateAvailableTimeDto.business_id);

            if (!businessExists)
            {
                throw new InvalidOperationException(
                    "Business does not exist.");
            }


            // Check duplicate available time
            var timeExists = await _context.business_availabilities
                .AnyAsync(x =>
                    x.business_id == updateAvailableTimeDto.business_id &&
                    x.available_time == updateAvailableTimeDto.available_time &&
                    x.id != availableTimeId);

            if (timeExists)
            {
                throw new InvalidOperationException(
                    "This available time already exists for this business.");
            }


            // DTO -> Entity
            _mapper.Map(
                updateAvailableTimeDto,
                availableTime);


            // Save changes
            await _context.SaveChangesAsync();


            // Entity -> DTO
            return _mapper.Map<AvailableTimeDTO>(
                availableTime);
        }


        // =========================
        // DELETE
        // =========================

        public async Task<bool> DeleteAvailableTimeAsync(
            long availableTimeId)
        {
            var availableTime = await _context.business_availabilities
                .FirstOrDefaultAsync(x => x.id == availableTimeId);

            if (availableTime == null)
            {
                return false;
            }


            _context.business_availabilities.Remove(
                availableTime);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}