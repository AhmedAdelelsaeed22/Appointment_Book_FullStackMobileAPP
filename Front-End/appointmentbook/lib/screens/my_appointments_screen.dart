import 'package:appointmentbook/exceptions/unauthorized_exception.dart';
import 'package:appointmentbook/models/appointment_details_model.dart';
import 'package:appointmentbook/models/appointment_list_model.dart';
import 'package:appointmentbook/repositories/appointment_repository.dart';
import 'package:appointmentbook/screens/update_appointment_screen.dart';
import 'package:appointmentbook/services/appointment_api_service.dart';
import 'package:appointmentbook/storage/token_storage.dart';
import 'package:flutter/material.dart';

class MyAppointmentsScreen extends StatefulWidget {
  final int userId;

  const MyAppointmentsScreen({super.key, required this.userId});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  // ================================================================
  // REPOSITORY
  // ================================================================

  final AppointmentRepository _appointmentRepository = AppointmentRepository(
    AppointmentApiService(),
  );

  final reasonController = TextEditingController();
  final TokenStorage _tokenStorage = TokenStorage();

  // ================================================================
  // DATA
  // ================================================================

  List<AppointmentListModel> _appointments = [];

  // all, upcoming, completed, cancelled
  String _selectedFilter = 'all';

  // ================================================================
  // STATES
  // ================================================================

  bool _isLoading = true;
  String? _errorMessage;

  int? _cancellingAppointmentId;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  // ================================================================
  // LOAD APPOINTMENTS
  // ================================================================

  Future<void> _loadAppointments({bool showLoading = true}) async {
    if (!mounted) return;

    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final accessToken = await _tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw const UnauthorizedException();
      }

      final appointments = await _appointmentRepository
          .getAllAppointmentsByUserId(widget.userId, accessToken);

      if (!mounted) return;

      setState(() {
        _appointments = appointments;
        _isLoading = false;
        _errorMessage = null;
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

  // ================================================================
  // FILTER APPOINTMENTS
  // ================================================================

  List<AppointmentListModel> get _filteredAppointments {
    final now = DateTime.now();

    final filtered = _appointments.where((appointment) {
      switch (_selectedFilter) {
        case 'upcoming':
          return _isUpcoming(appointment, now);

        case 'completed':
          return _isCompleted(appointment);

        case 'cancelled':
          return _isCancelled(appointment);

        case 'all':
        default:
          return true;
      }
    }).toList();

    filtered.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));

    if (_selectedFilter == 'completed' || _selectedFilter == 'cancelled') {
      filtered.sort((a, b) => b.startDatetime.compareTo(a.startDatetime));
    }

    return filtered;
  }

  bool _isCancelled(AppointmentListModel appointment) {
    final status = appointment.statusName.toLowerCase();

    return status.contains('cancel') || appointment.cancelledAt != null;
  }

  bool _isCompleted(AppointmentListModel appointment) {
    final status = appointment.statusName.toLowerCase();

    return status.contains('completed') ||
        status.contains('complete') ||
        appointment.completedAt != null;
  }

  bool _isUpcoming(AppointmentListModel appointment, DateTime now) {
    return !_isCancelled(appointment) &&
        !_isCompleted(appointment) &&
        appointment.startDatetime.toLocal().isAfter(now);
  }

  bool _canCancel(AppointmentListModel appointment) {
    final status = appointment.statusName.toLowerCase();

    // Only allow cancellation of future appointments that have
    // not already been cancelled or completed.
    final isPendingOrConfirmed =
        status.contains('pending') ||
        status.contains('confirm') ||
        status.contains('scheduled');

    return _isUpcoming(appointment, DateTime.now()) && isPendingOrConfirmed;
  }

  bool _canUpdate(AppointmentListModel appointment) {
    return appointment.statusName.trim().toLowerCase() == 'pending';
  }

