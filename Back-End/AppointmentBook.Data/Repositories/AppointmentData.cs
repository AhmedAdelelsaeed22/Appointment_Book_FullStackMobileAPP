using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using NpgsqlTypes;

namespace AppointmentBook.Data.Repositories
{
    public class AppointmentData : IAppointmentService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public AppointmentData(
            ApplicationDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }


        // =========================
        // GET APPOINTMENT BY ID
        // =========================

        public async Task<AppointmentDetailsDTO?> GetAppointmentByIdAsync(
            long appointmentId)
        {
            var connection = _context.Database.GetDbConnection();

            await connection.OpenAsync();

            try
            {
                await using var command = connection.CreateCommand();

                command.CommandText = @"
                    SELECT *
                    FROM booking.get_appointment_by_id(@p_appointment_id);
                ";

                var parameter = command.CreateParameter();

                parameter.ParameterName = "p_appointment_id";
                parameter.Value = appointmentId;
                parameter.DbType = System.Data.DbType.Int64;

                command.Parameters.Add(parameter);


                await using var reader = await command.ExecuteReaderAsync();

                if (!await reader.ReadAsync())
                {
                    return null;
                }


                return new AppointmentDetailsDTO(
                    reader.GetInt64(reader.GetOrdinal("id")),

                    reader.GetInt64(reader.GetOrdinal("business_id")),
                    reader.GetString(reader.GetOrdinal("business_name")),

                    reader.GetInt64(reader.GetOrdinal("customer_id")),
                    reader.GetString(reader.GetOrdinal("customer_name")),

                    reader.GetInt64(reader.GetOrdinal("service_id")),
                    reader.GetString(reader.GetOrdinal("service_name")),

                    reader.GetInt64(reader.GetOrdinal("status_id")),
                    reader.GetString(reader.GetOrdinal("status_name")),

                    reader.GetDateTime(reader.GetOrdinal("start_datetime")),
                    reader.GetDateTime(reader.GetOrdinal("end_datetime")),

                    reader.IsDBNull(reader.GetOrdinal("customer_notes"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("customer_notes")),

                    reader.GetDateTime(reader.GetOrdinal("created_at")),
                    reader.GetDateTime(reader.GetOrdinal("updated_at")),

                    reader.IsDBNull(reader.GetOrdinal("cancelled_at"))
                        ? null
                        : reader.GetDateTime(reader.GetOrdinal("cancelled_at")),

                    reader.IsDBNull(reader.GetOrdinal("completed_at"))
                        ? null
                        : reader.GetDateTime(reader.GetOrdinal("completed_at")),

                    reader.GetInt64(reader.GetOrdinal("staff_id")),

                    reader.IsDBNull(reader.GetOrdinal("staff_name"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("staff_name"))
                );
            }
            finally
            {
                await connection.CloseAsync();
            }
        }


        // =========================
        // GET ALL BY USER ID
        // =========================

        public async Task<List<AppointmentListDTO>> GetAllAppointmentsByUserIdAsync(
            long userId)
        {
            var appointments = new List<AppointmentListDTO>();

            var connection = _context.Database.GetDbConnection();

            await connection.OpenAsync();

            try
            {
                await using var command = connection.CreateCommand();

                command.CommandText = @"
                    SELECT *
                    FROM booking.get_all_appointments_by_user_id(@p_user_id);
                ";

                var parameter = command.CreateParameter();

                parameter.ParameterName = "p_user_id";
                parameter.Value = userId;
                parameter.DbType = System.Data.DbType.Int64;

                command.Parameters.Add(parameter);


                await using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    var appointment = new AppointmentListDTO(
                        reader.GetInt64(reader.GetOrdinal("id")),

                        reader.GetInt64(reader.GetOrdinal("business_id")),
                        reader.GetString(reader.GetOrdinal("business_name")),

                        reader.GetInt64(reader.GetOrdinal("customer_id")),
                        reader.GetString(reader.GetOrdinal("customer_name")),

                        reader.GetInt64(reader.GetOrdinal("service_id")),
                        reader.GetString(reader.GetOrdinal("service_name")),

                        reader.GetInt64(reader.GetOrdinal("status_id")),
                        reader.GetString(reader.GetOrdinal("status_name")),

                        reader.GetDateTime(reader.GetOrdinal("start_datetime")),
                        reader.GetDateTime(reader.GetOrdinal("end_datetime")),

                        reader.IsDBNull(reader.GetOrdinal("customer_notes"))
                            ? null
                            : reader.GetString(reader.GetOrdinal("customer_notes")),

                        reader.GetDateTime(reader.GetOrdinal("created_at")),
                        reader.GetDateTime(reader.GetOrdinal("updated_at")),

                        reader.IsDBNull(reader.GetOrdinal("cancelled_at"))
                            ? null
                            : reader.GetDateTime(reader.GetOrdinal("cancelled_at")),

                        reader.IsDBNull(reader.GetOrdinal("completed_at"))
                            ? null
                            : reader.GetDateTime(reader.GetOrdinal("completed_at")),

                        reader.GetInt64(reader.GetOrdinal("staff_id")),

                        reader.IsDBNull(reader.GetOrdinal("staff_name"))
                            ? null
                            : reader.GetString(reader.GetOrdinal("staff_name"))
                    );

                    appointments.Add(appointment);
                }

                return appointments;
            }
            finally
            {
                await connection.CloseAsync();
            }
        }


        // =========================
        // CREATE
        // =========================

        public async Task<long> CreateAppointmentAsync(
            appointmentDTO createAppointmentDto)
        {
            var connection = _context.Database.GetDbConnection();

            await connection.OpenAsync();

            try
            {
                await using var command = connection.CreateCommand();

                command.CommandText = @"
                    SELECT booking.create_appointment(
                        @p_business_id,
                        @p_customer_id,
                        @p_service_id,
                        @p_start_datetime,
                        @p_end_datetime,
                        @p_customer_notes,
                        @p_staff_id
                    );
                ";


                command.Parameters.Add(new NpgsqlParameter(
                    "p_business_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = createAppointmentDto.business_id
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_customer_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = createAppointmentDto.customer_id
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_service_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = createAppointmentDto.service_id
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_start_datetime",
                    NpgsqlDbType.TimestampTz)
                {
                    Value = createAppointmentDto.start_datetime
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_end_datetime",
                    NpgsqlDbType.TimestampTz)
                {
                    Value = createAppointmentDto.end_datetime
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_customer_notes",
                    NpgsqlDbType.Text)
                {
                    Value = (object?)createAppointmentDto.customer_notes
                        ?? DBNull.Value
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_staff_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = createAppointmentDto.staff_id
                });


                var result = await command.ExecuteScalarAsync();

                return Convert.ToInt64(result);
            }
            finally
            {
                await connection.CloseAsync();
            }
        }


        // =========================
        // UPDATE
        // =========================

        public async Task<bool> UpdateAppointmentAsync(
            long appointmentId,
            long changedByUserId,
            appointmentDTO updateAppointmentDto,
            string? reason)
        {
            var connection = _context.Database.GetDbConnection();

            await connection.OpenAsync();

            try
            {
                await using var command = connection.CreateCommand();

                command.CommandText = @"
                    CALL booking.update_appointment(
                        @p_appointment_id,
                        @p_changed_by_user_id,
                        @p_service_id,
                        @p_start_datetime,
                        @p_end_datetime,
                        @p_customer_notes,
                        @p_staff_id,
                        @p_reason
                    );
                ";


                command.Parameters.Add(new NpgsqlParameter(
                    "p_appointment_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = appointmentId
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_changed_by_user_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = changedByUserId
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_service_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = updateAppointmentDto.service_id
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_start_datetime",
                    NpgsqlDbType.TimestampTz)
                {
                    Value = updateAppointmentDto.start_datetime
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_end_datetime",
                    NpgsqlDbType.TimestampTz)
                {
                    Value = updateAppointmentDto.end_datetime
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_customer_notes",
                    NpgsqlDbType.Text)
                {
                    Value = (object?)updateAppointmentDto.customer_notes
                        ?? DBNull.Value
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_staff_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = updateAppointmentDto.staff_id
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_reason",
                    NpgsqlDbType.Text)
                {
                    Value = (object?)reason
                        ?? DBNull.Value
                });


                await command.ExecuteNonQueryAsync();

                return true;
            }
            finally
            {
                await connection.CloseAsync();
            }
        }


        // =========================
        // CONFIRM
        // =========================

        public async Task<bool> ConfirmAppointmentAsync(
            long appointmentId,
            long changedByUserId,
            string? reason)
        {
            var connection = _context.Database.GetDbConnection();

            await connection.OpenAsync();

            try
            {
                await using var command = connection.CreateCommand();

                command.CommandText = @"
                    CALL booking.confirm_appointment(
                        @p_appointment_id,
                        @p_changed_by_user_id,
                        @p_reason
                    );
                ";


                command.Parameters.Add(new NpgsqlParameter(
                    "p_appointment_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = appointmentId
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_changed_by_user_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = changedByUserId
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_reason",
                    NpgsqlDbType.Text)
                {
                    Value = (object?)reason
                        ?? DBNull.Value
                });


                await command.ExecuteNonQueryAsync();

                return true;
            }
            finally
            {
                await connection.CloseAsync();
            }
        }


        // =========================
        // CANCEL
        // =========================

        public async Task<bool> CancelAppointmentAsync(
            long appointmentId,
            long changedByUserId,
            string reason)
        {
            var connection = _context.Database.GetDbConnection();

            await connection.OpenAsync();

            try
            {
                await using var command = connection.CreateCommand();

                command.CommandText = @"
                    CALL booking.cancel_appointment(
                        @p_appointment_id,
                        @p_changed_by_user_id,
                        @p_reason
                    );
                ";


                command.Parameters.Add(new NpgsqlParameter(
                    "p_appointment_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = appointmentId
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_changed_by_user_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = changedByUserId
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_reason",
                    NpgsqlDbType.Text)
                {
                    Value = reason
                });


                await command.ExecuteNonQueryAsync();

                return true;
            }
            finally
            {
                await connection.CloseAsync();
            }
        }


        // =========================
        // COMPLETE
        // =========================

        public async Task<bool> CompleteAppointmentAsync(
            long appointmentId,
            long changedByUserId,
            string? reason)
        {
            var connection = _context.Database.GetDbConnection();

            await connection.OpenAsync();

            try
            {
                await using var command = connection.CreateCommand();

                command.CommandText = @"
                    CALL booking.complete_appointment(
                        @p_appointment_id,
                        @p_changed_by_user_id,
                        @p_reason
                    );
                ";


                command.Parameters.Add(new NpgsqlParameter(
                    "p_appointment_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = appointmentId
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_changed_by_user_id",
                    NpgsqlDbType.Bigint)
                {
                    Value = changedByUserId
                });

                command.Parameters.Add(new NpgsqlParameter(
                    "p_reason",
                    NpgsqlDbType.Text)
                {
                    Value = (object?)reason
                        ?? DBNull.Value
                });


                await command.ExecuteNonQueryAsync();

                return true;
            }
            finally
            {
                await connection.CloseAsync();
            }
        }
    }
}