using AppointmentBook.Data.Data;
using AppointmentBook.Data.Dto;
using AppointmentBook.Data.Entities;
using AppointmentBook.Data.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AppointmentBook.Data.Repositories
{
    public class AuditLogsData : IAuditLogsService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public AuditLogsData(
            ApplicationDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }


        public async Task<AuditLogsDTO?> GetAuditLogByIdAsync(long auditLogId)
        {
            var auditLog = await _context.audit_logs
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.id == auditLogId);

            if (auditLog == null)
            {
                return null;
            }

            var auditLogDto = _mapper.Map<AuditLogsDTO>(auditLog);

            return auditLogDto;
        }

        public async Task<long> CreateAuditLogAsync(
            AuditLogsDTO createAuditLogDto)
        {
            // DTO -> Entity
            var auditLog = _mapper.Map<audit_log>(createAuditLogDto);


            // Add to database
            await _context.audit_logs.AddAsync(auditLog);

            await _context.SaveChangesAsync();


            return auditLog.id;
        }

    }
}
