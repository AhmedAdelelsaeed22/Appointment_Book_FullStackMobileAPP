import 'package:appointmentbook/exceptions/unauthorized_exception.dart';
import 'package:appointmentbook/models/appointment_details_model.dart';
import 'package:appointmentbook/models/appointment_list_model.dart';
import 'package:appointmentbook/models/appointment_model.dart';
import 'package:appointmentbook/repositories/appointment_repository.dart';
import 'package:appointmentbook/services/appointment_api_service.dart';
import 'package:appointmentbook/storage/token_storage.dart';
import 'package:flutter/material.dart';

class UpdateAppointmentScreen extends StatefulWidget {
  final AppointmentListModel appointment;

  const UpdateAppointmentScreen({super.key, required this.appointment});

  @override
  State<UpdateAppointmentScreen> createState() =>
      _UpdateAppointmentScreenState();
}

class _UpdateAppointmentScreenState extends State<UpdateAppointmentScreen> {
  final AppointmentRepository _appointmentRepository = AppointmentRepository(
    AppointmentApiService(),
  );

  final TokenStorage _tokenStorage = TokenStorage();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _notesController = TextEditingController();

  final TextEditingController _reasonController = TextEditingController();

  AppointmentDetailsModel? _appointmentDetails;

  DateTime? _startDatetime;
  DateTime? _endDatetime;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAppointmentDetails();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD EXISTING APPOINTMENT
  // ============================================================

