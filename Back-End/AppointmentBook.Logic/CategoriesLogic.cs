using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Logic
{
    public class CategoriesLogic
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

        public string name { get; set; } = null!;


        // =========================
        // DTO
        // =========================

        public categoriesDTO CDTO
        {
            get
            {
                return new categoriesDTO(
                    this.id,
                    this.name
                );
            }
        }


        // =========================
        // CONSTRUCTOR
        // =========================

        public CategoriesLogic(
            categoriesDTO categoryDTO,
            enMode mode = enMode.Insert)
        {
            this.id = categoryDTO.id;

            this.name = categoryDTO.name;

            Mode = mode;
        }


        // =========================
        // GET ALL
        // =========================

        public static async Task<List<categoriesDTO>>
            GetAllCategoriesAsync(
                ICategoriesService categoriesData)
        {
            return await categoriesData
                .GetAllCategoriesAsync();
        }


        // =========================
        // FIND BY ID
        // =========================

        public static async Task<CategoriesLogic?>
            FindAsync(
                ICategoriesService categoriesData,
                long categoryId)
        {
            categoriesDTO? categoryDTO =
                await categoriesData
                    .GetCategoryByIdAsync(
                        categoryId);


            if (categoryDTO == null)
            {
                return null;
            }


            return new CategoriesLogic(
                categoryDTO,
                enMode.Update);
        }


        // =========================
        // INSERT
        // =========================

        private async Task<bool>
            InsertNewCategoryAsync(
                ICategoriesService categoriesData)
        {
            long newCategoryId =
                await categoriesData
                    .CreateCategoryAsync(
                        CDTO);


            if (newCategoryId == 0)
            {
                return false;
            }


            this.id = newCategoryId;

            return true;
        }


        // =========================
        // UPDATE
        // =========================

        private async Task<bool>
            UpdateCategoryAsync(
                ICategoriesService categoriesData)
        {
            categoriesDTO? updatedCategory =
                await categoriesData
                    .UpdateCategoryAsync(
                        CDTO.id,
                        CDTO);


            return updatedCategory != null;
        }


        // =========================
        // SAVE
        // =========================

        public async Task<bool>
            SaveAsync(
                ICategoriesService categoriesData)
        {
            switch (Mode)
            {
                case enMode.Insert:

                    if (await InsertNewCategoryAsync(
                        categoriesData))
                    {
                        Mode = enMode.Update;

                        return true;
                    }

                    return false;


                case enMode.Update:

                    return await UpdateCategoryAsync(
                        categoriesData);
            }


            return false;
        }


        // =========================
        // DELETE
        // =========================

        public static async Task<bool>
            DeleteCategoryAsync(
                ICategoriesService categoriesData,
                long categoryId)
        {
            return await categoriesData
                .DeleteCategoryAsync(
                    categoryId);
        }
    }
}