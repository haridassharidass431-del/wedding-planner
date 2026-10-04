import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/safe_network_image.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/service_category.dart';
import '../../../data/models/vendor.dart';
import '../../../data/repositories/mock_wedding_repository.dart';
import '../ai/ai_assistant_screen.dart';
import '../categories/categories_screen.dart';
import '../location/location_selection_screen.dart';
import '../profile/profile_screen.dart';
import '../vendors/vendor_details_screen.dart';
import '../vendors/vendor_listing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MockWeddingRepository _repository = MockWeddingRepository();
  final TextEditingController _searchController = TextEditingController();

  static const _offers = [
    _HomeOffer(
      title: 'Muhurtham venue packages',
      detail: 'Ask about current packages for your special day.',
      category: 'Wedding Halls',
      image:
          'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=780&q=85',
      label: 'WEDDING HALL OFFERS',
    ),
    _HomeOffer(
      title: 'Wedding photography',
      detail: 'Explore candid and cinematic wedding packages.',
      category: 'Photography',
      image:
          'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=780&q=85',
      label: 'PHOTO PACKAGES',
    ),
    _HomeOffer(
      title: 'Bridal makeup packages',
      detail: 'Find a bridal look that feels like you.',
      category: 'Makeup',
      image:
          'https://images.unsplash.com/photo-1487412720507-e7ab37603e7b?auto=format&fit=crop&w=780&q=85',
      label: 'BRIDAL BEAUTY OFFERS',
    ),
  ];

  static const _culture = [
    _CultureStory(
      title: 'Honouring parents',
      subtitle: 'A family blessing in Tamil Nadu weddings',
      image:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Wedding_ceremony_in_Tamil_Nadu_01.jpg/960px-Wedding_ceremony_in_Tamil_Nadu_01.jpg',
      icon: Icons.temple_hindu_rounded,
      credit: 'Kritzolina · CC BY-SA 4.0',
    ),
    _CultureStory(
      title: 'Nadaswaram & thavil',
      subtitle: 'Auspicious music fills the muhurtham',
      image:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Nadaswaram_being_performed_in_South_Indian_Marriage_JEG6777.JPG/960px-Nadaswaram_being_performed_in_South_Indian_Marriage_JEG6777.JPG',
      icon: Icons.music_note_rounded,
      credit: 'PJeganathan · CC BY-SA 4.0',
    ),
    _CultureStory(
      title: 'Tamil wedding virundhu',
      subtitle: 'A feast served on the banana leaf',
      image:
          'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bc/Tamil_Nadu_Hindu_Marriage_Lunch.jpg/960px-Tamil_Nadu_Hindu_Marriage_Lunch.jpg',
      icon: Icons.restaurant_rounded,
      credit: 'Gopinath · CC BY-SA 4.0',
    ),
    _CultureStory(
      title: 'Kolam at a Tamil wedding',
      subtitle: 'A welcoming pattern at the threshold',
      image:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Kolam%40TamilWedding.jpg/1280px-Kolam%40TamilWedding.jpg',
      icon: Icons.spa_rounded,
      credit: 'Umāpati · CC BY-SA 3.0',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSearch({String? category}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VendorListingScreen(
          initialCategory: category ?? 'All',
          initialQuery: _searchController.text.trim(),
        ),
      ),
    );
  }

  void _openCategory(ServiceCategory category) =>
      _openSearch(category: category.name);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repository,
      builder: (context, _) {
        final categories = _repository.categories.take(9).toList();
        final featured = _repository.getFeaturedVendors();
        final selectedLocation = _repository.selectedLocation;
        final bookings = _repository.currentUserId == 'guest'
            ? <Booking>[]
            : _repository.getCustomerBookings(_repository.currentUserName);
        final upcoming =
            bookings
                .where(
                  (booking) =>
                      booking.eventDate.isAfter(
                        DateTime.now().subtract(const Duration(days: 1)),
                      ) &&
                      booking.status != 'Declined' &&
                      booking.status != 'Cancelled',
                )
                .toList()
              ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _content(_buildHeader(selectedLocation)),
                ),
                SliverToBoxAdapter(child: _content(_buildSearch())),
                SliverToBoxAdapter(child: _content(_buildTrending(featured))),
                SliverToBoxAdapter(
                  child: _content(_buildCategories(categories)),
                ),
                SliverToBoxAdapter(child: _content(_buildOffers())),
                SliverToBoxAdapter(child: _content(_buildAiAgent())),
                if (_repository.currentRole == 'Customer')
                  SliverToBoxAdapter(child: _content(_buildJourney(upcoming))),
                SliverToBoxAdapter(child: _content(_buildCulture())),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content(Widget child) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1280),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );

  Widget _buildHeader(String location) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 8, 16, 12),
    child: Row(
      children: [
        Image.asset(
          AppConstants.logoAssetPath,
          width: 34,
          height: 34,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LocationSelectionScreen(),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primaryPlum,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'YOUR LOCATION',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryPlum,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppColors.secondaryPurple,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: AppColors.plumTint,
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: 'Customer profile',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
            icon: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.primaryPlum,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSearch() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
    child: TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _openSearch(),
      decoration: InputDecoration(
        hintText: 'Search wedding services, vendors, venues...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.primaryPlum,
        ),
        suffixIcon: IconButton(
          onPressed: _openSearch,
          tooltip: 'Search',
          icon: const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.secondaryPurple,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.goldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primaryPlum,
            width: 1.6,
          ),
        ),
      ),
    ),
  );

  Widget _buildTrending(List<Vendor> vendors) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeader(
        title: '🔥 Trending',
        subtitle: 'Loved by couples around the Delta',
        actionText: 'Explore',
        onActionTap: _openSearch,
      ),
      SizedBox(
        height: 182,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          scrollDirection: Axis.horizontal,
          itemCount: vendors.take(6).length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final vendor = vendors[index];
            return _TrendingCard(
              vendor: vendor,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VendorDetailsScreen(vendor: vendor),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _buildCategories(List<ServiceCategory> categories) => Column(
    children: [
      SectionHeader(
        title: 'Wedding categories',
        subtitle: 'Nine essentials for your celebration',
        actionText: 'View all',
        onActionTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CategoriesScreen())),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1100
                ? 5
                : width >= 860
                ? 4
                : width >= 600
                ? 3
                : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: width < 600 ? 0.82 : 0.9,
              ),
              itemBuilder: (context, index) => CategoryGridCard(
                category: categories[index],
                onTap: () => _openCategory(categories[index]),
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _buildOffers() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionHeader(
        title: '✨ Wedding offers',
        subtitle: 'Thoughtful picks for every part of the day',
      ),
      SizedBox(
        height: 208,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          scrollDirection: Axis.horizontal,
          itemCount: _offers.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) => _OfferCard(
            offer: _offers[index],
            onTap: () => _openSearch(category: _offers[index].category),
          ),
        ),
      ),
    ],
  );

  Widget _buildAiAgent() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 4),
    child: Material(
      color: AppColors.primaryPlum,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AiAssistantScreen())),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.96, end: 1),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeInOut,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.brightGold,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Wedding Agent',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Plan your perfect wedding with AI.',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Budget · checklist · timeline · ideas',
                      style: TextStyle(color: Color(0xFFE4D9FF), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryPlum,
                ),
                child: const Text('Ask AI'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildJourney(List<Booking> upcoming) {
    final savedVendors = _repository.currentUserId == 'guest'
        ? <Vendor>[]
        : _repository.getWishlistedVendors();
    final savedCount = savedVendors.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: _repository.currentUserId == 'guest'
              ? 'Your Wedding Journey'
              : 'Your Wedding Journey, ${_repository.currentUserName.split(' ').first}',
          subtitle: 'A little progress makes the day feel closer',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: upcoming.isNotEmpty
              ? _UpcomingBookingCard(booking: upcoming.first)
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.plumTint,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.goldBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.primaryPlum,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Your wedding journey starts here 💍',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryPlum,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$savedCount vendors saved · Your upcoming bookings will show here.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VendorListingScreen(
                              initialCategory: 'All',
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.explore_outlined),
                        label: const Text('Start Planning'),
                      ),
                    ],
                  ),
                ),
        ),
        if (savedVendors.isNotEmpty) ...[
          const SectionHeader(
            title: 'Saved vendors',
            subtitle: 'Your favorites, ready when you are',
            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
          ),
          SizedBox(
            height: 182,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: savedVendors.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final vendor = savedVendors[index];
                return _TrendingCard(
                  vendor: vendor,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VendorDetailsScreen(vendor: vendor),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCulture() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionHeader(
        title: 'Tamil Nadu wedding culture',
        subtitle: 'Traditions that make every union your own',
      ),
      SizedBox(
        height: 198,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          scrollDirection: Axis.horizontal,
          itemCount: _culture.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) => _CultureCard(story: _culture[index]),
        ),
      ),
    ],
  );
}