  Future<void> _loadAppointmentDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accessToken = await _tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw const UnauthorizedException();
      }

      final details = await _appointmentRepository.getAppointmentById(
        widget.appointment.id,
        accessToken,
      );

      if (!mounted) return;

      if (details == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Appointment not found.';
        });
        return;
      }

      // Do not allow editing an appointment that is no longer pending.
      if (details.statusName.trim().toLowerCase() != 'pending') {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Only pending appointments can be updated.';
        });
        return;
      }

      setState(() {
        _appointmentDetails = details;

        // Display the dates and times in the user's local timezone.
        _startDatetime = details.startDatetime.toLocal();
        _endDatetime = details.endDatetime.toLocal();

        _notesController.text = details.customerNotes ?? '';

        _isLoading = false;
      });
    } on UnauthorizedException {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Your session has expired. Please log in again.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanError(e);
      });
    }
  }

  // ============================================================
  // SELECT START DATE
  // ============================================================

  Future<void> _selectStartDate() async {
    if (_startDatetime == null) return;

    final now = DateTime.now();
    final current = _startDatetime!;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: current.isBefore(now)
          ? DateTime(now.year, now.month, now.day)
          : current,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2, 12, 31),
      helpText: 'Select appointment date',
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      _startDatetime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _startDatetime!.hour,
        _startDatetime!.minute,
      );

      // Keep the end date aligned with the new start date if needed.
      if (_endDatetime != null && !_endDatetime!.isAfter(_startDatetime!)) {
        _endDatetime = _startDatetime!.add(const Duration(minutes: 30));
      }
    });
  }

  // ============================================================
  // SELECT START TIME
  // ============================================================

  Future<void> _selectStartTime() async {
    if (_startDatetime == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDatetime!),
      helpText: 'Select start time',
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      _startDatetime = DateTime(
        _startDatetime!.year,
        _startDatetime!.month,
        _startDatetime!.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      if (_endDatetime != null && !_endDatetime!.isAfter(_startDatetime!)) {
        _endDatetime = _startDatetime!.add(const Duration(minutes: 30));
      }
    });
  }

  // ============================================================
  // SELECT END DATE
  // ============================================================

  Future<void> _selectEndDate() async {
    if (_endDatetime == null || _startDatetime == null) return;

    final currentEnd = _endDatetime!;
    final start = _startDatetime!;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentEnd.isBefore(start) ? start : currentEnd,
      firstDate: DateTime(start.year, start.month, start.day),
      lastDate: DateTime(start.year + 2, 12, 31),
      helpText: 'Select appointment end date',
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      _endDatetime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        currentEnd.hour,
        currentEnd.minute,
      );
    });
  }

  // ============================================================
  // SELECT END TIME
  // ============================================================

  Future<void> _selectEndTime() async {
    if (_endDatetime == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDatetime!),
      helpText: 'Select end time',
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      _endDatetime = DateTime(
        _endDatetime!.year,
        _endDatetime!.month,
        _endDatetime!.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  // ============================================================
  // VALIDATE AND UPDATE APPOINTMENT
  // ============================================================

  Future<void> _updateAppointment() async {
    if (_isSaving || _appointmentDetails == null) return;

    if (!_formKey.currentState!.validate()) return;

    final start = _startDatetime;
    final end = _endDatetime;

    if (start == null || end == null) {
      _showMessage('Please select the appointment date and time.');
      return;
    }

    if (!start.isAfter(DateTime.now())) {
      _showMessage('The appointment must be in the future.');
      return;
    }

    if (!end.isAfter(start)) {
      _showMessage('End time must be after start time.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final accessToken = await _tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw const UnauthorizedException();
      }

      final details = _appointmentDetails!;

      // Preserve the existing IDs and modify only editable fields.
      final updatedAppointment = AppointmentModel(
        id: details.id,
        businessId: details.businessId,
        customerId: details.customerId,
        serviceId: details.serviceId,
        startDatetime: start,
        endDatetime: end,
        customerNotes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        staffId: details.staffId,
      );

      final reason = _reasonController.text.trim();

      await _appointmentRepository.updateAppointment(
        details.id,
        updatedAppointment,
        accessToken,
        reason: reason.isEmpty ? null : reason,
      );

      if (!mounted) return;

      // true tells MyAppointmentsScreen to reload its list.
      Navigator.pop(context, true);
    } on UnauthorizedException {
      if (!mounted) return;

      _showMessage('Your session has expired. Please log in again.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to update appointment: ${_cleanError(e)}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Update Appointment',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: _buildBody(),
      bottomNavigationBar: _isLoading || _errorMessage != null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _updateAppointment,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'Updating...' : 'Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1264E8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1264E8)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 52,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadAppointmentDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final details = _appointmentDetails!;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _buildBusinessCard(details),
          const SizedBox(height: 24),

          const Text(
            'Appointment Schedule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose a new date and time for your appointment.',
            style: TextStyle(color: Color(0xFF6B7280), height: 1.5),
          ),
          const SizedBox(height: 18),

          _buildDateTimeField(
            label: 'Start date',
            value: _formatDate(_startDatetime!),
            icon: Icons.calendar_month_outlined,
            onTap: _selectStartDate,
          ),
          const SizedBox(height: 12),

          _buildDateTimeField(
            label: 'Start time',
            value: _formatTime(_startDatetime!),
            icon: Icons.access_time_rounded,
            onTap: _selectStartTime,
          ),
          const SizedBox(height: 18),

          _buildDateTimeField(
            label: 'End date',
            value: _formatDate(_endDatetime!),
            icon: Icons.event_available_outlined,
            onTap: _selectEndDate,
          ),
          const SizedBox(height: 12),

          _buildDateTimeField(
            label: 'End time',
            value: _formatTime(_endDatetime!),
            icon: Icons.schedule_rounded,
            onTap: _selectEndTime,
          ),
          const SizedBox(height: 24),

          const Text(
            'Customer Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _notesController,
            maxLines: 4,
            minLines: 3,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Add any notes for your appointment...',
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Update Reason (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _reasonController,
            maxLines: 2,
            maxLength: 300,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Why are you changing this appointment?',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUSINESS / SERVICE SUMMARY
  // ============================================================

  Widget _buildBusinessCard(AppointmentDetailsModel details) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: Color(0xFF1264E8),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.businessName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details.serviceName,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          _summaryRow(
            Icons.person_outline,
            'Staff',
            details.staffName?.isNotEmpty == true
                ? details.staffName!
                : 'Not assigned',
          ),
          const SizedBox(height: 12),
          _summaryRow(Icons.info_outline, 'Status', details.statusName),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 19, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(color: Color(0xFF6B7280))),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE / TIME FIELDS
  // ============================================================

  Widget _buildDateTimeField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isSaving ? null : onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1264E8), size: 23),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: Color(0xFF9CA3AF), size: 19),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FORMATTING / ERRORS
  // ============================================================

  String _formatDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
