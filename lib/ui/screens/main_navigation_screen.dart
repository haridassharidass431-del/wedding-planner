import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/mock_wedding_repository.dart';
import 'categories/categories_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'vendors/vendor_listing_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  final MockWeddingRepository _repository = MockWeddingRepository();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repository,
      builder: (context, _) {
        final wishlistCount = _repository.wishlistVendorIds.length;

        final screens = [
          const HomeScreen(),
          const CategoriesScreen(),
          const VendorListingScreen(initialCategory: 'All'),
          const ProfileScreen(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                backgroundColor: Colors.white,
                indicatorColor: AppColors.plumTint,
                elevation: 0,
                height: 65,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
                    selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryPlum),
                    label: 'Home',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined, color: AppColors.textSecondary),
                    selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.primaryPlum),
                    label: 'Services',
                  ),
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: wishlistCount > 0,
                      label: Text('$wishlistCount', style: const TextStyle(fontSize: 10)),
                      backgroundColor: AppColors.royalGold,
                      textColor: AppColors.textOnGold,
                      child: const Icon(Icons.storefront_outlined, color: AppColors.textSecondary),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: wishlistCount > 0,
                      label: Text('$wishlistCount', style: const TextStyle(fontSize: 10)),
                      backgroundColor: AppColors.royalGold,
                      textColor: AppColors.textOnGold,
                      child: const Icon(Icons.storefront_rounded, color: AppColors.primaryPlum),
                    ),
                    label: 'Vendors',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                    selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryPlum),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
