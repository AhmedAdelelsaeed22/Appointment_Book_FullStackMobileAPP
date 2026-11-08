import 'package:appointmentbook/providers/user_provider.dart';
import 'package:appointmentbook/screens/business_screen.dart';
import 'package:appointmentbook/screens/favorites_screen.dart';
import 'package:appointmentbook/screens/my_appointments_screen.dart';
import 'package:appointmentbook/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color primaryBlue = Color(0xFF1264E8);
const Color lightBlue = Color(0xFFEAF2FF);
const Color backgroundColor = Color(0xFFF7F9FC);
const Color textColor = Color(0xFF172033);
const Color secondaryTextColor = Color(0xFF687386);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() => _isMenuOpen = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _openBusinesses(int? customerId) async {
    _closeMenu();

    if (customerId == null) {
      _showMessage('User information is not available.');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BusinessScreen(customerId: customerId)),
    );
  }

  Future<void> _openAppointments(int? customerId) async {
    _closeMenu();

    if (customerId == null) {
      _showMessage('User information is not available.');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyAppointmentsScreen(userId: customerId),
      ),
    );
  }

  Future<void> _openFavorites(int? customerId) async {
    _closeMenu();

    if (customerId == null) {
      _showMessage('User information is not available.');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(customerId: customerId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState.value;
    final customerId = user?.userId;
    final userName = user?.fullName ?? 'there';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(userName),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(userName, customerId),

                        const SizedBox(height: 30),

                        _buildSectionHeading(
                          title: 'Explore Categories',
                          subtitle: 'Find the service you need',
                        ),

                        const SizedBox(height: 16),

                        _buildCategories(customerId),

                        const SizedBox(height: 30),

                        _buildAboutSection(),

                        const SizedBox(height: 28),

                        _buildFeaturedBusinesses(customerId),

                        const SizedBox(height: 24),

                        _buildBottomBanner(customerId),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dark overlay
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu,
                child: Container(color: Colors.black.withValues(alpha: 0.40)),
              ),
            ),

          // Animated side menu
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            left: _isMenuOpen ? 0 : -300,
            top: 0,
            bottom: 0,
            child: _buildSideMenu(
              context,
              customerId,
              user?.fullName ?? 'Customer',
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // APP BAR
  // ------------------------------------------------------------

  Widget _buildAppBar(String userName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: _toggleMenu,
            tooltip: _isMenuOpen ? 'Close menu' : 'Open menu',
            icon: Icon(
              _isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
              color: textColor,
              size: 27,
            ),
          ),

          const SizedBox(width: 4),

          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AppointmentBook',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Your time, organized.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Tooltip(
            message: 'Profile',
            child: CircleAvatar(
              radius: 21,
              backgroundColor: lightBlue,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // WELCOME / HERO SECTION
  // ------------------------------------------------------------

  Widget _buildWelcomeSection(String userName, int? customerId) {
    return Container(
      width: double.infinity,
      height: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.15),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d'
              '?auto=format&fit=crop&w=1000&q=85',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: primaryBlue),
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF082D69).withValues(alpha: 0.95),
                    const Color(0xFF1264E8).withValues(alpha: 0.76),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.62, 1.0],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.17),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'YOUR PERSONAL BOOKING ASSISTANT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Text(
                    'Hello, $userName!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Find the right\nservice for you.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Discover trusted businesses and book\n'
                    'your next appointment with ease.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _openBusinesses(customerId),
                      icon: const Icon(Icons.explore_outlined, size: 19),
                      label: const Text(
                        'Explore Businesses',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION HEADING
  // ------------------------------------------------------------

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: secondaryTextColor, fontSize: 13),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // CATEGORIES
  // ------------------------------------------------------------

  Widget _buildCategories(int? customerId) {
    final categories = [
      const _CategoryInfo(
        title: 'Medical',
        subtitle: 'Health & care',
        image:
            'https://images.unsplash.com/photo-1622253692010-333f2da6031d'
            '?auto=format&fit=crop&w=500&q=80',
        icon: Icons.medical_services_outlined,
      ),
      const _CategoryInfo(
        title: 'Dental',
        subtitle: 'Healthy smiles',
        image:
            'https://images.unsplash.com/photo-1606811971618-4486d14f3f99'
            '?auto=format&fit=crop&w=500&q=80',
        icon: Icons.health_and_safety_outlined,
      ),
      const _CategoryInfo(
        title: 'Beauty',
        subtitle: 'Self-care',
        image:
            'https://images.unsplash.com/photo-1560066984-138dadb4c035'
            '?auto=format&fit=crop&w=500&q=80',
        icon: Icons.spa_outlined,
      ),
      const _CategoryInfo(
        title: 'Fitness',
        subtitle: 'Stay active',
        image:
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48'
            '?auto=format&fit=crop&w=500&q=80',
        icon: Icons.fitness_center_rounded,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];

        return InkWell(
          onTap: () => _openBusinesses(customerId),
          borderRadius: BorderRadius.circular(19),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xFFEBEFF5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: Image.network(
                          category.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: lightBlue,
                            child: Icon(
                              category.icon,
                              color: primaryBlue,
                              size: 36,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 9,
                        top: 9,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            category.icon,
                            color: primaryBlue,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        category.subtitle,
                        style: const TextStyle(
                          color: secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ABOUT APPOINTMENTBOOK
  // ------------------------------------------------------------

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDEAFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: primaryBlue,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'About AppointmentBook',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            'Your time matters. AppointmentBook helps you discover '
            'businesses, explore available services, and manage your '
            'appointments in one convenient place.',
            style: TextStyle(
              color: Color(0xFF52627A),
              fontSize: 13,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 17),

          const _AboutFeature(
            icon: Icons.search_rounded,
            title: 'Discover services',
            description: 'Find businesses that match your needs.',
          ),

          const SizedBox(height: 13),

          const _AboutFeature(
            icon: Icons.access_time_rounded,
            title: 'Save your time',
            description: 'Explore services and appointment options.',
          ),

          const SizedBox(height: 13),

          const _AboutFeature(
            icon: Icons.event_available_rounded,
            title: 'Stay organized',
            description: 'Keep track of your appointments in one place.',
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FEATURED BUSINESSES
  // ------------------------------------------------------------

  Widget _buildFeaturedBusinesses(int? customerId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(
          title: 'Discover Businesses',
          subtitle: 'Explore services in one convenient place',
        ),

        const SizedBox(height: 15),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: const Color(0xFFEBEFF5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  'https://images.unsplash.com/photo-1497366754035-f200968a6e72'
                  '?auto=format&fit=crop&w=1000&q=85',
                  height: 145,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 145,
                    color: lightBlue,
                    child: const Center(
                      child: Icon(
                        Icons.business_outlined,
                        size: 48,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Your next favorite place awaits',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Browse business profiles, learn about their services, '
                'and find the right place for your next appointment.',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 17),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _openBusinesses(customerId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront_outlined, size: 20),
                      SizedBox(width: 9),
                      Text(
                        'Show Businesses',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // BOTTOM BANNER
  // ------------------------------------------------------------

  Widget _buildBottomBanner(int? customerId) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF172F57),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Everything in one place.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'View your existing bookings whenever you need.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => _openAppointments(customerId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text('My Appointments'),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.event_note_rounded,
            size: 65,
            color: Color(0xFF8EB9FF),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SIDE MENU
  // ------------------------------------------------------------

  Widget _buildSideMenu(
    BuildContext context,
    int? customerId,
    String userName,
  ) {
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        width: 290,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: lightBlue,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: primaryBlue,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              const SizedBox(height: 12),

              _buildMenuItem(
                context,
                icon: Icons.home_rounded,
                title: 'Home',
                selected: true,
                onTap: _closeMenu,
              ),

              _buildMenuItem(
                context,
                icon: Icons.calendar_month_outlined,
                title: 'My Appointments',
                onTap: () => _openAppointments(customerId),
              ),

              _buildMenuItem(
                context,
                icon: Icons.storefront_outlined,
                title: 'Businesses',
                onTap: () => _openBusinesses(customerId),
              ),

              // _buildMenuItem(
              //   context,
              //   icon: Icons.notifications_none_rounded,
              //   title: 'Notifications',
              //   onTap: () {
              //     _closeMenu();
              //     _showMessage('Notifications are not available yet.');
              //   },
              // ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Divider(),
              ),

              _buildMenuItem(
                context,
                icon: Icons.favorite,
                title: 'My Favorites',
                onTap: () => _openFavorites(customerId),
              ),

              _buildMenuItem(
                context,
                icon: Icons.person_outline_rounded,
                title: 'Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),

              // _buildMenuItem(
              //   context,
              //   icon: Icons.settings_outlined,
              //   title: 'Settings',
              //   onTap: () {
              //     _closeMenu();
              //     _showMessage('Settings are not available yet.');
              //   },
              // ),
              const Spacer(),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              ),

              _buildMenuItem(
                context,
                icon: Icons.logout_rounded,
                title: 'Logout',
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  _closeMenu();
                  _showMessage('Connect this action to your logout flow.');
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MENU ITEM
  // ------------------------------------------------------------

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    Color? iconColor,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        tileColor: selected ? lightBlue : Colors.transparent,
        leading: Icon(
          icon,
          color:
              iconColor ?? (selected ? primaryBlue : const Color(0xFF536174)),
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                textColor ?? (selected ? primaryBlue : const Color(0xFF374151)),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }
}

// ------------------------------------------------------------
// CATEGORY MODEL
// ------------------------------------------------------------

class _CategoryInfo {
  final String title;
  final String subtitle;
  final String image;
  final IconData icon;

  const _CategoryInfo({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.icon,
  });
}

// ------------------------------------------------------------
// ABOUT FEATURE
// ------------------------------------------------------------

class _AboutFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AboutFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: primaryBlue),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: secondaryTextColor,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
