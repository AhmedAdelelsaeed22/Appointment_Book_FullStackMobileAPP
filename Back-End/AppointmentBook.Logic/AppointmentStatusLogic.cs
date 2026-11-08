using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Logic
{
    public class AppointmentStatusLogic
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

        public string? description { get; set; }


        // =========================
        // DTO
        // =========================

        public appointmentStatusDTO StatusDTO
        {
            get
            {
                return new appointmentStatusDTO(
                    this.id,
                    this.name,
                    this.description
                );
            }
        }


        // =========================
        // CONSTRUCTOR
        // =========================

        public AppointmentStatusLogic(
            appointmentStatusDTO appointmentStatusDTO,
            enMode mode = enMode.Insert)
        {
            this.id = appointmentStatusDTO.id;
            this.name = appointmentStatusDTO.name;
            this.description = appointmentStatusDTO.description;

            Mode = mode;
        }


        // =========================
        // GET ALL
        // =========================

        public static async Task<List<appointmentStatusDTO>>
            GetAllAppointmentStatusesAsync(
                IAppointmentStatusService appointmentStatusData)
        {
            return await appointmentStatusData
                .GetAllAppointmentStatusesAsync();
        }


        // =========================
        // FIND BY ID
        // =========================

        public static async Task<AppointmentStatusLogic?>
            FindAsync(
                IAppointmentStatusService appointmentStatusData,
                long statusId)
        {
            appointmentStatusDTO? statusDTO =
                await appointmentStatusData
                    .GetAppointmentStatusByIdAsync(statusId);

            if (statusDTO == null)
            {
                return null;
            }

            return new AppointmentStatusLogic(
                statusDTO,
                enMode.Update);
        }


        // =========================
        // INSERT
        // =========================

        private async Task<bool> InsertNewAppointmentStatusAsync(
            IAppointmentStatusService appointmentStatusData)
        {
            long newStatusId =
                await appointmentStatusData
                    .CreateAppointmentStatusAsync(StatusDTO);

            if (newStatusId == 0)
            {
                return false;
            }


            // Important:
            // Put generated database ID into Logic object
            this.id = newStatusId;

            return true;
        }


        // =========================
        // UPDATE
        // =========================

        private async Task<bool> UpdateAppointmentStatusAsync(
            IAppointmentStatusService appointmentStatusData)
        {
            appointmentStatusDTO? updatedStatus =
                await appointmentStatusData
                    .UpdateAppointmentStatusAsync(
                        this.id,
                        StatusDTO);

            return updatedStatus != null;
        }


        // =========================
        // SAVE
        // =========================

        public async Task<bool> SaveAsync(
            IAppointmentStatusService appointmentStatusData)
        {
            switch (Mode)
            {
                case enMode.Insert:

                    if (await InsertNewAppointmentStatusAsync(
                        appointmentStatusData))
                    {
                        Mode = enMode.Update;

                        return true;
                    }

                    return false;


                case enMode.Update:

                    return await UpdateAppointmentStatusAsync(
                        appointmentStatusData);
            }

            return false;
        }


        // =========================
        // DELETE
        // =========================

        public static async Task<bool> DeleteAppointmentStatusAsync(
            IAppointmentStatusService appointmentStatusData,
            long statusId)
        {
            return await appointmentStatusData
                .DeleteAppointmentStatusAsync(statusId);
        }
    }
}