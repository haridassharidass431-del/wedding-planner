import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/booking.dart';
import '../../../data/repositories/mock_wedding_repository.dart';
import '../auth/login_screen.dart';
import '../location/location_selection_screen.dart';
import '../vendors/vendor_listing_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showRoleSwitchDialog(BuildContext context, MockWeddingRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Switch Persona / Role', style: TextStyle(color: AppColors.primaryPlum, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _roleDialogItem(ctx, repo, AppConstants.roleCustomer, 'Customer (Couple/Family)', Icons.favorite_rounded),
              _roleDialogItem(ctx, repo, AppConstants.roleVendor, 'Wedding Vendor (Service Partner)', Icons.storefront_rounded),
              _roleDialogItem(ctx, repo, AppConstants.roleAdmin, 'Administrator (Marketplace Hub)', Icons.shield_rounded),
            ],
          ),
        );
      },
    );
  }

  Widget _roleDialogItem(BuildContext ctx, MockWeddingRepository repo, String role, String subtitle, IconData icon) {
    final isCurrent = repo.currentRole == role;
    return ListTile(
      leading: Icon(icon, color: isCurrent ? AppColors.royalGold : AppColors.primaryPlum),
      title: Text(role, style: TextStyle(fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: AppColors.royalGold) : null,
      onTap: () {
        repo.setCurrentRole(role);
        Navigator.pop(ctx);
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Switched view to $role perspective'),
            backgroundColor: AppColors.primaryPlum,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.royalGold, width: 1.5),
                ),
                child: ClipOval(
                  child: Image.asset(AppConstants.logoAssetPath, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              const Text('About Haventra', style: TextStyle(color: AppColors.primaryPlum, fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Haventra Wedding Planner is the premier luxury marketplace designed for auspicious weddings across the Cauvery Delta region.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              const Text(
                'Target Locations:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryPlum),
              ),
              const SizedBox(height: 4),
              Text(
                AppConstants.defaultLocations.join(' • '),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Developed & Powered by:',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const Text(
                AppConstants.companyName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.deepGold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: AppColors.primaryPlum, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = MockWeddingRepository();

    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final currentRole = repository.currentRole;
        final bookingsCount = repository.bookings.length;
        final wishlistCount = repository.wishlistVendorIds.length;
        final reviewsCount = repository.reviews.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () => _showAboutDialog(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            children: [
              // User Card with Gold Border
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.cardFoilGradient,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.goldBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.royalGold.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar with Gold Ring
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.goldGradient,
                          ),
                          child: const CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Name & Contact
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ananya & Vignesh',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                '+91 98400 12345 • ananya.v@email.com',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryPlum,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.stars_rounded, size: 12, color: AppColors.royalGold),
                                        const SizedBox(width: 4),
                                        Text(
                                          currentRole.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Hub: ${repository.selectedLocation}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.deepGold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: AppColors.borderLight),
                    const SizedBox(height: 10),

                    // Quick Counters Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _counterItem('$bookingsCount', 'Bookings'),
                        Container(width: 1, height: 28, color: AppColors.borderLight),
                        _counterItem('$wishlistCount', 'Shortlisted'),
                        Container(width: 1, height: 28, color: AppColors.borderLight),
                        _counterItem('$reviewsCount', 'Reviews'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Persona Switcher Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.plumTint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryPlum.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.switch_account_rounded, color: AppColors.primaryPlum),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active App Persona',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          Text(
                            '$currentRole View',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryPlum),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showRoleSwitchDialog(context, repository),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: AppColors.primaryPlum,
                      ),
                      child: const Text('Change Role', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent Booking Section
              const Text(
                'My Active Wedding Bookings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPlum,
                ),
              ),
              const SizedBox(height: 10),
              if (repository.bookings.isNotEmpty)
                ...repository.bookings.take(2).map((b) => _bookingCard(context, b))
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: const Text('No bookings yet. Explore wedding halls and services!'),
                ),
              const SizedBox(height: 20),

              // Account & Preferences Menu
              const Text(
                'Marketplace & Planning Settings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPlum,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _menuTile(
                      icon: Icons.location_on_outlined,
                      title: 'Change Active Service Hub',
                      subtitle: 'Current: ${repository.selectedLocation}',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LocationSelectionScreen()),
                        );
                      },
                    ),
                    _divider(),
                    _menuTile(
                      icon: Icons.favorite_border_rounded,
                      title: 'Saved & Shortlisted Vendors',
                      subtitle: '$wishlistCount vendors saved for your wedding',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VendorListingScreen(initialCategory: 'All'),
                          ),
                        );
                      },
                    ),
                    _divider(),
                    _menuTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About Haventra & Artigence Ai Hub',
                      subtitle: 'Version 1.0.0 • Royal Wedding Platform',
                      onTap: () => _showAboutDialog(context),
                    ),
                    _divider(),
                    _menuTile(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out / Switch Account',
                      subtitle: 'Return to login screen',
                      iconColor: AppColors.error,
                      textColor: AppColors.error,
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _counterItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryPlum,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _bookingCard(BuildContext context, Booking booking) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.plumTint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.id,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryPlum,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.vendorName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${booking.packageName} • ${booking.location}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date: ${DateFormat('dd MMM yyyy').format(booking.eventDate)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              Text(
                currencyFormatter.format(booking.totalPrice),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryPlum),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primaryPlum),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 56, color: AppColors.borderLight);
  }
}
