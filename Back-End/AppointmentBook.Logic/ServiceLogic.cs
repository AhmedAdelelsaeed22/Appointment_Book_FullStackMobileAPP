using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Logic
{
    public class ServiceLogic
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

        public long business_id { get; set; }

        public long? category_id { get; set; }

        public string name { get; set; } = null!;

        public string? description { get; set; }

        public int duration_minutes { get; set; }

        public decimal price { get; set; }

        public string currency { get; set; } = null!;

        public bool is_available { get; set; }

        public DateTime created_at { get; set; }

        public DateTime updated_at { get; set; }


        // =========================
        // DTO
        // =========================

        public serviceDTO ServiceDTO
        {
            get
            {
                return new serviceDTO(
                    this.id,
                    this.business_id,
                    this.category_id,
                    this.name,
                    this.description,
                    this.duration_minutes,
                    this.price,
                    this.currency,
                    this.is_available,
                    this.created_at,
                    this.updated_at
                );
            }
        }


        // =========================
        // CONSTRUCTOR
        // =========================

        public ServiceLogic(
            serviceDTO serviceDTO,
            enMode mode = enMode.Insert)
        {
            this.id = serviceDTO.id;
            this.business_id = serviceDTO.business_id;
            this.category_id = serviceDTO.category_id;
            this.name = serviceDTO.name;
            this.description = serviceDTO.description;
            this.duration_minutes = serviceDTO.duration_minutes;
            this.price = serviceDTO.price;
            this.currency = serviceDTO.currency;
            this.is_available = serviceDTO.is_available;
            this.created_at = serviceDTO.created_at;
            this.updated_at = serviceDTO.updated_at;

            Mode = mode;
        }


        // =========================
        // GET ALL
        // =========================

        public static async Task<List<serviceDTO>>
            GetAllServicesAsync(
                IServiceService servicesData, long businessId)
        {
            return await servicesData
                .GetAllServicesAsync(businessId);
        }


        // =========================
        // FIND BY ID
        // =========================

        public static async Task<ServiceLogic?>
            FindAsync(
                IServiceService servicesData,
                long serviceId)
        {
            serviceDTO? serviceDTO =
                await servicesData
                    .GetServiceByIdAsync(serviceId);

            if (serviceDTO == null)
            {
                return null;
            }

            return new ServiceLogic(
                serviceDTO,
                enMode.Update);
        }


        // =========================
        // INSERT
        // =========================

        private async Task<bool>
            InsertNewServiceAsync(
                IServiceService servicesData)
        {
            long newServiceId =
                await servicesData
                    .CreateServiceAsync(ServiceDTO);

            if (newServiceId == 0)
            {
                return false;
            }


            // Store generated identity ID
            this.id = newServiceId;

            return true;
        }


        // =========================
        // UPDATE
        // =========================

        private async Task<bool>
            UpdateServiceAsync(
                IServiceService servicesData)
        {
            serviceDTO? updatedService =
                await servicesData
                    .UpdateServiceAsync(
                        this.id,
                        ServiceDTO);

            return updatedService != null;
        }


        // =========================
        // SAVE
        // =========================

        public async Task<bool> SaveAsync(
            IServiceService servicesData)
        {
            switch (Mode)
            {
                case enMode.Insert:

                    if (await InsertNewServiceAsync(
                        servicesData))
                    {
                        Mode = enMode.Update;

                        return true;
                    }

                    return false;


                case enMode.Update:

                    return await UpdateServiceAsync(
                        servicesData);
            }

            return false;
        }


        // =========================
        // DELETE
        // =========================

        public static async Task<bool>
            DeleteServiceAsync(
                IServiceService servicesData,
                long serviceId)
        {
            return await servicesData
                .DeleteServiceAsync(serviceId);
        }
    }
}