  int _countForFilter(String filter) {
    final now = DateTime.now();

    switch (filter) {
      case 'upcoming':
        return _appointments.where((a) => _isUpcoming(a, now)).length;
      case 'completed':
        return _appointments.where(_isCompleted).length;
      case 'cancelled':
        return _appointments.where(_isCancelled).length;
      default:
        return _appointments.length;
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh appointments',
            onPressed: _isLoading ? null : () => _loadAppointments(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1264E8)),
      );
    }

    if (_errorMessage != null && _appointments.isEmpty) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: const Color(0xFF1264E8),
      onRefresh: () => _loadAppointments(showLoading: false),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: _buildHeader(),
            ),
          ),
          SliverToBoxAdapter(child: _buildFilters()),
          if (_errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _buildInlineError(),
              ),
            ),
          if (_filteredAppointments.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final appointment = _filteredAppointments[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildAppointmentCard(appointment),
                  );
                }, childCount: _filteredAppointments.length),
              ),
            ),
        ],
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1264E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your appointments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_appointments.length} appointment'
                  '${_appointments.length == 1 ? '' : 's'} in total',
                  style: const TextStyle(
                    color: Color(0xFFDCEAFF),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FILTERS
  // ================================================================

  Widget _buildFilters() {
    const filters = [
      ('all', 'All'),
      ('upcoming', 'Upcoming'),
      ('completed', 'Completed'),
      ('cancelled', 'Cancelled'),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = _selectedFilter == filter.$1;
          final count = _countForFilter(filter.$1);

          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter.$1;
              });
            },
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF1264E8),
            side: BorderSide(
              color: selected
                  ? const Color(0xFF1264E8)
                  : const Color(0xFFE5E7EB),
            ),
            label: Text('${filter.$2} ($count)'),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF374151),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }

  // ================================================================
  // APPOINTMENT CARD
  // ================================================================

  Widget _buildAppointmentCard(AppointmentListModel appointment) {
    final statusColor = _statusColor(appointment.statusName);
    final localStart = appointment.startDatetime.toLocal();
    final canCancel = _canCancel(appointment);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showAppointmentDetails(appointment),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${localStart.day}',
                          style: const TextStyle(
                            color: Color(0xFF1264E8),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _monthName(localStart.month),
                          style: const TextStyle(
                            color: Color(0xFF1264E8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.businessName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          appointment.serviceName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 17,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${_formatDate(localStart)} • '
                      '${_formatTime(localStart)}',
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 17,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      appointment.staffName?.isNotEmpty == true
                          ? appointment.staffName!
                          : 'Staff not assigned',
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  _buildStatusBadge(appointment.statusName, statusColor),
                ],
              ),
              if (canCancel) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cancellingAppointmentId == appointment.id
                        ? null
                        : () => _showCancelDialog(appointment),
                    icon: _cancellingAppointmentId == appointment.id
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.event_busy_outlined, size: 18),
                    label: Text(
                      _cancellingAppointmentId == appointment.id
                          ? 'Cancelling...'
                          : 'Cancel Appointment',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
              ],

              if (_canUpdate(appointment)) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showUpdateDialog(appointment);
                    },
                    icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                    label: const Text('Update Appointment'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1264E8),
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // STATUS BADGE
  // ================================================================

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Unknown' : status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase();

    if (value.contains('cancel')) {
      return const Color(0xFFDC2626);
    }

    if (value.contains('complete')) {
      return const Color(0xFF16A34A);
    }

    if (value.contains('confirm')) {
      return const Color(0xFF1264E8);
    }

    if (value.contains('pending')) {
      return const Color(0xFFD97706);
    }

    return const Color(0xFF6B7280);
  }

  // ================================================================
  // APPOINTMENT DETAILS
  // ================================================================

  Future<void> _showAppointmentDetails(AppointmentListModel appointment) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _AppointmentDetailsDialog(
          appointment: appointment,
          loadDetails: () async {
            final accessToken = await _tokenStorage.getAccessToken();

            if (accessToken == null || accessToken.isEmpty) {
              throw const UnauthorizedException();
            }

            return _appointmentRepository.getAppointmentById(
              appointment.id,
              accessToken,
            );
          },
        );
      },
    );
  }

  // ================================================================
  // CANCEL DIALOG
  // ================================================================

  Future<void> _showCancelDialog(AppointmentListModel appointment) async {
    if (_cancellingAppointmentId != null || !mounted) return;

    // Clear the previous cancellation reason before opening the dialog.
    reasonController.clear();

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Cancel Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel your appointment at '
                '${appointment.businessName}?',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                minLines: 2,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Reason for cancellation',
                  hintText: 'Tell us why you want to cancel',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Keep Appointment'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final value = reasonController.text.trim();

                if (value.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a cancellation reason.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              child: const Text('Confirm Cancellation'),
            ),
          ],
        );
      },
    );

    // The screen may have been removed while the dialog was open.
    if (!mounted || reason == null || reason.trim().isEmpty) {
      return;
    }

    await _cancelAppointment(appointment, reason.trim());
  }

  // ================================================================
  // update DIALOG
  // ================================================================

  Future<void> _showUpdateDialog(AppointmentListModel appointment) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateAppointmentScreen(appointment: appointment),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      await _loadAppointments();

      if (!mounted) return;

      _showMessage('Appointment updated successfully.');
    }
  }

  // ================================================================
  // CALL CANCEL API
  // ================================================================

  Future<void> _cancelAppointment(
    AppointmentListModel appointment,
    String reason,
  ) async {
    if (!mounted) return;

    setState(() {
      _cancellingAppointmentId = appointment.id;
    });

    try {
      final accessToken = await _tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw const UnauthorizedException();
      }

      final AppointmentDetailsModel result = await _appointmentRepository
          .cancelAppointment(appointment.id, reason, accessToken);

      if (!mounted) return;

      // Update the card immediately with the returned server data.
      setState(() {
        final index = _appointments.indexWhere((a) => a.id == appointment.id);

        if (index != -1) {
          _appointments[index] = AppointmentListModel(
            id: result.id,
            businessId: result.businessId,
            businessName: result.businessName,
            customerId: result.customerId,
            customerName: result.customerName,
            serviceId: result.serviceId,
            serviceName: result.serviceName,
            statusId: result.statusId,
            statusName: result.statusName,
            startDatetime: result.startDatetime,
            endDatetime: result.endDatetime,
            customerNotes: result.customerNotes,
            createdAt: result.createdAt,
            updatedAt: result.updatedAt,
            cancelledAt: result.cancelledAt,
            completedAt: result.completedAt,
            staffId: result.staffId,
            staffName: result.staffName,
          );
        }
      });

      _showMessage('Appointment cancelled successfully.');
    } on UnauthorizedException {
      if (!mounted) return;

      _showMessage('Your session has expired. Please log in again.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to cancel appointment: ${_cleanError(e)}');
    } finally {
      if (mounted) {
        setState(() {
          _cancellingAppointmentId = null;
        });
      }
    }
  }

  // ================================================================
  // EMPTY STATE
  // ================================================================

  Widget _buildEmptyState() {
    final isAll = _selectedFilter == 'all';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 40,
                color: Color(0xFF1264E8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isAll ? 'No appointments yet' : 'No matching appointments',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAll
                  ? 'Your bookings will appear here when you make an appointment.'
                  : 'Try selecting another filter to see your appointments.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            if (!isAll)
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'all';
                  });
                },
                child: const Text('Show All Appointments'),
              ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // ERROR STATES
  // ================================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load appointments',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadAppointments(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () => _loadAppointments(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FORMATTING / MESSAGES
  // ================================================================

  String _monthName(int month) {
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

    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

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

// ==================================================================
// APPOINTMENT DETAILS DIALOG
// ==================================================================

class _AppointmentDetailsDialog extends StatefulWidget {
  final AppointmentListModel appointment;

  final Future<AppointmentDetailsModel?> Function() loadDetails;

  const _AppointmentDetailsDialog({
    required this.appointment,
    required this.loadDetails,
  });

  @override
  State<_AppointmentDetailsDialog> createState() =>
      _AppointmentDetailsDialogState();
}

class _AppointmentDetailsDialogState extends State<_AppointmentDetailsDialog> {
  late Future<AppointmentDetailsModel?> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = widget.loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.sizeOf(context).height * 0.65;

    return AlertDialog(
      title: const Text('Appointment Details'),
      content: SizedBox(
        width: 360,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxDialogHeight),
          child: FutureBuilder<AppointmentDetailsModel?>(
            future: _detailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load appointment details.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _detailsFuture = widget.loadDetails();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              final appointment = snapshot.data;

              if (appointment == null) {
                return const Text('Appointment details were not found.');
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Business', appointment.businessName),
                    _detailRow('Service', appointment.serviceName),
                    _detailRow('Customer', appointment.customerName),
                    _detailRow(
                      'Staff',
                      appointment.staffName?.isNotEmpty == true
                          ? appointment.staffName!
                          : 'Not assigned',
                    ),
                    _detailRow('Status', appointment.statusName),
                    _detailRow('Start', _dateTime(appointment.startDatetime)),
                    _detailRow('End', _dateTime(appointment.endDatetime)),
                    _detailRow(
                      'Notes',
                      appointment.customerNotes?.isNotEmpty == true
                          ? appointment.customerNotes!
                          : 'No additional notes',
                    ),
                    if (appointment.cancelledAt != null)
                      _detailRow(
                        'Cancelled',
                        _dateTime(appointment.cancelledAt!),
                      ),
                    if (appointment.completedAt != null)
                      _detailRow(
                        'Completed',
                        _dateTime(appointment.completedAt!),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _dateTime(DateTime value) {
    final date = value.toLocal();
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day}/${date.month}/${date.year} '
        '$hour:$minute $period';
  }
}
