using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AppointmentBook.Data.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Repositories
{
    public class CategoriesData : ICategoriesService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;


        public CategoriesData(
            ApplicationDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }


        // =========================
        // GET ALL
        // =========================

        public async Task<List<categoriesDTO>>
            GetAllCategoriesAsync()
        {
            var categories = await _context.categories
                .AsNoTracking()
                .ToListAsync();


            return _mapper.Map<List<categoriesDTO>>(
                categories);
        }


        // =========================
        // GET BY ID
        // =========================

        public async Task<categoriesDTO?>
            GetCategoryByIdAsync(
                long categoryId)
        {
            var category = await _context.categories
                .FirstOrDefaultAsync(
                    x => x.id == categoryId);


            if (category == null)
            {
                return null;
            }


            return _mapper.Map<categoriesDTO>(
                category);
        }


        // =========================
        // CREATE
        // =========================

        public async Task<long>
            CreateCategoryAsync(
                categoriesDTO createCategoryDto)
        {
            // Check duplicate name
            var nameExists = await _context.categories
                .AnyAsync(x =>
                    x.name.ToLower() ==
                    createCategoryDto.name.ToLower());


            if (nameExists)
            {
                throw new InvalidOperationException(
                    "A category with this name already exists.");
            }


            // DTO -> Entity
            var category =
                _mapper.Map<category>(
                    createCategoryDto);


            // Add
            await _context.categories.AddAsync(
                category);


            // Save
            await _context.SaveChangesAsync();


            return category.id;
        }


        // =========================
        // UPDATE
        // =========================

        public async Task<categoriesDTO?>
            UpdateCategoryAsync(
                long categoryId,
                categoriesDTO updateCategoryDto)
        {
            // Find existing category
            var category = await _context.categories
                .FirstOrDefaultAsync(
                    x => x.id == categoryId);


            if (category == null)
            {
                return null;
            }


            // Check duplicate name
            var nameExists = await _context.categories
                .AnyAsync(x =>
                    x.name.ToLower() ==
                    updateCategoryDto.name.ToLower()
                    &&
                    x.id != categoryId);


            if (nameExists)
            {
                throw new InvalidOperationException(
                    "Another category with this name already exists.");
            }


            // DTO -> existing Entity
            _mapper.Map(
                updateCategoryDto,
                category);


            // Save
            await _context.SaveChangesAsync();


            // Entity -> DTO
            return _mapper.Map<categoriesDTO>(
                category);
        }


        // =========================
        // DELETE
        // =========================

        public async Task<bool>
            DeleteCategoryAsync(
                long categoryId)
        {
            var category = await _context.categories
                .FirstOrDefaultAsync(
                    x => x.id == categoryId);


            if (category == null)
            {
                return false;
            }


            _context.categories.Remove(category);


            await _context.SaveChangesAsync();


            return true;
        }
    }
}