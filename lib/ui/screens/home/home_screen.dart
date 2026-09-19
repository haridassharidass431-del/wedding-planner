import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/vendor_card.dart';
import '../../../data/repositories/mock_wedding_repository.dart';
import '../categories/categories_screen.dart';
import '../location/location_selection_screen.dart';
import '../vendors/vendor_details_screen.dart';
import '../vendors/vendor_listing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MockWeddingRepository _repository = MockWeddingRepository();
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  final List<Map<String, String>> _banners = [
    {
      'tag': 'ROYAL PRIVILEGE',
      'title': 'Cauvery Delta Wedding Fest',
      'desc': 'Book top-tier Mandapams & Palaces with complimentary bridal suites.',
      'image': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=900&q=80',
    },
    {
      'tag': 'AUTHENTIC TASTE',
      'title': '32-Item Ela Sappadu Feasts',
      'desc': 'Authentic Thiruvarur Asoka Halwa & traditional banana leaf spreads.',
      'image': 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=900&q=80',
    },
    {
      'tag': 'CINEMATIC LUXURY',
      'title': 'Timeless Muhurtham Moments',
      'desc': 'Sony 4K FX3 cameras, aerial drone films & handcrafted leather albums.',
      'image': 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=900&q=80',
    },
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repository,
      builder: (context, _) {
        final selectedLocation = _repository.selectedLocation;
        final featuredVendors = _repository.getFeaturedVendors();
        final localHalls = _repository.vendors
            .where((v) => v.category == 'Wedding Halls' && (v.location == selectedLocation || selectedLocation == 'All Locations'))
            .toList();

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Luxury Top App Bar
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    color: Colors.white,
                    child: Row(
                      children: [
                        // Small Circular Brand Logo
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.royalGold, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.royalGold.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(AppConstants.logoAssetPath, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Location Selector Pill
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LocationSelectionScreen(),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text(
                                      'WEDDING LOCATION',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.royalGold,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.royalGold),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 15, color: AppColors.primaryPlum),
                                    const SizedBox(width: 3),
                                    Text(
                                      selectedLocation,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryPlum,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.plumTint,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryPlum.withValues(alpha: 0.15)),
                          ),
                          child: Text(
                            _repository.currentRole,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryPlum,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar Box
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VendorListingScreen(initialCategory: 'All'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.warmCream,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search_rounded, color: AppColors.primaryPlum),
                            SizedBox(width: 12),
                            Text(
                              'Search Wedding Halls, Photography, Catering...',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Hero Promotional Carousel
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 165,
                        child: PageView.builder(
                          controller: _bannerController,
                          itemCount: _banners.length,
                          onPageChanged: (idx) => setState(() => _currentBannerIndex = idx),
                          itemBuilder: (context, index) {
                            final banner = _banners[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(banner['image']!),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPlum.withValues(alpha: 0.18),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryPlum.withValues(alpha: 0.85),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.royalGold,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        banner['tag']!,
                                        style: const TextStyle(
                                          color: AppColors.textOnGold,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      banner['title']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        banner['desc']!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Carousel dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_banners.length, (idx) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentBannerIndex == idx ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentBannerIndex == idx ? AppColors.royalGold : AppColors.borderLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // Quick Service Categories Bar
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Wedding Services',
                        subtitle: 'Everything for your auspicious celebration',
                        actionText: 'View All 9',
                        onActionTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                          );
                        },
                      ),
                      SizedBox(
                        height: 105,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: _repository.categories.length,
                          itemBuilder: (context, index) {
                            final cat = _repository.categories[index];
                            return CategoryBubbleItem(
                              category: cat,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => VendorListingScreen(initialCategory: cat.name),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Featured Wedding Vendors (Horizontal Carousel)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Featured Wedding Vendors',
                        subtitle: 'Handpicked and verified by Haventra',
                        actionText: 'Explore',
                        onActionTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VendorListingScreen(initialCategory: 'All'),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 255,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: featuredVendors.length,
                          itemBuilder: (context, index) {
                            final vendor = featuredVendors[index];
                            final isWishlisted = _repository.isWishlisted(vendor.id);

                            return VendorCompactCard(
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
                ),

                // Popular Mandapams & Halls in Selected Location
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Wedding Halls in $selectedLocation',
                        subtitle: 'Royal mandapams & AC marriage venues',
                        actionText: 'See Halls',
                        onActionTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VendorListingScreen(
                                initialCategory: 'Wedding Halls',
                                initialLocation: selectedLocation,
                              ),
                            ),
                          );
                        },
                      ),
                      if (localHalls.isNotEmpty)
                        ...localHalls.take(2).map((hall) {
                          return VendorCard(
                            vendor: hall,
                            isWishlisted: _repository.isWishlisted(hall.id),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VendorDetailsScreen(vendor: hall),
                                ),
                              );
                            },
                            onWishlistTap: () => _repository.toggleWishlist(hall.id),
                          );
                        })
                      else
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.castle_rounded, color: AppColors.royalGold, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Explore all verified marriage halls across the Delta region.',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Wedding Checklist Banner
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppColors.plumGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPlum.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.checklist_rounded, color: AppColors.brightGold, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Auspicious Wedding Checklist',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Track your Muhurtham date, Hall, Feast & Gold purchases.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                ),
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
          ),
        );
      },
    );
  }
}
