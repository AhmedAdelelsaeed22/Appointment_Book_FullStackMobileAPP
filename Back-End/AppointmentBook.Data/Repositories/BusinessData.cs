using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AppointmentBook.Data.Helper;
using AppointmentBook.Data.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Repositories
{
    public class BusinessData : IBusinessService
    {

        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public BusinessData(
            ApplicationDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }



        // =========================
        // GET
        // =========================

        public async Task<List<BusinessWithCategoryDTO>> GetAllBusinessesAsync()
        {
            return await _context.businesses_with_categories
            .AsNoTracking()
            .Select(b => new BusinessWithCategoryDTO
            {
                id = b.id,
                owner_id = b.owner_id,
                name = b.name,
                description = b.description,
                email = b.email,
                phone = b.phone,
                logo_url = b.logo_url,
                timezone = b.timezone,
                is_open = b.is_open,
                category_name = b.category_name,
                rating = b.rating,
                location = b.location
            })
            .ToListAsync();
        }



        public async Task<businessDTO?> GetBusinessByIdAsync(long businessId)
        {
            var business = await _context.businesses
                .FirstOrDefaultAsync(x => x.id == businessId);

            if (business == null)
            {
                return null;
            }

            var businessDto = _mapper.Map<businessDTO>(business);

            return businessDto;
        }


        // =========================
        // CREATE
        // =========================

        public async Task<long> CreateBusinessAsync(
            businessDTO createBusinessDto)
        {
            // Check if email already exists
            var emailExists = await _context.businesses
                .AnyAsync(x => x.email == createBusinessDto.email);

            if (emailExists)
            {
                throw new InvalidOperationException(
                    "A business with this email already exists.");
            }


            if (!Validator.IsValidEmail(createBusinessDto.email))
            {
                throw new InvalidOperationException(
                    "Invalid email format.");
            }

            // DTO -> Entity
            var business = _mapper.Map<business>(createBusinessDto);


            // Add to database
            await _context.businesses.AddAsync(business);

            await _context.SaveChangesAsync();


            return business.id;
        }


        // =========================
        // UPDATE
        // =========================

        public async Task<businessDTO?> UpdateBusinessAsync(
            long businessId,
            businessDTO updateBusinessDto)
        {
            // Get tracked entity
            var business = await _context.businesses
                .FirstOrDefaultAsync(x => x.id == businessId);

            if (business == null)
            {
                return null;
            }


            // Check if another business already uses this email
            var emailExists = await _context.businesses
                .AnyAsync(x =>
                    x.email == updateBusinessDto.email &&
                    x.id != businessId);

            if (emailExists)
            {
                throw new InvalidOperationException(
                    "Another business already uses this email.");
            }

            if (!Validator.IsValidEmail(updateBusinessDto.email))
            {
                throw new InvalidOperationException(
                    "Invalid email format.");
            }


            // Update Entity from DTO
            _mapper.Map(updateBusinessDto, business);

            // Save changes
            await _context.SaveChangesAsync();


            // Entity -> DTO
            var resultDto = _mapper.Map<businessDTO>(business);

            return resultDto;
        }


        // =========================
        // DELETE
        // =========================

        public async Task<bool> DeleteBusinessAsync(long businessId)
        {
            var business = await _context.businesses
                .FirstOrDefaultAsync(x => x.id == businessId);

            if (business == null)
            {
                return false;
            }


            _context.businesses.Remove(business);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}
