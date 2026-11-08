import 'package:appointmentbook/models/business_with_category_model.dart';
import 'package:appointmentbook/widget/build_business_image.dart';
import 'package:flutter/material.dart';

import '../models/favorite_business_with_details_model.dart';
import '../services/favorites_manager.dart';
import 'business_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.customerId});

  final int customerId;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // ========================================================================
  // DATA
  // ========================================================================

  List<FavoriteBusinessWithDetailsModel> _favorites = [];

  // ========================================================================
  // STATE
  // ========================================================================

  bool _isLoading = true;

  String? _errorMessage;

  // ID of the business currently being removed.
  int? _removingFavoriteBusinessId;

  // ========================================================================
  // INIT
  // ========================================================================

  @override
  void initState() {
    super.initState();

    _loadFavorites();
  }

  // ========================================================================
  // LOAD FAVORITES
  // ========================================================================

  Future<void> _loadFavorites() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final favorites = await favoritesManager.getAllFavorites();

      if (!mounted) return;

      setState(() {
        _favorites = favorites;
      });
    } catch (e) {
      debugPrint('LOAD FAVORITES ERROR: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ========================================================================
  // REMOVE FAVORITE
  // ========================================================================

  Future<void> _removeFavorite(
    FavoriteBusinessWithDetailsModel business,
  ) async {
    // Prevent multiple remove requests.
    if (_removingFavoriteBusinessId != null) {
      return;
    }

    // IMPORTANT:
    // business.id       = favorite record ID
    // business.businessId = actual business ID
    final businessId = business.businessId;

    setState(() {
      _removingFavoriteBusinessId = businessId;
    });

    try {
      final result = await favoritesManager.removeFavorite(businessId);

      if (!result) {
        throw Exception('Failed to remove favorite.');
      }

      if (!mounted) return;

      // Remove it from the local list after
      // the backend confirms success.
      setState(() {
        _favorites.removeWhere((item) => item.businessId == businessId);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Removed from favorites.')));
    } catch (e) {
      debugPrint('REMOVE FAVORITE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove favorite.')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _removingFavoriteBusinessId = null;
      });
    }
  }

  // ========================================================================
  // BUILD
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Favorites'),

        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _loadFavorites,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
            ),
        ],
      ),

      body: _buildBody(),
    );
  }

  // ========================================================================
  // BODY
  // ========================================================================

  Widget _buildBody() {
    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // ----------------------------------------------------------
    // EMPTY
    // ----------------------------------------------------------

    if (_favorites.isEmpty) {
      return _buildEmptyState();
    }

    // ----------------------------------------------------------
    // FAVORITES
    // ----------------------------------------------------------

    return _buildFavoritesList(_favorites);
  }

  // ========================================================================
  // FAVORITES LIST
  // ========================================================================

  Widget _buildFavoritesList(List<FavoriteBusinessWithDetailsModel> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),

      itemCount: favorites.length,

      itemBuilder: (context, index) {
        final business = favorites[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),

          child: _buildFavoriteCard(business),
        );
      },
    );
  }

  // ========================================================================
  // FAVORITE CARD
  // ========================================================================

  Widget _buildFavoriteCard(FavoriteBusinessWithDetailsModel business) {
    final bool isRemoving = _removingFavoriteBusinessId == business.businessId;

    final favorite = business;

    final businessForDetails = BusinessWithCategoryModel(
      id: favorite.businessId,
      ownerId: 0, // Favorite model currently doesn't contain ownerId.
      name: favorite.name,
      description: favorite.description,
      email: favorite.email,
      phone: favorite.phone,
      logoUrl: favorite.logoUrl,
      timezone: favorite.timezone,
      isOpen: favorite.isOpen,
      categoryName: favorite.categoryName,
      rating: favorite.rating,
      location: favorite.location,
    );

    return InkWell(
      onTap: isRemoving
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusinessDetailsScreen(
                    business: businessForDetails,
                    customerId: widget.customerId,
                  ),
                ),
              );
            },

      borderRadius: BorderRadius.circular(16),

      child: Card(
        clipBehavior: Clip.antiAlias,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==============================================================
            // IMAGE
            // ==============================================================
            SizedBox(
              height: 160,
              width: double.infinity,

              child: BuildBusinessImage(imageUrl: business.logoUrl),
            ),

            // ==============================================================
            // INFORMATION
            // ==============================================================
            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // --------------------------------------------------------
                  // NAME + FAVORITE
                  // --------------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          business.name,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),

                      // ----------------------------------------------------
                      // REMOVE FAVORITE
                      // ----------------------------------------------------
                      IconButton(
                        onPressed: isRemoving
                            ? null
                            : () => _removeFavorite(business),

                        icon: isRemoving
                            ? const SizedBox(
                                width: 20,
                                height: 20,

                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.favorite_rounded,
                                color: Colors.red,
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // --------------------------------------------------------
                  // BUSINESS TYPE
                  // --------------------------------------------------------
                  Text(
                    'Business',

                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 12),

                  // --------------------------------------------------------
                  // RATING
                  // --------------------------------------------------------
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,

                        size: 18,

                        color: Color(0xFFFFB800),
                      ),

                      const SizedBox(width: 4),

                      Text(
                        business.rating.toStringAsFixed(1),

                        style: const TextStyle(
                          fontSize: 14,

                          fontWeight: FontWeight.w600,

                          color: Color(0xFF374151),
                        ),
                      ),

                      const SizedBox(width: 4),

                      Text(
                        'rating',

                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // --------------------------------------------------------
                  // LOCATION
                  // --------------------------------------------------------
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,

                        size: 18,

                        color: Color(0xFF6B7280),
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          business.location,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // --------------------------------------------------------
                  // BOOK BUTTON
                  // --------------------------------------------------------
                  SizedBox(
                    width: double.infinity,

                    height: 46,

                    child: ElevatedButton(
                      onPressed: isRemoving
                          ? null
                          : () {
                              // TODO:
                              // Navigate to appointment booking.
                            },

                      child: const Text('Book Appointment'),
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

  // ========================================================================
  // EMPTY STATE
  // ========================================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),

                borderRadius: BorderRadius.circular(28),
              ),

              child: const Icon(
                Icons.favorite_border_rounded,

                size: 50,

                color: Color(0xFF1264E8),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'No Favorites Yet',

              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 10),

            Text(
              'Businesses you add to your favorites '
              'will appear here.',

              textAlign: TextAlign.center,

              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // ERROR STATE
  // ========================================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: Colors.red.shade50,

                borderRadius: BorderRadius.circular(24),
              ),

              child: Icon(Icons.favorite, size: 45, color: Colors.red.shade700),
            ),

            const SizedBox(height: 20),

            Text(
              'Not Found Favorites',

              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              'Not Found Any Favorite Businesses Yet!',

              textAlign: TextAlign.center,

              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