class _TrendingCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onTap;
  const _TrendingCard({required this.vendor, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 158,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SafeNetworkImage(imageUrl: vendor.heroImage),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: AppColors.secondaryPurple,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            vendor.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryPlum,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vendor.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HomeOffer {
  final String title, detail, category, image, label;
  const _HomeOffer({
    required this.title,
    required this.detail,
    required this.category,
    required this.image,
    required this.label,
  });
}

class _OfferCard extends StatelessWidget {
  final _HomeOffer offer;
  final VoidCallback onTap;
  const _OfferCard({required this.offer, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 276,
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                SafeNetworkImage(imageUrl: offer.image),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPlum,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      offer.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryPlum,
                        ),
                      ),
                      Text(
                        offer.detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: onTap, child: const Text('View offer')),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _UpcomingBookingCard extends StatelessWidget {
  final Booking booking;
  const _UpcomingBookingCard({required this.booking});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.plumTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.primaryPlum,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UPCOMING BOOKING',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: AppColors.secondaryPurple,
                  ),
                ),
                Text(
                  booking.vendorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${booking.eventDate.day}/${booking.eventDate.month}/${booking.eventDate.year} · ${booking.status}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: AppColors.primaryPlum,
          ),
        ],
      ),
    ),
  );
}

class _CultureStory {
  final String title, subtitle, image, credit;
  final IconData icon;
  const _CultureStory({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.icon,
    required this.credit,
  });
}

class _CultureCard extends StatelessWidget {
  final _CultureStory story;
  const _CultureCard({required this.story});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 245,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          SafeNetworkImage(imageUrl: story.image),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.darkPlum.withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 12,
            bottom: 14,
            child: Row(
              children: [
                Icon(story.icon, color: AppColors.brightGold, size: 24),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        story.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFE4D9FF),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Photo: ${story.credit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD9CBEF),
                          fontSize: 8,
                        ),
                      ),
                    ],
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
