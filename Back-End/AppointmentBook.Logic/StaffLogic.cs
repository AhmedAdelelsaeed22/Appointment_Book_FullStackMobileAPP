using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Logic
{
    public class StaffLogic
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

        public string? job_title { get; set; }

        public bool is_avilable { get; set; }


        // =========================
        // DTO
        // =========================

        public staffDTO StaffDTO
        {
            get
            {
                return new staffDTO(
                    this.id,
                    this.business_id,
                    this.job_title,
                    this.is_avilable
                );
            }
        }


        // =========================
        // CONSTRUCTOR
        // =========================

        public StaffLogic(
            staffDTO staffDTO,
            enMode mode = enMode.Insert)
        {
            this.id = staffDTO.id;
            this.business_id = staffDTO.business_id;
            this.job_title = staffDTO.job_title;
            this.is_avilable = staffDTO.is_avilable;

            Mode = mode;
        }


        // =========================
        // GET ALL
        // =========================

        public static async Task<List<staffDTO>>
            GetAllStaffAsync(
                IStaffService staffData, long businessId)
        {
            return await staffData
                .GetAllStaffAsync(businessId);
        }


        // =========================
        // FIND BY ID
        // =========================

        public static async Task<StaffLogic?>
            FindAsync(
                IStaffService staffData,
                long staffId)
        {
            staffDTO? staffDTO =
                await staffData
                    .GetStaffByIdAsync(staffId);

            if (staffDTO == null)
            {
                return null;
            }

            return new StaffLogic(
                staffDTO,
                enMode.Update);
        }


        // =========================
        // INSERT
        // =========================

        private async Task<bool>
            InsertNewStaffAsync(
                IStaffService staffData)
        {
            long newStaffId =
                await staffData
                    .CreateStaffAsync(StaffDTO);

            if (newStaffId == 0)
            {
                return false;
            }


            // Store generated ID
            this.id = newStaffId;

            return true;
        }


        // =========================
        // UPDATE
        // =========================

        private async Task<bool>
            UpdateStaffAsync(
                IStaffService staffData)
        {
            staffDTO? updatedStaff =
                await staffData
                    .UpdateStaffAsync(
                        this.id,
                        StaffDTO);

            return updatedStaff != null;
        }


        // =========================
        // SAVE
        // =========================

        public async Task<bool> SaveAsync(
            IStaffService staffData)
        {
            switch (Mode)
            {
                case enMode.Insert:

                    if (await InsertNewStaffAsync(
                        staffData))
                    {
                        Mode = enMode.Update;

                        return true;
                    }

                    return false;


                case enMode.Update:

                    return await UpdateStaffAsync(
                        staffData);
            }

            return false;
        }


        // =========================
        // DELETE
        // =========================

        public static async Task<bool>
            DeleteStaffAsync(
                IStaffService staffData,
                long staffId)
        {
            return await staffData
                .DeleteStaffAsync(staffId);
        }
    }
}