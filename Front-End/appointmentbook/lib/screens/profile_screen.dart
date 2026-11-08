import 'package:appointmentbook/models/user_model.dart';
import 'package:appointmentbook/providers/user_provider.dart';
import 'package:appointmentbook/screens/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color _primaryBlue = Color(0xFF1264E8);
const Color _lightBlue = Color(0xFFEAF2FF);
const Color _backgroundColor = Color(0xFFF7F9FC);
const Color _textColor = Color(0xFF172033);
const Color _secondaryTextColor = Color(0xFF687386);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: _textColor,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: userState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _primaryBlue)),
        error: (error, stackTrace) => _buildError(context),
        data: (user) {
          if (user == null) {
            return _buildEmptyState(context);
          }

          return _buildProfile(context, user);
        },
      ),
    );
  }

  // ============================================================
  // PROFILE CONTENT
  // ============================================================

  Widget _buildProfile(BuildContext context, UserModel user) {
    final fullName = _displayValue(user.fullName);
    final firstName = _displayValue(user.firstName);
    final lastName = _displayValue(user.lastName);
    final email = _displayValue(user.email);
    final phone = _displayValue(user.phone);
    final role = _displayValue(user.userRole);
    final userId = _displayValue(user.userId);
    final createdAt = _formatDate(user.createAt);
    final isActive = user.isActive == true;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
        // --------------------------------------------------------
        // PROFILE HEADER
        // --------------------------------------------------------
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1264E8), Color(0xFF4389F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: _primaryBlue.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70, width: 2),
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white,
                  child: Text(
                    _initials(fullName),
                    style: const TextStyle(
                      color: _primaryBlue,
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 17),

              Text(
                fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      role,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // --------------------------------------------------------
        // PERSONAL INFORMATION
        // --------------------------------------------------------
        _sectionHeading(
          'Personal Information',
          'Your personal account details',
        ),

        const SizedBox(height: 15),

        _informationCard([
          _ProfileItem(
            icon: Icons.badge_outlined,
            label: 'User ID',
            value: userId,
          ),
          _ProfileItem(
            icon: Icons.person_outline_rounded,
            label: 'First Name',
            value: firstName,
          ),
          _ProfileItem(
            icon: Icons.person_outline_rounded,
            label: 'Last Name',
            value: lastName,
          ),
          _ProfileItem(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: email,
          ),
          _ProfileItem(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: phone,
          ),
        ]),

        const SizedBox(height: 26),

        // --------------------------------------------------------
        // ACCOUNT DETAILS
        // --------------------------------------------------------
        _sectionHeading(
          'Account Details',
          'Your account information and status',
        ),

        const SizedBox(height: 15),

        _informationCard([
          _ProfileItem(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Account Role',
            value: role,
          ),
          _ProfileItem(
            icon: Icons.verified_outlined,
            label: 'Account Status',
            value: isActive ? 'Active' : 'Inactive',
            valueColor: isActive ? Colors.green : Colors.red,
          ),
          _ProfileItem(
            icon: Icons.calendar_today_outlined,
            label: 'Member Since',
            value: createdAt,
          ),
        ]),

        const SizedBox(height: 26),

        // --------------------------------------------------------
        // ACCOUNT ACTIONS
        // --------------------------------------------------------
        _sectionHeading('Account Actions', 'Manage your account'),

        const SizedBox(height: 15),

        _actionTile(
          icon: Icons.edit_outlined,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () {
            _showMessage(
              context,
              'Edit Profile screen is not implemented yet.',
            );
          },
        ),

        const SizedBox(height: 10),

        _actionTile(
          icon: Icons.lock_outline_rounded,
          title: 'Change Password',
          subtitle: 'Keep your account secure',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangePasswordScreen(email: user.email),
              ),
            );
          },
        ),

        const SizedBox(height: 10),

        _actionTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'Get help with AppointmentBook',
          onTap: () {
            _showMessage(context, 'Help & Support is not implemented yet.');
          },
        ),
      ],
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _textColor,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: _secondaryTextColor, fontSize: 12),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _informationCard(List<_ProfileItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFEBEFF5)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _informationRow(items[i]),
            if (i < items.length - 1)
              const Divider(height: 1, indent: 48, color: Color(0xFFEEF1F5)),
          ],
        ],
      ),
    );
  }

  Widget _informationRow(_ProfileItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _lightBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, size: 19, color: _primaryBlue),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: _secondaryTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                SelectableText(
                  item.value,
                  style: TextStyle(
                    color: item.valueColor ?? _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION TILE
  // ============================================================

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEBEFF5)),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: _primaryBlue, size: 22),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _secondaryTextColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: _secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 72,
              color: _primaryBlue,
            ),
            const SizedBox(height: 16),
            const Text(
              'User information unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please sign in again to load your profile.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryTextColor),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 55,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please try again later.',
              style: TextStyle(color: _secondaryTextColor),
            ),
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _displayValue(Object? value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Not provided';
    }

    return value.toString();
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not provided';

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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

// ============================================================
// PROFILE ITEM MODEL
// ============================================================

class _ProfileItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}
