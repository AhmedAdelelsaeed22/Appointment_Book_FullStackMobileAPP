using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Logic
{
    public class BusinessLogic
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

        public long owner_id { get; set; }

        public string name { get; set; } = null!;

        public string? description { get; set; }

        public string email { get; set; } = null!;

        public string phone { get; set; } = null!;

        public string? logo_url { get; set; }

        public string timezone { get; set; } = null!;

        public bool is_open { get; set; }

        public long service_category_id { get; set; }

        public decimal rating { get; set; }

        public string location { get; set; } = null!;



        public businessDTO BDTO
        {
            get
            {
                return new businessDTO
                (
                    this.id,
                    this.owner_id,
                    this.name,
                    this.description,
                    this.email,
                    this.phone,
                    this.logo_url,
                    this.timezone,
                    this.is_open,
                    this.service_category_id,
                    this.rating,
                    this.location
                );
            }
        }


        // =========================
        // CONSTRUCTOR
        // =========================

        public BusinessLogic(
            businessDTO businessDTO,
            enMode mode = enMode.Insert)
        {

            this.id = businessDTO.id;
            this.owner_id = businessDTO.owner_id;
            this.name = businessDTO.name;
            this.description = businessDTO.description;
            this.email = businessDTO.email;
            this.phone = businessDTO.phone;
            this.logo_url = businessDTO.logo_url;
            this.timezone = businessDTO.timezone;
            this.is_open = businessDTO.is_open;
            this.service_category_id = businessDTO.service_category_id;
            this.rating = businessDTO.rating;
            this.location = businessDTO.location;


            Mode = mode;
        }


        // =========================
        // GET ALL
        // =========================

        public static async Task<List<BusinessWithCategoryDTO>> GetAllBusinessesAsync(
            IBusinessService businessesData)
        {
            return await businessesData.GetAllBusinessesAsync();
        }






        // =========================
        // FIND BY ID
        // =========================

        public static async Task<BusinessLogic?> FindAsync(
            IBusinessService businessesData,
            long businessId)
        {
            businessDTO? businessDTO =
                await businessesData.GetBusinessByIdAsync(businessId);

            if (businessDTO == null)
            {
                return null;
            }

            return new BusinessLogic(
                businessDTO,
                enMode.Update);
        }


        // =========================
        // INSERT
        // =========================

        private async Task<bool> InsertNewBusinessAsync(IBusinessService businessesData)
        {
            long newBusinessId =
                await businessesData.CreateBusinessAsync(BDTO);

            if (newBusinessId == 0)
            {
                return false;
            }

            return true;
        }





        // =========================
        // UPDATE
        // =========================

        private async Task<bool> UpdateBusinessAsync(IBusinessService businessesData)
        {
            businessDTO? updatedBusiness =
                await businessesData.UpdateBusinessAsync(
                    BDTO.id,
                    BDTO);

            return updatedBusiness != null;
        }


        // =========================
        // SAVE
        // =========================

        public async Task<bool> SaveAsync(IBusinessService businessesData)
        {
            switch (Mode)
            {
                case enMode.Insert:

                    if (await InsertNewBusinessAsync(businessesData))
                    {
                        Mode = enMode.Update;

                        return true;
                    }

                    return false;


                case enMode.Update:

                    return await UpdateBusinessAsync(businessesData);
            }

            return false;
        }


        // =========================
        // DELETE
        // =========================

        public static async Task<bool> DeleteBusinessAsync(
            IBusinessService businessesData,
            long businessId)
        {
            return await businessesData.DeleteBusinessAsync(businessId);
        }
    }
}
