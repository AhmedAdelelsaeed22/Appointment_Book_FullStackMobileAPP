import 'package:appointmentbook/models/business_with_category_model.dart';
import 'package:appointmentbook/screens/create_appointment_screen.dart';
import 'package:appointmentbook/services/favorites_manager.dart';
import 'package:appointmentbook/widget/build_business_image.dart';
import 'package:flutter/material.dart';

class BusinessDetailsScreen extends StatefulWidget {
  final BusinessWithCategoryModel business;
  final int customerId;
  const BusinessDetailsScreen({
    super.key,
    required this.business,
    required this.customerId,
  });

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  // ==================================================================
  // DATA
  // ==================================================================

  BusinessWithCategoryModel get business => widget.business;

  // ==================================================================
  // FAVORITE STATE
  // ==================================================================

  bool _isFavorite = false;

  bool _isFavoriteLoading = true;

  // ==================================================================
  // INIT
  // ==================================================================

  @override
  void initState() {
    super.initState();

    _loadFavoriteStatus();
  }

  // ==================================================================
  // LOAD FAVORITE STATUS
  // ==================================================================

  Future<void> _loadFavoriteStatus() async {
    try {
      final favorites = await favoritesManager.getAllFavorites();

      if (!mounted) return;

      setState(() {
        _isFavorite = favorites.any(
          (favorite) => favorite.businessId == business.id,
        );

        _isFavoriteLoading = false;
      });
    } catch (e) {
      debugPrint('LOAD FAVORITE STATUS ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isFavorite = false;
        _isFavoriteLoading = false;
      });
    }
  }

  // ==================================================================
  // TOGGLE FAVORITE
  // ==================================================================

  Future<void> _toggleFavorite() async {
    if (_isFavoriteLoading) {
      return;
    }

    final bool wasFavorite = _isFavorite;

    // --------------------------------------------------------------
    // OPTIMISTIC UI
    // --------------------------------------------------------------

    setState(() {
      _isFavoriteLoading = true;

      _isFavorite = !wasFavorite;
    });

    try {
      // ------------------------------------------------------------
      // REMOVE
      // ------------------------------------------------------------

      if (wasFavorite) {
        await favoritesManager.removeFavorite(business.id);
      }
      // ------------------------------------------------------------
      // ADD
      // ------------------------------------------------------------
      else {
        await favoritesManager.addFavorite(business.id);
      }
    } catch (e) {
      debugPrint('TOGGLE FAVORITE ERROR: $e');

      if (!mounted) return;

      // ------------------------------------------------------------
      // ROLLBACK
      // ------------------------------------------------------------

      setState(() {
        _isFavorite = wasFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorite.')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isFavoriteLoading = false;
      });
    }
  }

  // ==================================================================
  // BUILD
  // ==================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ==============================================================
      // APP BAR
      // ==============================================================
      appBar: AppBar(
        title: const Text('Business Details'),

        actions: [
          IconButton(
            onPressed: _isFavoriteLoading ? null : _toggleFavorite,

            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',

            icon: _isFavoriteLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _isFavorite ? Colors.red : const Color(0xFF374151),
                  ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ==============================================================
      // BODY
      // ==============================================================
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _buildBusinessHeader(),

                  const SizedBox(height: 24),

                  _buildBusinessInformation(),

                  const SizedBox(height: 24),

                  _buildAboutSection(),

                  const SizedBox(height: 24),

                  _buildContactSection(),

                  const SizedBox(height: 24),

                  _buildOpeningStatus(),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ==========================================================
            // BOTTOM BOOK BUTTON
            // ==========================================================
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,

              child: _buildBookButton(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================================
  // BUSINESS HEADER
  // ==================================================================

  Widget _buildBusinessHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // --------------------------------------------------------------
        // IMAGE
        // --------------------------------------------------------------
        Stack(
          children: [
            SizedBox(
              height: 240,
              width: double.infinity,

              child: BuildBusinessImage(imageUrl: business.logoUrl),
            ),

            // ----------------------------------------------------------
            // OPEN / CLOSED
            // ----------------------------------------------------------
            Positioned(left: 20, bottom: 16, child: _buildOpenStatus()),

            // ----------------------------------------------------------
            // VERIFIED
            // ----------------------------------------------------------
            Positioned(
              right: 20,
              bottom: 16,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 17,
                      color: Color(0xFF1264E8),
                    ),

                    SizedBox(width: 6),

                    Text(
                      'Verified',

                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1264E8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // --------------------------------------------------------------
        // NAME + CATEGORY
        // --------------------------------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                business.name,

                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

              Text(
                business.categoryName,

                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF1264E8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================================================================
  // BUSINESS INFORMATION
  // ==================================================================

  Widget _buildBusinessInformation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFB800),
                  title: business.rating.toStringAsFixed(1),
                  subtitle: 'Rating',
                ),
              ),

              _buildVerticalDivider(),

              Expanded(
                child: _buildInfoItem(
                  icon: Icons.location_on_outlined,
                  iconColor: const Color(0xFF1264E8),
                  title: 'Location',
                  subtitle: business.location,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: iconColor),

        const SizedBox(height: 8),

        Text(
          title,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          textAlign: TextAlign.center,

          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,

          maxLines: 2,

          overflow: TextOverflow.ellipsis,

          textAlign: TextAlign.center,

          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 60,

      color: const Color(0xFFE5E7EB),

      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  // ==================================================================
  // ABOUT
  // ==================================================================

  Widget _buildAboutSection() {
    final description = business.description;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text('About', style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),

              child: Text(
                description == null || description.trim().isEmpty
                    ? 'No description available for this business.'
                    : description,

                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // CONTACT
  // ==================================================================

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'Contact Information',

            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                _buildContactItem(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: business.phone,
                ),

                const Divider(height: 1),

                _buildContactItem(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: business.email,
                ),

                const Divider(height: 1),

                _buildContactItem(
                  icon: Icons.public_outlined,
                  title: 'Timezone',
                  value: business.timezone,
                ),

                const Divider(height: 1),

                _buildContactItem(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: business.location,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: const Color(0xFF1264E8), size: 21),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value.isEmpty ? 'Not available' : value,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // OPENING STATUS
  // ==================================================================

  Widget _buildOpeningStatus() {
    final bool isOpen = business.isOpen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text('Availability', style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),

              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,

                    decoration: BoxDecoration(
                      color: isOpen ? Colors.green.shade50 : Colors.red.shade50,

                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Icon(
                      isOpen
                          ? Icons.access_time_rounded
                          : Icons.access_time_filled_rounded,

                      color: isOpen
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          isOpen ? 'Open now' : 'Currently closed',

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,

                            color: isOpen
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          isOpen
                              ? 'This business is currently accepting appointments.'
                              : 'This business is currently closed.',

                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // OPEN STATUS BADGE
  // ==================================================================

  Widget _buildOpenStatus() {
    final bool isOpen = business.isOpen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            width: 8,
            height: 8,

            decoration: BoxDecoration(
              color: isOpen ? Colors.green : Colors.red,

              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 7),

          Text(
            isOpen ? 'Open now' : 'Closed',

            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,

              color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================================
  // BOOK APPOINTMENT
  // ==================================================================

  Widget _buildBookButton() {
    return Material(
      elevation: 8,

      shadowColor: Colors.black.withValues(alpha: 0.12),

      borderRadius: BorderRadius.circular(12),

      child: SizedBox(
        width: double.infinity,
        height: 52,

        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateAppointmentScreen(
                  business: business,
                  customerId: widget.customerId,
                ),
              ),
            );
          },

          icon: const Icon(Icons.calendar_month_rounded, size: 21),

          label: const Text('Book Appointment'),
        ),
      ),
    );
  }
}
