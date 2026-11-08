using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Logic
{
    public class AvailableTimeLogic
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

        public TimeOnly available_time { get; set; }


        // =========================
        // DTO
        // =========================

        public AvailableTimeDTO ATDTO
        {
            get
            {
                return new AvailableTimeDTO
                (
                    this.id,
                    this.business_id,
                    this.available_time
                );
            }
        }


        // =========================
        // CONSTRUCTOR
        // =========================

        public AvailableTimeLogic(
            AvailableTimeDTO availableTimeDTO,
            enMode mode = enMode.Insert)
        {
            this.id = availableTimeDTO.id;
            this.business_id = availableTimeDTO.business_id;
            this.available_time = availableTimeDTO.available_time;

            Mode = mode;
        }


        // =========================
        // GET ALL
        // =========================

        public static async Task<List<AvailableTimeDTO>>
            GetAllAvailableTimesAsync(
                IAvailableTimeService availableTimesData, long businessId)
        {
            return await availableTimesData
                .GetAllAvailableTimesAsync(businessId);
        }


        // =========================
        // FIND BY ID
        // =========================

        public static async Task<AvailableTimeLogic?>
            FindAsync(
                IAvailableTimeService availableTimesData,
                long availableTimeId)
        {
            AvailableTimeDTO? availableTimeDTO =
                await availableTimesData
                    .GetAvailableTimeByIdAsync(
                        availableTimeId);

            if (availableTimeDTO == null)
            {
                return null;
            }

            return new AvailableTimeLogic(
                availableTimeDTO,
                enMode.Update);
        }


        // =========================
        // INSERT
        // =========================

        private async Task<bool> InsertNewAvailableTimeAsync(
            IAvailableTimeService availableTimesData)
        {
            long newAvailableTimeId =
                await availableTimesData
                    .CreateAvailableTimeAsync(
                        ATDTO);

            if (newAvailableTimeId == 0)
            {
                return false;
            }

            this.id = newAvailableTimeId;

            return true;
        }


        // =========================
        // UPDATE
        // =========================

        private async Task<bool> UpdateAvailableTimeAsync(
            IAvailableTimeService availableTimesData)
        {
            AvailableTimeDTO? updatedAvailableTime =
                await availableTimesData
                    .UpdateAvailableTimeAsync(
                        ATDTO.id,
                        ATDTO);

            return updatedAvailableTime != null;
        }


        // =========================
        // SAVE
        // =========================

        public async Task<bool> SaveAsync(
            IAvailableTimeService availableTimesData)
        {
            switch (Mode)
            {
                case enMode.Insert:

                    if (await InsertNewAvailableTimeAsync(
                        availableTimesData))
                    {
                        Mode = enMode.Update;

                        return true;
                    }

                    return false;


                case enMode.Update:

                    return await UpdateAvailableTimeAsync(
                        availableTimesData);
            }

            return false;
        }


        // =========================
        // DELETE
        // =========================

        public static async Task<bool>
            DeleteAvailableTimeAsync(
                IAvailableTimeService availableTimesData,
                long availableTimeId)
        {
            return await availableTimesData
                .DeleteAvailableTimeAsync(
                    availableTimeId);
        }
    }
}