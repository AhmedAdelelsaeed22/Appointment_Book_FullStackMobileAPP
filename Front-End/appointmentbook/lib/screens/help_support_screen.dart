import 'package:flutter/material.dart';

const Color _primaryBlue = Color(0xFF1264E8);
const Color _backgroundColor = Color(0xFFF7F9FC);
const Color _textColor = Color(0xFF172033);
const Color _secondaryTextColor = Color(0xFF687386);

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      appBar: AppBar(
        backgroundColor: _backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: _textColor,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: _textColor),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1264E8), Color(0xFF4389F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.support_agent_rounded,
                    size: 55,
                    color: Colors.white,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Find useful information about using Appointment Book and managing your appointments.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // GETTING STARTED
            // ==================================================
            _sectionHeading(
              'Getting Started',
              'Learn how to use Appointment Book',
            ),

            const SizedBox(height: 15),

            _helpCard(
              icon: Icons.person_outline_rounded,
              title: 'Your Account',
              description:
                  'Create an account or log in to access the application. You can view and update your personal information from your profile.',
            ),

            _helpCard(
              icon: Icons.search_rounded,
              title: 'Find a Business',
              description:
                  'Browse available businesses and explore their services. You can discover businesses based on their categories.',
            ),

            _helpCard(
              icon: Icons.calendar_month_outlined,
              title: 'Book an Appointment',
              description:
                  'Choose a business, select the service you need, and pick an available date and time. Submit your booking request to create an appointment.',
            ),

            const SizedBox(height: 25),

            // ==================================================
            // APPOINTMENTS
            // ==================================================
            _sectionHeading(
              'Managing Appointments',
              'Everything about your bookings',
            ),

            const SizedBox(height: 15),

            _helpCard(
              icon: Icons.event_note_outlined,
              title: 'View Your Appointments',
              description:
                  'Open My Appointments to view your bookings and check their current status, including pending, confirmed, completed, and cancelled appointments.',
            ),

            _helpCard(
              icon: Icons.edit_calendar_outlined,
              title: 'Update an Appointment',
              description:
                  'You can update eligible pending appointments by selecting the appointment and changing the available booking information.',
            ),

            _helpCard(
              icon: Icons.cancel_outlined,
              title: 'Cancel an Appointment',
              description:
                  'If you cannot attend an appointment, open its details and use the cancel option. You may also be asked to provide a cancellation reason.',
            ),

            const SizedBox(height: 25),

            // ==================================================
            // ACCOUNT SECURITY
            // ==================================================
            _sectionHeading('Account & Security', 'Keep your account safe'),

            const SizedBox(height: 15),

            _helpCard(
              icon: Icons.manage_accounts_outlined,
              title: 'Edit Your Profile',
              description:
                  'You can update your first name, last name, email address, phone number, and profile image from the Edit Profile screen.',
            ),

            _helpCard(
              icon: Icons.lock_outline_rounded,
              title: 'Change Password',
              description:
                  'Use the Change Password option to update your account password. Choose a strong password and keep it private.',
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SUPPORT
            // ==================================================
            _sectionHeading('Need More Help?', 'We are here to help'),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.headset_mic_outlined,
                    color: _primaryBlue,
                    size: 38,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _textColor,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'If you experience any problems while using Appointment Book, please contact our support team for assistance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryTextColor,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // FOOTER
            // ==================================================
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: _primaryBlue,
                    size: 28,
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Appointment Book',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _textColor,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Making appointments easier for everyone.',
                    style: TextStyle(fontSize: 12, color: _secondaryTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  static Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textColor,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: _secondaryTextColor),
        ),
      ],
    );
  }

  // ============================================================
  // HELP CARD
  // ============================================================

  static Widget _helpCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.13)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryBlue, size: 23),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _secondaryTextColor,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
