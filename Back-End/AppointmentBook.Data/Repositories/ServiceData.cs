using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AppointmentBook.Data.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Repositories
{
    public class ServiceData : IServiceService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public ServiceData(
            ApplicationDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }


        // =========================
        // GET ALL
        // =========================

        public async Task<List<serviceDTO>>
            GetAllServicesAsync(long businessId)
        {
            var services = await _context.services
                .Where(s => s.business_id == businessId)
                .AsNoTracking()
                .ToListAsync();

            return _mapper.Map<List<serviceDTO>>(services);
        }


        // =========================
        // GET BY ID
        // =========================

        public async Task<serviceDTO?>
            GetServiceByIdAsync(long serviceId)
        {
            var service = await _context.services
                .FirstOrDefaultAsync(x => x.id == serviceId);

            if (service == null)
            {
                return null;
            }

            return _mapper.Map<serviceDTO>(service);
        }


        // =========================
        // CREATE
        // =========================

        public async Task<long> CreateServiceAsync(
            serviceDTO createServiceDto)
        {
            // =========================
            // Check business exists
            // =========================

            var businessExists = await _context.businesses
                .AnyAsync(x =>
                    x.id == createServiceDto.business_id);

            if (!businessExists)
            {
                throw new InvalidOperationException(
                    "Business not found.");
            }


            // =========================
            // Check category exists
            // =========================

            if (createServiceDto.category_id.HasValue)
            {
                var categoryExists = await _context.categories
                    .AnyAsync(x =>
                        x.id == createServiceDto.category_id.Value);

                if (!categoryExists)
                {
                    throw new InvalidOperationException(
                        "Category not found.");
                }
            }


            // =========================
            // Check duplicate service
            // =========================

            var serviceExists = await _context.services
                .AnyAsync(x =>
                    x.business_id == createServiceDto.business_id &&
                    x.name == createServiceDto.name);

            if (serviceExists)
            {
                throw new InvalidOperationException(
                    "This business already has a service with this name.");
            }


            // =========================
            // Validate duration
            // =========================

            if (createServiceDto.duration_minutes <= 0)
            {
                throw new InvalidOperationException(
                    "Duration must be greater than zero.");
            }


            // =========================
            // Validate price
            // =========================

            if (createServiceDto.price < 0)
            {
                throw new InvalidOperationException(
                    "Price cannot be negative.");
            }


            // =========================
            // DTO -> Entity
            // =========================

            var service = _mapper.Map<service>(
                createServiceDto);


            // =========================
            // Set timestamps
            // =========================

            service.created_at = DateTime.UtcNow;
            service.updated_at = DateTime.UtcNow;


            // =========================
            // Add to database
            // =========================

            await _context.services.AddAsync(service);

            await _context.SaveChangesAsync();


            return service.id;
        }


        // =========================
        // UPDATE
        // =========================

        public async Task<serviceDTO?>
            UpdateServiceAsync(
                long serviceId,
                serviceDTO updateServiceDto)
        {
            // =========================
            // Get tracked entity
            // =========================

            var service = await _context.services
                .FirstOrDefaultAsync(x =>
                    x.id == serviceId);

            if (service == null)
            {
                return null;
            }


            // =========================
            // Check business exists
            // =========================

            var businessExists = await _context.businesses
                .AnyAsync(x =>
                    x.id == updateServiceDto.business_id);

            if (!businessExists)
            {
                throw new InvalidOperationException(
                    "Business not found.");
            }


            // =========================
            // Check category exists
            // =========================

            if (updateServiceDto.category_id.HasValue)
            {
                var categoryExists = await _context.categories
                    .AnyAsync(x =>
                        x.id == updateServiceDto.category_id.Value);

                if (!categoryExists)
                {
                    throw new InvalidOperationException(
                        "Category not found.");
                }
            }


            // =========================
            // Check duplicate service
            // =========================

            var serviceExists = await _context.services
                .AnyAsync(x =>
                    x.business_id == updateServiceDto.business_id &&
                    x.name == updateServiceDto.name &&
                    x.id != serviceId);

            if (serviceExists)
            {
                throw new InvalidOperationException(
                    "This business already has another service with this name.");
            }


            // =========================
            // Validate duration
            // =========================

            if (updateServiceDto.duration_minutes <= 0)
            {
                throw new InvalidOperationException(
                    "Duration must be greater than zero.");
            }


            // =========================
            // Validate price
            // =========================

            if (updateServiceDto.price < 0)
            {
                throw new InvalidOperationException(
                    "Price cannot be negative.");
            }


            // =========================
            // Update Entity
            // =========================

            _mapper.Map(
                updateServiceDto,
                service);


            // =========================
            // Preserve created_at
            // =========================

            service.created_at = service.created_at;


            // =========================
            // Update timestamp
            // =========================

            service.updated_at = DateTime.UtcNow;


            // =========================
            // Save
            // =========================

            await _context.SaveChangesAsync();


            // =========================
            // Entity -> DTO
            // =========================

            return _mapper.Map<serviceDTO>(service);
        }


        // =========================
        // DELETE
        // =========================

        public async Task<bool> DeleteServiceAsync(
            long serviceId)
        {
            var service = await _context.services
                .FirstOrDefaultAsync(x =>
                    x.id == serviceId);

            if (service == null)
            {
                return false;
            }


            _context.services.Remove(service);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}