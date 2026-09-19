import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/vendor_card.dart';
import '../../../data/models/vendor.dart';
import '../../../data/repositories/mock_wedding_repository.dart';
import '../location/location_selection_screen.dart';
import 'vendor_details_screen.dart';

class VendorListingScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialLocation;

  const VendorListingScreen({
    super.key,
    this.initialCategory,
    this.initialLocation,
  });

  @override
  State<VendorListingScreen> createState() => _VendorListingScreenState();
}

class _VendorListingScreenState extends State<VendorListingScreen> {
  final MockWeddingRepository _repository = MockWeddingRepository();
  final TextEditingController _searchController = TextEditingController();

  late String _selectedCategory;
  late String _selectedLocation;
  String _sortBy = 'Popularity'; // 'Popularity', 'Rating', 'Price: Low to High', 'Price: High to Low'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _selectedLocation = widget.initialLocation ?? _repository.selectedLocation;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repository,
      builder: (context, _) {
        // Fetch and filter vendors
        List<Vendor> filtered = _repository.searchVendors(
          _searchQuery,
          category: _selectedCategory,
          location: _selectedLocation == 'All Locations' ? null : _selectedLocation,
        );

        // Sort
        if (_sortBy == 'Rating') {
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
        } else if (_sortBy == 'Price: Low to High') {
          filtered.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
        } else if (_sortBy == 'Price: High to Low') {
          filtered.sort((a, b) => b.startingPrice.compareTo(a.startingPrice));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _selectedCategory == 'All' ? 'Wedding Services' : _selectedCategory,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: _showFilterBottomSheet,
              ),
            ],
          ),
          body: Column(
            children: [
              // Search & Active Filter Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search vendors in $_selectedLocation...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quick Location & Sort Pills
                    Row(
                      children: [
                        // Location Picker Pill
                        InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LocationSelectionScreen()),
                            );
                            setState(() {
                              _selectedLocation = _repository.selectedLocation;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.plumTint,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primaryPlum.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primaryPlum),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedLocation,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryPlum,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.primaryPlum),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Sort pill
                        InkWell(
                          onTap: _showSortDialog,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.softChampagne,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.6)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.sort_rounded, size: 14, color: AppColors.deepGold),
                                const SizedBox(width: 4),
                                Text(
                                  'Sort: $_sortBy',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkPlum,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Category Filter Bar
              Container(
                height: 48,
                color: Colors.white,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _categoryPill('All'),
                    ...AppConstants.serviceCategories.map((c) => _categoryPill(c)),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderLight),

              // Results Count Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} Vendors Found',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_selectedCategory != 'All' || _selectedLocation != 'All Locations' || _searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = 'All';
                            _selectedLocation = 'All Locations';
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        child: const Text(
                          'Reset Filters',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.royalGold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Vendor Listing
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
                              const SizedBox(height: 14),
                              const Text(
                                'No wedding vendors found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryPlum,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Try selecting "All Locations" or a different service category.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedCategory = 'All';
                                    _selectedLocation = 'All Locations';
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                                child: const Text('Show All Vendors'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 30),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final vendor = filtered[index];
                          final isWishlisted = _repository.isWishlisted(vendor.id);

                          return VendorCard(
                            vendor: vendor,
                            isWishlisted: isWishlisted,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VendorDetailsScreen(vendor: vendor),
                                ),
                              );
                            },
                            onWishlistTap: () => _repository.toggleWishlist(vendor.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _categoryPill(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 6),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedCategory = category);
        },
        selectedColor: AppColors.primaryPlum,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primaryPlum : AppColors.borderLight,
        ),
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort Vendors By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryPlum),
                ),
                const SizedBox(height: 14),
                ...['Popularity', 'Rating', 'Price: Low to High', 'Price: High to Low'].map((s) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: _sortBy == s ? const Icon(Icons.check_rounded, color: AppColors.royalGold) : null,
                    onTap: () {
                      setState(() => _sortBy = s);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryPlum),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['All Locations', ...AppConstants.defaultLocations].map((loc) {
                    final isSelected = _selectedLocation == loc;
                    return ChoiceChip(
                      label: Text(loc),
                      selected: isSelected,
                      selectedColor: AppColors.primaryPlum,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedLocation = loc);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
