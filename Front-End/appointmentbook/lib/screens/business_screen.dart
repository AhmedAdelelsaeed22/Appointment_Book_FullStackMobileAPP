import 'package:appointmentbook/models/business_with_category_model.dart';
import 'package:appointmentbook/models/category_model.dart';
import 'package:appointmentbook/repositories/business_repository.dart';
import 'package:appointmentbook/repositories/category_repository.dart';
import 'package:appointmentbook/screens/business_details_screen.dart';
import 'package:appointmentbook/screens/create_appointment_screen.dart';
import 'package:appointmentbook/screens/favorites_screen.dart';
import 'package:appointmentbook/services/business_api_service.dart';
import 'package:appointmentbook/services/category_api_service.dart';
import 'package:appointmentbook/services/favorites_manager.dart';
import 'package:appointmentbook/storage/token_storage.dart';
import 'package:appointmentbook/widget/build_business_image.dart';
import 'package:flutter/material.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key, required this.customerId});
  final int customerId;

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  // ========================================================================
  // REPOSITORIES
  // ========================================================================

  late final TokenStorage _tokenStorage;

  late final BusinessRepository _businessRepository;

  late final CategoryRepository _categoryRepository;

  // ========================================================================
  // DATA
  // ========================================================================

  List<CategoryModel> _categories = [];

  List<BusinessWithCategoryModel> _businesses = [];

  // ========================================================================
  // FAVORITES
  // ========================================================================

  // Contains the IDs of businesses that are currently favorites.
  Set<int> _favoriteIds = <int>{};

  // ID of the business whose favorite request is currently running.
  int? _favoriteUpdatingBusinessId;

  // ========================================================================
  // STATE
  // ========================================================================

  bool _isLoading = false;

  String? _errorMessage;

  // ========================================================================
  // CONTROLLERS
  // ========================================================================

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';

  // ========================================================================
  // INIT
  // ========================================================================

  @override
  void initState() {
    super.initState();

    _tokenStorage = TokenStorage();

    _businessRepository = BusinessRepository(BusinessApiService());

    _categoryRepository = CategoryRepository(CategoryApiService());

    _loadData();
  }

  // ========================================================================
  // LOAD DATA
  // ========================================================================

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accessToken = await _tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token not found.');
      }

      // ----------------------------------------------------------
      // LOAD CATEGORIES
      // ----------------------------------------------------------

      final categories = await _categoryRepository.getAllCategories(
        accessToken,
      );

      // ----------------------------------------------------------
      // LOAD BUSINESSES
      // ----------------------------------------------------------

      final businesses = await _businessRepository.getAllBusinesses(
        accessToken,
      );

      // ----------------------------------------------------------
      // LOAD FAVORITES
      // ----------------------------------------------------------

      await _loadFavorites();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _businesses = businesses;
      });
    } catch (e) {
      debugPrint('BUSINESS SCREEN ERROR: $e');

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
  // LOAD FAVORITES
  // ========================================================================

  Future<void> _loadFavorites() async {
    try {
      final favorites = await favoritesManager.getAllFavorites();

      if (!mounted) return;

      setState(() {
        _favoriteIds = favorites.map((favorite) => favorite.businessId).toSet();
      });
    } catch (e) {
      debugPrint('LOAD FAVORITES ERROR: $e');
    }
  }

  // ========================================================================
  // CHECK FAVORITE
  // ========================================================================

  bool _isFavorite(int businessId) {
    return _favoriteIds.contains(businessId);
  }

  // ========================================================================
  // TOGGLE FAVORITE
  // ========================================================================

  Future<void> _toggleFavorite(BusinessWithCategoryModel business) async {
    debugPrint('================================');
    debugPrint('BUSINESS NAME: ${business.name}');
    debugPrint('BUSINESS ID: ${business.id}');
    debugPrint('================================');

    final businessId = business.id;

    // Prevent multiple favorite requests at the same time.
    if (_favoriteUpdatingBusinessId != null) {
      return;
    }

    final wasFavorite = _isFavorite(businessId);

    // ----------------------------------------------------------
    // OPTIMISTIC UI UPDATE
    // ----------------------------------------------------------

    setState(() {
      _favoriteUpdatingBusinessId = businessId;

      if (wasFavorite) {
        _favoriteIds.remove(businessId);
      } else {
        _favoriteIds.add(businessId);
      }
    });

    try {
      // ----------------------------------------------------------
      // REMOVE FAVORITE
      // ----------------------------------------------------------

      if (wasFavorite) {
        await favoritesManager.removeFavorite(businessId);
      }
      // ----------------------------------------------------------
      // ADD FAVORITE
      // ----------------------------------------------------------
      else {
        await favoritesManager.addFavorite(businessId);
      }
    } catch (e) {
      debugPrint('TOGGLE FAVORITE ERROR: $e');

      if (!mounted) return;

      // ----------------------------------------------------------
      // ROLLBACK UI
      // ----------------------------------------------------------

      setState(() {
        if (wasFavorite) {
          // It was originally favorite.
          // Put it back into favorites.
          _favoriteIds.add(businessId);
        } else {
          // It was originally not favorite.
          // Remove it again.
          _favoriteIds.remove(businessId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorite.')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _favoriteUpdatingBusinessId = null;
      });
    }
  }

  // ========================================================================
  // FILTER BUSINESSES
  // ========================================================================

  List<BusinessWithCategoryModel> get _filteredBusinesses {
    List<BusinessWithCategoryModel> result = List.from(_businesses);

    // ----------------------------------------------------------
    // CATEGORY FILTER
    // ----------------------------------------------------------

    if (_selectedCategory != 'All') {
      result = result
          .where((business) => business.categoryName == _selectedCategory)
          .toList();
    }

    // ----------------------------------------------------------
    // SEARCH FILTER
    // ----------------------------------------------------------

    final searchText = _searchController.text.trim().toLowerCase();

    if (searchText.isNotEmpty) {
      result = result.where((business) {
        final name = business.name.toLowerCase();

        final category = business.categoryName.toLowerCase();

        final location = business.location.toLowerCase();

        return name.contains(searchText) ||
            category.contains(searchText) ||
            location.contains(searchText);
      }).toList();
    }

    return result;
  }

  // ========================================================================
  // DISPOSE
  // ========================================================================

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // ========================================================================
  // BUILD
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Businesses'),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FavoritesScreen(customerId: widget.customerId),
                ),
              ).then((_) {
                // Refresh favorite IDs when coming back.
                _loadFavorites();
              });
            },

            icon: const Icon(Icons.favorite_rounded),

            tooltip: 'Favorites',
          ),
        ],
      ),

      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          slivers: [
            // ============================================================
            // ERROR
            // ============================================================
            if (_errorMessage != null)
              SliverToBoxAdapter(child: _buildErrorState(context)),

            // ============================================================
            // SEARCH
            // ============================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),

                child: _buildSearchBar(context),
              ),
            ),

            // ============================================================
            // CATEGORIES
            // ============================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),

                child: _buildCategories(),
              ),
            ),

            // ============================================================
            // SECTION TITLE
            // ============================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Popular Businesses',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),

                    Text(
                      '${_filteredBusinesses.length} found',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // LOADING
            // ============================================================
            if (_isLoading && _businesses.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),

                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            // ============================================================
            // EMPTY
            // ============================================================
            else if (_filteredBusinesses.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState(context))
            // ============================================================
            // BUSINESS LIST
            // ============================================================
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),

                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final business = _filteredBusinesses[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),

                      child: _buildBusinessCard(context, business),
                    );
                  }, childCount: _filteredBusinesses.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // SEARCH BAR
  // ========================================================================

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,

      onChanged: (_) {
        setState(() {});
      },

      decoration: InputDecoration(
        hintText: 'Search businesses, services...',

        prefixIcon: const Icon(Icons.search_rounded),

        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();

                  setState(() {});
                },

                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }

  // ========================================================================
  // CATEGORIES
  // ========================================================================

  Widget _buildCategories() {
    return SizedBox(
      height: 46,

      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),

        scrollDirection: Axis.horizontal,

        itemCount: _categories.length + 1,

        separatorBuilder: (_, __) {
          return const SizedBox(width: 10);
        },

        itemBuilder: (context, index) {
          // ----------------------------------------------------------
          // ALL
          // ----------------------------------------------------------

          if (index == 0) {
            const categoryName = 'All';

            final selected = _selectedCategory == categoryName;

            return ChoiceChip(
              label: const Text(categoryName),

              selected: selected,

              onSelected: (_) {
                setState(() {
                  _selectedCategory = categoryName;
                });
              },

              selectedColor: const Color(0xFF1264E8),

              backgroundColor: const Color(0xFFF8FAFC),

              side: BorderSide(
                color: selected
                    ? const Color(0xFF1264E8)
                    : const Color(0xFFE5E7EB),
              ),

              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF374151),

                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }

          // ----------------------------------------------------------
          // API CATEGORY
          // ----------------------------------------------------------

          final category = _categories[index - 1];

          final categoryName = category.name;

          final selected = categoryName == _selectedCategory;

          return ChoiceChip(
            label: Text(categoryName),

            selected: selected,

            onSelected: (_) {
              setState(() {
                _selectedCategory = categoryName;
              });
            },

            selectedColor: const Color(0xFF1264E8),

            backgroundColor: const Color(0xFFF8FAFC),

            side: BorderSide(
              color: selected
                  ? const Color(0xFF1264E8)
                  : const Color(0xFFE5E7EB),
            ),

            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF374151),

              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  // ========================================================================
  // BUSINESS CARD
  // ========================================================================

  Widget _buildBusinessCard(
    BuildContext context,
    BusinessWithCategoryModel business,
  ) {
    final bool isOpen = business.isOpen;

    final bool isFavorite = _isFavorite(business.id);

    final bool isUpdating = _favoriteUpdatingBusinessId == business.id;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessDetailsScreen(
              business: business,
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
            Stack(
              children: [
                SizedBox(
                  height: 170,

                  width: double.infinity,

                  child: BuildBusinessImage(imageUrl: business.logoUrl),
                ),

                // ----------------------------------------------------------
                // OPEN / CLOSED
                // ----------------------------------------------------------
                Positioned(
                  top: 12,

                  left: 12,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Container(
                          width: 7,

                          height: 7,

                          decoration: BoxDecoration(
                            color: isOpen ? Colors.green : Colors.red,

                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 6),

                        Text(
                          isOpen ? 'Open now' : 'Closed',

                          style: TextStyle(
                            fontSize: 12,

                            fontWeight: FontWeight.w600,

                            color: isOpen
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ----------------------------------------------------------
                // FAVORITE
                // ----------------------------------------------------------
                Positioned(
                  top: 10,

                  right: 10,

                  child: Material(
                    color: Colors.white,

                    shape: const CircleBorder(),

                    child: IconButton(
                      onPressed: isUpdating
                          ? null
                          : () => _toggleFavorite(business),

                      icon: isUpdating
                          ? const SizedBox(
                              width: 20,

                              height: 20,

                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                            ),

                      color: isFavorite ? Colors.red : const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
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
                  // NAME + VERIFIED
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

                      const SizedBox(width: 8),

                      const Icon(
                        Icons.verified_rounded,

                        size: 18,

                        color: Color(0xFF1264E8),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // --------------------------------------------------------
                  // CATEGORY
                  // --------------------------------------------------------
                  Text(
                    business.categoryName,

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

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 70),

      child: Column(
        children: [
          Container(
            width: 90,

            height: 90,

            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),

              borderRadius: BorderRadius.circular(24),
            ),

            child: const Icon(
              Icons.search_off_rounded,

              size: 45,

              color: Color(0xFF1264E8),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'No businesses found',

            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 8),

          Text(
            'Try another search or category.',

            textAlign: TextAlign.center,

            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ========================================================================
  // ERROR STATE
  // ========================================================================

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.red.shade50,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(color: Colors.red.shade100),
        ),

        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade700),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                'Failed to load businesses.',

                style: TextStyle(
                  color: Colors.red.shade700,

                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            TextButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
