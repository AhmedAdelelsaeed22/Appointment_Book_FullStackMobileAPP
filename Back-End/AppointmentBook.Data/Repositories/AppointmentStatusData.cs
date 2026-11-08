using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AppointmentBook.Data.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Repositories
{
    public class AppointmentStatusData : IAppointmentStatusService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public AppointmentStatusData(
            ApplicationDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }


        // =========================
        // GET ALL
        // =========================

        public async Task<List<appointmentStatusDTO>>
            GetAllAppointmentStatusesAsync()
        {
            var statuses = await _context.appointment_statuses
                .AsNoTracking()
                .ToListAsync();

            return _mapper.Map<List<appointmentStatusDTO>>(statuses);
        }


        // =========================
        // GET BY ID
        // =========================

        public async Task<appointmentStatusDTO?>
            GetAppointmentStatusByIdAsync(long statusId)
        {
            var status = await _context.appointment_statuses
                .FirstOrDefaultAsync(x => x.id == statusId);

            if (status == null)
            {
                return null;
            }

            return _mapper.Map<appointmentStatusDTO>(status);
        }


        // =========================
        // CREATE
        // =========================

        public async Task<long> CreateAppointmentStatusAsync(
            appointmentStatusDTO createAppointmentStatusDto)
        {
            // Check if name already exists
            var nameExists = await _context.appointment_statuses
                .AnyAsync(x =>
                    x.name == createAppointmentStatusDto.name);

            if (nameExists)
            {
                throw new InvalidOperationException(
                    "An appointment status with this name already exists.");
            }


            // DTO -> Entity
            var status = _mapper.Map<appointment_status>(
                createAppointmentStatusDto);


            // Add to database
            await _context.appointment_statuses.AddAsync(status);

            await _context.SaveChangesAsync();


            return status.id;
        }


        // =========================
        // UPDATE
        // =========================

        public async Task<appointmentStatusDTO?>
            UpdateAppointmentStatusAsync(
                long statusId,
                appointmentStatusDTO updateAppointmentStatusDto)
        {
            // Get tracked entity
            var status = await _context.appointment_statuses
                .FirstOrDefaultAsync(x => x.id == statusId);

            if (status == null)
            {
                return null;
            }


            // Check if another status already uses this name
            var nameExists = await _context.appointment_statuses
                .AnyAsync(x =>
                    x.name == updateAppointmentStatusDto.name &&
                    x.id != statusId);

            if (nameExists)
            {
                throw new InvalidOperationException(
                    "Another appointment status already uses this name.");
            }


            // Update Entity from DTO
            _mapper.Map(updateAppointmentStatusDto, status);


            // Save changes
            await _context.SaveChangesAsync();


            // Entity -> DTO
            return _mapper.Map<appointmentStatusDTO>(status);
        }


        // =========================
        // DELETE
        // =========================

        public async Task<bool> DeleteAppointmentStatusAsync(
            long statusId)
        {
            var status = await _context.appointment_statuses
                .FirstOrDefaultAsync(x => x.id == statusId);

            if (status == null)
            {
                return false;
            }


            _context.appointment_statuses.Remove(status);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}