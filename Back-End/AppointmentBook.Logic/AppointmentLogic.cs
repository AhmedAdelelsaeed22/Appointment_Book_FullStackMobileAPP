using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;

namespace AppointmentBook.Data.Logic
{
    public class AppointmentLogic
    {
        public enum enMode
        {
            Insert = 0,
            Update = 1
        }

        public enMode Mode { get; private set; }

        public long id { get; set; }
        public long business_id { get; set; }
        public long customer_id { get; set; }
        public long service_id { get; set; }
        public DateTime start_datetime { get; set; }
        public DateTime end_datetime { get; set; }
        public string? customer_notes { get; set; }
        public long staff_id { get; set; }

        public appointmentDTO ADTO
        {
            get
            {
                return new appointmentDTO(
                    id,
                    business_id,
                    customer_id,
                    service_id,
                    start_datetime,
                    end_datetime,
                    customer_notes,
                    staff_id
                );
            }
        }

        // =========================
        // Constructor
        // =========================

        public AppointmentLogic(
            appointmentDTO appointmentDto,
            enMode mode = enMode.Insert)
        {
            this.id = appointmentDto.id;
            this.business_id = appointmentDto.business_id;
            this.customer_id = appointmentDto.customer_id;
            this.service_id = appointmentDto.service_id;
            this.start_datetime = appointmentDto.start_datetime;
            this.end_datetime = appointmentDto.end_datetime;
            this.customer_notes = appointmentDto.customer_notes;
            this.staff_id = appointmentDto.staff_id;

            Mode = mode;
        }

        // =========================
        // GET BY ID
        // =========================

        public static async Task<AppointmentDetailsDTO?>
            GetAppointmentByIdAsync(
                IAppointmentService appointmentService,
                long appointmentId)
        {
            return await appointmentService.GetAppointmentByIdAsync(
                appointmentId);
        }

        // =========================
        // GET ALL BY USER ID
        // =========================

        public static async Task<List<AppointmentListDTO>>
            GetAllAppointmentsByUserIdAsync(
                IAppointmentService appointmentService,
                long userId)
        {
            return await appointmentService
                .GetAllAppointmentsByUserIdAsync(userId);
        }

        // =========================
        // FIND
        // =========================
        // Used when we want to load an
        // appointment into AppointmentLogic
        // for updating.

        public static async Task<AppointmentLogic?>
            FindAsync(
                IAppointmentService appointmentService,
                long appointmentId)
        {
            AppointmentDetailsDTO? details =
                await appointmentService.GetAppointmentByIdAsync(
                    appointmentId);

            if (details == null)
                return null;

            appointmentDTO appointmentDto = new appointmentDTO(
                details.id,
                details.business_id,
                details.customer_id,
                details.service_id,
                details.start_datetime,
                details.end_datetime,
                details.customer_notes,
                details.staff_id
            );

            return new AppointmentLogic(
                appointmentDto,
                enMode.Update);
        }

        // =========================
        // INSERT
        // =========================

        private async Task<bool> InsertNewAppointmentAsync(
            IAppointmentService appointmentService)
        {
            long newAppointmentId =
                await appointmentService.CreateAppointmentAsync(ADTO);

            if (newAppointmentId <= 0)
                return false;

            this.id = newAppointmentId;

            return true;
        }

        // =========================
        // UPDATE
        // =========================

        private async Task<bool> UpdateAppointmentAsync(
            IAppointmentService appointmentService,
            long changedByUserId,
            string? reason)
        {
            return await appointmentService.UpdateAppointmentAsync(
                this.id,
                changedByUserId,
                ADTO,
                reason);
        }

        // =========================
        // SAVE
        // =========================

        public async Task<bool> SaveAsync(
            IAppointmentService appointmentService,
            long changedByUserId,
            string? reason = null)
        {
            switch (Mode)
            {
                case enMode.Insert:

                    if (await InsertNewAppointmentAsync(
                        appointmentService))
                    {
                        Mode = enMode.Update;

                        return true;
                    }

                    return false;

                case enMode.Update:

                    return await UpdateAppointmentAsync(
                        appointmentService,
                        changedByUserId,
                        reason);

                default:

                    return false;
            }
        }

        // =========================
        // CONFIRM
        // =========================

        public static async Task<bool>
            ConfirmAppointmentAsync(
                IAppointmentService appointmentService,
                long appointmentId,
                long changedByUserId,
                string? reason = null)
        {
            return await appointmentService.ConfirmAppointmentAsync(
                appointmentId,
                changedByUserId,
                reason);
        }

        // =========================
        // CANCEL
        // =========================

        public static async Task<bool>
            CancelAppointmentAsync(
                IAppointmentService appointmentService,
                long appointmentId,
                long changedByUserId,
                string reason)
        {
            return await appointmentService.CancelAppointmentAsync(
                appointmentId,
                changedByUserId,
                reason);
        }

        // =========================
        // COMPLETE
        // =========================

        public static async Task<bool>
            CompleteAppointmentAsync(
                IAppointmentService appointmentService,
                long appointmentId,
                long changedByUserId,
                string? reason = null)
        {
            return await appointmentService.CompleteAppointmentAsync(
                appointmentId,
                changedByUserId,
                reason);
        }
    }
}