import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/vendor_card.dart';
import '../../../core/widgets/safe_network_image.dart';
import '../../../data/repositories/mock_wedding_repository.dart';
import '../../../data/models/vendor.dart';
import '../location/location_selection_screen.dart';
import 'vendor_details_screen.dart';

class VendorListingScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialLocation;
  final String? initialQuery;

  const VendorListingScreen({
    super.key,
    this.initialCategory,
    this.initialLocation,
    this.initialQuery,
  });

  @override
  State<VendorListingScreen> createState() => _VendorListingScreenState();
}

class _VendorGridCard extends StatelessWidget {
  const _VendorGridCard({
    required this.vendor,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistTap,
  });

  final Vendor vendor;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SafeNetworkImage(imageUrl: vendor.heroImage),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton.filledTonal(
                      onPressed: onWishlistTap,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted
                            ? Colors.red
                            : AppColors.primaryPlum,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          '${vendor.rating} ★',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vendor.category} · ${vendor.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'From ₹${vendor.startingPrice}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryPlum,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: AppColors.primaryPlum,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorListingScreenState extends State<VendorListingScreen> {
  final MockWeddingRepository _repository = MockWeddingRepository();
  final TextEditingController _searchController = TextEditingController();
  late String _selectedCategory;
  late String _selectedLocation;
  String _sortBy = 'Popularity';
  String _searchQuery = '';
  double _maxPrice = double.infinity;
  double _minRating = 0;
  bool _onlyAvailable = false;
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _selectedLocation = widget.initialLocation ?? _repository.selectedLocation;
    _searchQuery = widget.initialQuery ?? '';
    _searchController.text = _searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedLocation = 'All Locations';
      _searchQuery = '';
      _maxPrice = double.infinity;
      _minRating = 0;
      _onlyAvailable = false;
      _favoritesOnly = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repository,
      builder: (context, _) {
        var filtered = _repository.searchVendors(
          _searchQuery,
          category: _selectedCategory,
          location: _selectedLocation == 'All Locations'
              ? null
              : _selectedLocation,
          maxPrice: _maxPrice.isFinite ? _maxPrice : null,
          minRating: _minRating > 0 ? _minRating : null,
        );
        final approvedServices = _repository.publicServices.where((service) {
          final queryMatch =
              _searchQuery.isEmpty ||
              '${service['name']} ${service['category']} ${service['location']} ${service['vendorName']}'
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
          final categoryMatch =
              _selectedCategory == 'All' ||
              service['category'].toString().toLowerCase() ==
                  _selectedCategory.toLowerCase();
          final locationMatch =
              _selectedLocation == 'All Locations' ||
              _repository.matchesLocation(
                service['location'].toString(),
                _selectedLocation,
              );
          return queryMatch && categoryMatch && locationMatch;
        }).toList();
        if (_onlyAvailable) {
          filtered = filtered.where((vendor) => vendor.isAvailable).toList();
        }
        if (_favoritesOnly) {
          filtered = filtered
              .where((vendor) => _repository.isWishlisted(vendor.id))
              .toList();
        }
        if (_sortBy == 'Rating') {
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
        }
        if (_sortBy == 'Price: Low to High') {
          filtered.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
        }
        if (_sortBy == 'Price: High to Low') {
          filtered.sort((a, b) => b.startingPrice.compareTo(a.startingPrice));
        }
        final hasFilters =
            _selectedCategory != 'All' ||
            _selectedLocation != 'All Locations' ||
            _searchQuery.isNotEmpty ||
            _maxPrice.isFinite ||
            _minRating > 0 ||
            _onlyAvailable ||
            _favoritesOnly;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _selectedCategory == 'All'
                  ? 'Wedding Services'
                  : _selectedCategory,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              TextButton.icon(
                onPressed: _showFilterBottomSheet,
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Filter'),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search vendors in $_selectedLocation...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LocationSelectionScreen(),
                              ),
                            );
                            setState(
                              () => _selectedLocation =
                                  _repository.selectedLocation,
                            );
                          },
                          child: _pill(
                            Icons.location_on_rounded,
                            _selectedLocation,
                            AppColors.plumTint,
                            AppColors.primaryPlum,
                          ),
                        ),
                        InkWell(
                          onTap: _showSortDialog,
                          child: _pill(
                            Icons.sort_rounded,
                            'Sort: $_sortBy',
                            AppColors.softChampagne,
                            AppColors.deepGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 48,
                color: Colors.white,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _categoryPill('All'),
                    ...AppConstants.serviceCategories.map(_categoryPill),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderLight),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 4,
                  spacing: 8,
                  children: [
                    Text(
                      '${filtered.length} Vendors Found',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    FilterChip(
                      avatar: const Icon(Icons.favorite_rounded, size: 16),
                      label: const Text('Favorites'),
                      selected: _favoritesOnly,
                      onSelected: (value) =>
                          setState(() => _favoritesOnly = value),
                    ),
                    if (hasFilters)
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Reset Filters'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty && approvedServices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No wedding vendors found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryPlum,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _clearFilters,
                              child: const Text('Show All Vendors'),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 760) {
                            final columns = constraints.maxWidth >= 1100
                                ? 3
                                : 2;
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                12,
                                18,
                                30,
                              ),
                              itemCount:
                                  filtered.length + approvedServices.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    mainAxisExtent: 370,
                                  ),
                              itemBuilder: (context, index) {
                                if (index >= filtered.length) {
                                  final service =
                                      approvedServices[index - filtered.length];
                                  final images =
                                      service['images'] as List? ?? const [];
                                  return Card(
                                    margin: EdgeInsets.zero,
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: images.isEmpty
                                              ? Container(
                                                  color: AppColors.plumTint,
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.storefront_outlined,
                                                      color:
                                                          AppColors.primaryPlum,
                                                      size: 36,
                                                    ),
                                                  ),
                                                )
                                              : SafeNetworkImage(
                                                  imageUrl: images.first
                                                      .toString(),
                                                ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                service['name'].toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${service['vendorName']} · ${service['category']}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${service['location']} · ₹${service['price']}',
                                                style: const TextStyle(
                                                  color: AppColors.primaryPlum,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                final vendor = filtered[index];
                                return _VendorGridCard(
                                  vendor: vendor,
                                  isWishlisted: _repository.isWishlisted(
                                    vendor.id,
                                  ),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          VendorDetailsScreen(vendor: vendor),
                                    ),
                                  ),
                                  onWishlistTap: () =>
                                      _repository.toggleWishlist(vendor.id),
                                );
                              },
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 30),
                            itemCount:
                                filtered.length + approvedServices.length,
                            itemBuilder: (context, index) {
                              if (index >= filtered.length) {
                                final service =
                                    approvedServices[index - filtered.length];
                                final image =
                                    (service['images'] as List).isEmpty
                                    ? ''
                                    : (service['images'] as List).first
                                          .toString();
                                return Card(
                                  margin: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    8,
                                  ),
                                  child: ListTile(
                                    leading: image.isEmpty
                                        ? const Icon(
                                            Icons.storefront_rounded,
                                            color: AppColors.primaryPlum,
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              image,
                                              width: 58,
                                              height: 58,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.storefront_rounded,
                                                    color:
                                                        AppColors.primaryPlum,
                                                  ),
                                            ),
                                          ),
                                    title: Text(
                                      service['name'].toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${service['vendorName']} · ${service['category']} · ${service['location']}\n₹${service['price']}',
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              }
                              final vendor = filtered[index];
                              return VendorCard(
                                vendor: vendor,
                                isWishlisted: _repository.isWishlisted(
                                  vendor.id,
                                ),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VendorDetailsScreen(vendor: vendor),
                                  ),
                                ),
                                onWishlistTap: () =>
                                    _repository.toggleWishlist(vendor.id),
                              );
                            },
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

  Widget _pill(
    IconData icon,
    String label,
    Color background,
    Color foreground,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryPill(String category) {
    final selected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 6),
      child: ChoiceChip(
        label: Text(category),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = category),
        selectedColor: AppColors.primaryPlum,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(
          color: selected ? AppColors.primaryPlum : AppColors.borderLight,
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
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort Vendors By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryPlum,
                ),
              ),
              const SizedBox(height: 14),
              ...[
                'Popularity',
                'Rating',
                'Price: Low to High',
                'Price: High to Low',
              ].map(
                (sort) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    sort,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: _sortBy == sort
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.royalGold,
                        )
                      : null,
                  onTap: () {
                    setState(() => _sortBy = sort);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    var draftLocation = _selectedLocation;
    var draftMaxPrice = _maxPrice;
    var draftMinRating = _minRating;
    var draftOnlyAvailable = _onlyAvailable;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, updateSheet) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Vendors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPlum,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Location',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['All Locations', ...AppConstants.defaultLocations]
                      .map(
                        (location) => ChoiceChip(
                          label: Text(location),
                          selected: draftLocation == location,
                          selectedColor: AppColors.primaryPlum,
                          labelStyle: TextStyle(
                            color: draftLocation == location
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) =>
                              updateSheet(() => draftLocation = location),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  'Maximum budget: ${draftMaxPrice.isFinite ? '₹${draftMaxPrice.toInt()}' : 'Any budget'}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Slider(
                  value: draftMaxPrice.isFinite
                      ? draftMaxPrice.clamp(25000, 250000).toDouble()
                      : 250000,
                  min: 25000,
                  max: 250000,
                  divisions: 9,
                  onChanged: (value) =>
                      updateSheet(() => draftMaxPrice = value),
                ),
                const Text(
                  'Minimum rating',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Wrap(
                  spacing: 8,
                  children: [0.0, 4.0, 4.5]
                      .map(
                        (rating) => ChoiceChip(
                          label: Text(
                            rating == 0
                                ? 'Any'
                                : '${rating.toStringAsFixed(1)}+',
                          ),
                          selected: draftMinRating == rating,
                          onSelected: (_) =>
                              updateSheet(() => draftMinRating = rating),
                        ),
                      )
                      .toList(),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available vendors only'),
                  value: draftOnlyAvailable,
                  onChanged: (value) =>
                      updateSheet(() => draftOnlyAvailable = value),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _clearFilters();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedLocation = draftLocation;
                            _maxPrice = draftMaxPrice;
                            _minRating = draftMinRating;
                            _onlyAvailable = draftOnlyAvailable;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
