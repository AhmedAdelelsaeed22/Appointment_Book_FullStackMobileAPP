import 'package:appointmentbook/exceptions/unauthorized_exception.dart';
import 'package:appointmentbook/models/appointment_model.dart';
import 'package:appointmentbook/models/appointment_details_model.dart';
import 'package:appointmentbook/models/available_time_model.dart';
import 'package:appointmentbook/models/business_with_category_model.dart';
import 'package:appointmentbook/models/service_model.dart';
import 'package:appointmentbook/models/staff_model.dart';
import 'package:appointmentbook/repositories/appointment_repository.dart';
import 'package:appointmentbook/repositories/available_time_repository.dart';
import 'package:appointmentbook/repositories/service_repository.dart';
import 'package:appointmentbook/repositories/staff_repository.dart';
import 'package:appointmentbook/screens/service_details_screen.dart';
import 'package:appointmentbook/services/appointment_api_service.dart';
import 'package:appointmentbook/services/available_time_api_service.dart';
import 'package:appointmentbook/services/service_api_service.dart';
import 'package:appointmentbook/services/staff_api_service.dart';
import 'package:appointmentbook/storage/token_storage.dart';
import 'package:flutter/material.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final BusinessWithCategoryModel business;
  final int customerId;

  const CreateAppointmentScreen({
    super.key,
    required this.business,
    required this.customerId,
  });

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  // ================================================================
  // REPOSITORIES
  // ================================================================

  final ServiceRepository _serviceRepository = ServiceRepository(
    ServiceApiService(),
  );

  final StaffRepository _staffRepository = StaffRepository(StaffApiService());

  final AvailableTimeRepository _availableTimeRepository =
      AvailableTimeRepository(AvailableTimeApiService());

  final AppointmentRepository _appointmentRepository = AppointmentRepository(
    AppointmentApiService(),
  );

  final TokenStorage _tokenStorage = TokenStorage();

  // ================================================================
  // DATA
  // ================================================================

  List<ServiceModel> _services = [];
  List<StaffModel> _staff = [];
  List<AvailableTimeModel> _availableTimes = [];

  // ================================================================
  // SELECTIONS
  // ================================================================

  int? _selectedServiceId;
  int? _selectedStaffId;

  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  // ================================================================
  // CONTROLLERS
  // ================================================================

  final TextEditingController _notesController = TextEditingController();

  // ================================================================
  // LOADING / ERROR
  // ================================================================

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAppointmentData();
  }

  // ================================================================
  // LOAD DATA
  // ================================================================

  Future<void> _loadAppointmentData() async {
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

      final businessId = widget.business.id;

      final services = await _serviceRepository.getAllServices(
        businessId,
        accessToken,
      );

      final staff = await _staffRepository.getAllStaff(businessId, accessToken);

      final availableTimes = await _availableTimeRepository
          .getAllAvailableTimes(businessId, accessToken);

      if (!mounted) return;

      setState(() {
        _services = services;
        _staff = staff;
        _availableTimes = availableTimes;
        _isLoading = false;
      });
    } on UnauthorizedException {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Your session has expired. Please login again.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ================================================================
  // SELECTED OBJECTS
  // ================================================================

  ServiceModel? get _selectedService {
    for (final service in _services) {
      if (service.id == _selectedServiceId) {
        return service;
      }
    }
    return null;
  }

  StaffModel? get _selectedStaff {
    for (final staff in _staff) {
      if (staff.id == _selectedStaffId) {
        return staff;
      }
    }
    return null;
  }

  // ================================================================
  // CREATE APPOINTMENT
  // ================================================================

  Future<void> _createAppointment() async {
    if (_isSubmitting) return;

    final service = _selectedService;
    final staff = _selectedStaff;
    final selectedTime = _selectedTime;

    if (service == null || staff == null || selectedTime == null) {
      _showMessage('Please select a service, staff member, and time.');
      return;
    }

    // Convert the selected time into a DateTime on the selected date.
    final timeParts = selectedTime.split(':');

    if (timeParts.length < 2) {
      _showMessage('The selected appointment time is invalid.');
      return;
    }

    late final DateTime startDatetime;

    try {
      startDatetime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (_) {
      _showMessage('Unable to interpret the selected appointment time.');
      return;
    }

    // Use the selected service's duration to calculate the end time.
    final endDatetime = startDatetime.add(
      Duration(minutes: service.durationMinutes),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final accessToken = await _tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw const UnauthorizedException();
      }

      final appointment = AppointmentModel(
        id: 0,
        businessId: widget.business.id,
        customerId: widget.customerId,
        serviceId: service.id,
        startDatetime: startDatetime,
        endDatetime: endDatetime,
        customerNotes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        staffId: staff.id,
      );

      final AppointmentDetailsModel result = await _appointmentRepository
          .createAppointment(appointment, accessToken);

      if (!mounted) return;

      Navigator.pop<AppointmentDetailsModel>(context, result);
      // _showMessage('The Create Appointment Is Successfully!');
    } on UnauthorizedException {
      if (!mounted) return;

      _showMessage('Your session has expired. Please login again.');
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to create appointment: '
        '${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ================================================================
  // CONFIRMATION DIALOG
  // ================================================================

  Future<void> _showConfirmationDialog() async {
    if (_selectedService == null ||
        _selectedStaff == null ||
        _selectedTime == null ||
        _isSubmitting) {
      _showMessage('Please select a service, staff member, and time.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Appointment'),
          content: const Text(
            'Are you sure you want to book this appointment?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _createAppointment();
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState(context)
          : _buildAppointmentContent(context),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 55, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Unable to load appointment data',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAppointmentData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // APPOINTMENT CONTENT
  // ================================================================

  Widget _buildAppointmentContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBusinessHeader(context),
          const SizedBox(height: 28),

          _buildSectionTitle(
            context,
            'Select Service',
            'Choose a service to continue.',
          ),
          const SizedBox(height: 14),
          _buildServices(context),
          const SizedBox(height: 28),

          _buildSectionTitle(
            context,
            'Select Staff',
            'Choose your preferred staff member.',
          ),
          const SizedBox(height: 14),
          _buildStaff(context),
          const SizedBox(height: 28),

          _buildSectionTitle(
            context,
            'Select Date',
            'Choose a convenient date for your appointment.',
          ),
          const SizedBox(height: 14),
          _buildDateSelector(context),
          const SizedBox(height: 28),

          _buildSectionTitle(
            context,
            'Select Time',
            'Available appointment times.',
          ),
          const SizedBox(height: 14),
          _buildTimeSelector(context),
          const SizedBox(height: 28),

          _buildSectionTitle(
            context,
            'Additional Notes',
            'Add anything you want the business to know.',
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notesController,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'Example: I have a previous medical report...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 30),

          _buildSummary(context),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _isSubmitting ||
                      _selectedServiceId == null ||
                      _selectedStaffId == null ||
                      _selectedTime == null
                  ? null
                  : _showConfirmationDialog,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm Appointment'),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // BUSINESS HEADER
  // ================================================================

  Widget _buildBusinessHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                widget.business.logoUrl != null &&
                    widget.business.logoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      widget.business.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.business_outlined,
                        color: Color(0xFF1264E8),
                        size: 30,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.business_outlined,
                    color: Color(0xFF1264E8),
                    size: 30,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.business.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.business.categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB020),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.business.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (widget.business.location.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF6B7280),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.business.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SECTION TITLE
  // ================================================================

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  // ================================================================
  // SERVICES
  // ================================================================

  Widget _buildServices(BuildContext context) {
    if (_services.isEmpty) {
      return _buildEmptyMessage(
        context,
        Icons.medical_services_outlined,
        'No services available',
      );
    }

    return Column(
      children: _services.map((service) {
        final selected = _selectedServiceId == service.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: service.isAvailable
                ? () {
                    setState(() {
                      _selectedServiceId = service.id;
                    });
                  }
                : null,
            child: Opacity(
              opacity: service.isAvailable ? 1.0 : 0.55,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF1264E8)
                        : const Color(0xFFE5E7EB),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        Icons.medical_services_outlined,
                        color: selected
                            ? const Color(0xFF1264E8)
                            : const Color(0xFF374151),
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  service.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              if (!service.isAvailable)
                                const Text(
                                  'Unavailable',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${service.durationMinutes} min • '
                            '${service.price.toStringAsFixed(0)} '
                            '${service.currency}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 17,
                        color: Color(0xFF9CA3AF),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ServiceDetailsScreen(service: service),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================================================================
  // STAFF
  // ================================================================

  Widget _buildStaff(BuildContext context) {
    if (_staff.isEmpty) {
      return _buildEmptyMessage(
        context,
        Icons.people_outline,
        'No staff available',
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _staff.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final staff = _staff[index];
          final selected = _selectedStaffId == staff.id;

          return GestureDetector(
            onTap: staff.isAvilable
                ? () {
                    setState(() {
                      _selectedStaffId = staff.id;
                    });
                  }
                : null,
            child: Opacity(
              opacity: staff.isAvilable ? 1.0 : 0.55,
              child: Container(
                width: 210,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF1264E8)
                        : const Color(0xFFE5E7EB),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF1264E8),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.jobTitle?.isNotEmpty == true
                                ? staff.jobTitle!
                                : 'Staff Member',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            staff.isAvilable ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              fontSize: 12,
                              color: staff.isAvilable
                                  ? const Color(0xFF16A34A)
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================================================================
  // DATE SELECTOR
  // ================================================================

  Widget _buildDateSelector(BuildContext context) {
    final today = DateTime.now();

    return SizedBox(
      height: 92,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime(today.year, today.month, today.day + index);

          final selected =
              date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _selectedTime = null;
              });
            },
            child: Container(
              width: 68,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF1264E8) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF1264E8)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date.weekday),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================================================================
  // TIME SELECTOR
  // ================================================================

  Widget _buildTimeSelector(BuildContext context) {
    if (_availableTimes.isEmpty) {
      return _buildEmptyMessage(
        context,
        Icons.access_time_outlined,
        'No available times',
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableTimes.map((time) {
        final selected = _selectedTime == time.availableTime;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTime = time.availableTime;
            });
          },
          child: Container(
            width: 105,
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF1264E8) : Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: selected
                    ? const Color(0xFF1264E8)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(
              _formatTime(time.availableTime),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================================================================
  // EMPTY MESSAGE
  // ================================================================

  Widget _buildEmptyMessage(
    BuildContext context,
    IconData icon,
    String message,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  // ================================================================
  // SUMMARY
  // ================================================================

  Widget _buildSummary(BuildContext context) {
    final service = _selectedService;
    final staff = _selectedStaff;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Summary',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _summaryRow(context, 'Service', service?.name ?? 'Not selected'),
          const SizedBox(height: 10),
          _summaryRow(
            context,
            'Staff',
            staff?.jobTitle ??
                (staff == null ? 'Not selected' : 'Staff Member'),
          ),
          const SizedBox(height: 10),
          _summaryRow(context, 'Date', _formatDate(_selectedDate)),
          const SizedBox(height: 10),
          _summaryRow(
            context,
            'Time',
            _selectedTime == null
                ? 'Not selected'
                : _formatTime(_selectedTime!),
          ),
          if (service != null) ...[
            const SizedBox(height: 10),
            _summaryRow(
              context,
              'Duration',
              '${service.durationMinutes} minutes',
            ),
            const SizedBox(height: 10),
            _summaryRow(
              context,
              'Price',
              '${service.price.toStringAsFixed(0)} ${service.currency}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        const SizedBox(width: 15),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // DATE / TIME HELPERS
  // ================================================================

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');

      if (parts.length < 2) return time;

      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';

      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time;
    }
  }
}
