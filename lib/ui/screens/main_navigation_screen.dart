import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/mock_wedding_repository.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'vendors/vendor_listing_screen.dart';
import 'vendors/vendor_dashboard_screen.dart';
import 'role_screens.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _index;
  final _repo = MockWeddingRepository();
  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _repo,
    builder: (context, _) {
      final role = _repo.currentRole;
      final isCustomer = role == 'Customer';
      final isAdmin = role == 'Administrator';
      final isDesktop = MediaQuery.sizeOf(context).width >= 900;
      final customerPages = <Widget>[
        const HomeScreen(),
        const WeddingReelsScreen(),
        const VendorListingScreen(initialCategory: 'All'),
        const MyBookingsScreen(),
        const ProfileScreen(),
      ];
      final vendorMobilePages = <Widget>[
        const VendorBusinessDashboardScreen(),
        const WeddingReelsScreen(),
        const AddServiceScreen(),
        const MyBookingsScreen(vendorMode: true),
        const ProfileScreen(),
      ];
      final vendorDesktopPages = <Widget>[
        const VendorBusinessDashboardScreen(),
        const WeddingReelsScreen(),
        const AddServiceScreen(),
        const MyBookingsScreen(vendorMode: true),
        const VendorEarningsScreen(),
        const ProfileScreen(),
      ];
      final adminPages = <Widget>[
        const AdminDashboardScreen(),
        const AdminRequestsScreen(),
        const ProfileScreen(),
      ];
      final pages = isCustomer
          ? customerPages
          : isAdmin
          ? adminPages
          : isDesktop
          ? vendorDesktopPages
          : vendorMobilePages;
      final labels = isCustomer
          ? ['Home', 'Reels', 'Search', 'My Booking', 'Profile']
          : isAdmin
          ? ['Dashboard', 'Requests', 'Profile']
          : isDesktop
          ? [
              'Dashboard',
              'Reels',
              'Post Service',
              'Bookings',
              'Earnings',
              'Profile',
            ]
          : ['Home', 'Reels', 'Post', 'Bookings', 'Profile'];
      final icons = isCustomer
          ? [
              Icons.home_outlined,
              Icons.play_circle_outline,
              Icons.search,
              Icons.event_note_outlined,
              Icons.person_outline,
            ]
          : isAdmin
          ? [
              Icons.dashboard_outlined,
              Icons.fact_check_outlined,
              Icons.person_outline,
            ]
          : isDesktop
          ? [
              Icons.dashboard_outlined,
              Icons.play_circle_outline,
              Icons.add_box_outlined,
              Icons.event_note_outlined,
              Icons.account_balance_wallet_outlined,
              Icons.person_outline,
            ]
          : [
              Icons.home_outlined,
              Icons.play_circle_outline,
              Icons.add_rounded,
              Icons.event_note_outlined,
              Icons.person_outline,
            ];
      final selected = _index.clamp(0, pages.length - 1);
      if (isDesktop) {
        final destinations = List.generate(
          labels.length,
          (i) => NavigationRailDestination(
            icon: Icon(icons[i]),
            label: Text(labels[i]),
          ),
        );
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                NavigationRail(
                  extended: true,
                  selectedIndex: selected,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  indicatorColor: AppColors.plumTint,
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 28),
                    child: Row(
                      children: [
                        Image.asset(
                          AppConstants.logoAssetPath,
                          width: 34,
                          height: 34,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Haventra',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  destinations: destinations,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(index: selected, children: pages),
                ),
              ],
            ),
          ),
        );
      }
      if (isCustomer) {
        return Scaffold(
          body: IndexedStack(index: selected, children: pages),
          bottomNavigationBar: SafeArea(
            top: false,
            child: NavigationBar(
              height: 72,
              selectedIndex: selected,
              onDestinationSelected: (i) => setState(() => _index = i),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              indicatorColor: AppColors.plumTint,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: List.generate(
                labels.length,
                (i) => NavigationDestination(
                  icon: Icon(icons[i], size: 24),
                  selectedIcon: Icon(icons[i], size: 26),
                  label: labels[i],
                ),
              ),
            ),
          ),
        );
      }

      return Scaffold(
        body: IndexedStack(index: selected, children: pages),
        bottomNavigationBar: SafeArea(
          top: false,
          child: NavigationBar(
            height: 72,
            selectedIndex: selected,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            indicatorColor: AppColors.plumTint,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: List.generate(
              labels.length,
              (i) => NavigationDestination(
                icon: Icon(icons[i], size: 24),
                selectedIcon: Icon(icons[i], size: 26),
                label: labels[i],
              ),
            ),
          ),
        ),
      );
    },
  );
}
