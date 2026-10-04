import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/booking.dart';
import '../../../data/repositories/mock_wedding_repository.dart';
import '../../../core/widgets/safe_network_image.dart';
import '../auth/login_screen.dart';
import '../location/location_selection_screen.dart';
import '../vendors/vendor_listing_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                  child: Image.asset(
                    AppConstants.logoAssetPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'About Haventra',
                style: TextStyle(
                  color: AppColors.primaryPlum,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
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
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPlum,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppConstants.defaultLocations.join(' • '),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepGold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primaryPlum,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentRole) {
    final repository = MockWeddingRepository();
    final isVendor = currentRole == AppConstants.roleVendor;
    final profile = isVendor
        ? repository.vendorProfile
        : repository.customerProfile;

    final firstNameController = TextEditingController(
      text: profile['firstName'] ?? profile['ownerFirstName'] ?? '',
    );
    final lastNameController = TextEditingController(
      text: profile['lastName'] ?? profile['ownerLastName'] ?? '',
    );
    final emailController = TextEditingController(text: profile['email'] ?? '');
    final phoneController = TextEditingController(text: profile['phone'] ?? '');
    final addressController = TextEditingController(
      text: profile['address'] ?? '',
    );
    final cityController = TextEditingController(text: profile['city'] ?? '');
    final districtController = TextEditingController(
      text: profile['district'] ?? '',
    );
    final pincodeController = TextEditingController(
      text: profile['pincode'] ?? '',
    );
    final dateOfBirthController = TextEditingController(
      text: profile['dateOfBirth'] ?? '',
    );
    final businessNameController = TextEditingController(
      text: profile['businessName'] ?? '',
    );
    final categoryController = TextEditingController(
      text: profile['category'] ?? '',
    );
    final businessDescriptionController = TextEditingController(
      text: profile['description'] ?? '',
    );
    final servicesController = TextEditingController(
      text: profile['services'] ?? '',
    );
    final budgetController = TextEditingController(
      text: profile['budgetRange'] ?? '',
    );
    final capacityController = TextEditingController(
      text: profile['capacity'] ?? '',
    );
    final facilitiesController = TextEditingController(
      text: profile['facilities'] ?? '',
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          repository.isTamil ? 'சுயவிவரத்தை திருத்து' : 'Edit Profile',
        ),
        content: SizedBox(
          width: 520,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isVendor) ...[
                    TextFormField(
                      controller: businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Business name required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'Owner First Name',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Owner Last Name',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Full Business Address',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: cityController,
                            decoration: const InputDecoration(
                              labelText: 'City / Town',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: districtController,
                            decoration: const InputDecoration(
                              labelText: 'District',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: pincodeController,
                      decoration: const InputDecoration(labelText: 'Pincode'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: businessDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Business Description',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: servicesController,
                      decoration: const InputDecoration(labelText: 'Services'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Price / Budget Range',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: capacityController,
                      decoration: const InputDecoration(labelText: 'Capacity'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: facilitiesController,
                      decoration: const InputDecoration(
                        labelText: 'Facilities',
                      ),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'First name required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Last name required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: dateOfBirthController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.tryParse(dateOfBirthController.text) ??
                              DateTime.now().subtract(
                                const Duration(days: 3650),
                              ),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          dateOfBirthController.text = DateFormat(
                            'yyyy-MM-dd',
                          ).format(picked);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Full Address',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: cityController,
                            decoration: const InputDecoration(
                              labelText: 'City / Town',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: districtController,
                            decoration: const InputDecoration(
                              labelText: 'District',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: pincodeController,
                      decoration: const InputDecoration(labelText: 'Pincode'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(repository.isTamil ? 'நீக்கு' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                if (isVendor) {
                  repository.updateVendorProfile({
                    'businessName': businessNameController.text.trim(),
                    'ownerFirstName': firstNameController.text.trim(),
                    'ownerLastName': lastNameController.text.trim(),
                    'email': emailController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'address': addressController.text.trim(),
                    'city': cityController.text.trim(),
                    'district': districtController.text.trim(),
                    'pincode': pincodeController.text.trim(),
                    'category': categoryController.text.trim(),
                    'description': businessDescriptionController.text.trim(),
                    'services': servicesController.text.trim(),
                    'budgetRange': budgetController.text.trim(),
                    'capacity': capacityController.text.trim(),
                    'facilities': facilitiesController.text.trim(),
                  });
                } else {
                  repository.updateCustomerProfile({
                    'firstName': firstNameController.text.trim(),
                    'lastName': lastNameController.text.trim(),
                    'dateOfBirth': dateOfBirthController.text.trim(),
                    'email': emailController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'address': addressController.text.trim(),
                    'city': cityController.text.trim(),
                    'district': districtController.text.trim(),
                    'pincode': pincodeController.text.trim(),
                  });
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      repository.isTamil
                          ? 'சுயவிவரம் புதுப்பிக்கப்பட்டது'
                          : 'Profile updated successfully',
                    ),
                    backgroundColor: AppColors.primaryPlum,
                  ),
                );
              }
            },
            child: Text(repository.isTamil ? 'சேமி' : 'Save Changes'),
          ),
        ],
      ),
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
        final profile = currentRole == AppConstants.roleVendor
            ? repository.vendorProfile
            : repository.customerProfile;
        final pendingRequests = repository.getPendingBookingRequests();

        final firstName =
            (profile['firstName'] ?? profile['ownerFirstName'] ?? 'Guest')
                .toString();
        final lastName = (profile['lastName'] ?? profile['ownerLastName'] ?? '')
            .toString();
        final companyName = (profile['businessName'] ?? '').toString();
        final nameText =
            currentRole == AppConstants.roleVendor && companyName.isNotEmpty
            ? companyName
            : '$firstName $lastName'.trim();
        final profilePhoto = (profile['profilePhoto'] ?? '').toString();
        final avatarUrl = profilePhoto.isNotEmpty
            ? profilePhoto
            : currentRole == AppConstants.roleVendor
            ? 'https://images.unsplash.com/photo-1556740749-887f6717d7e4?auto=format&fit=crop&w=300&q=80'
            : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80';

        return Scaffold(
          appBar: AppBar(
            title: Text(repository.isTamil ? 'என் சுயவிவரம்' : 'My Profile'),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Notifications'),
                          content: SizedBox(
                            width: 260,
                            child: Text(
                              repository.notifications.isEmpty
                                  ? 'No notifications yet.'
                                  : repository.notifications.first.message,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (repository.unreadNotifications.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: AppColors.royalGold,
                        child: Text(
                          '${repository.unreadNotifications.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () => _showAboutDialog(context),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardFoilGradient,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.goldBorder,
                        width: 1.2,
                      ),
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
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.goldGradient,
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  avatarUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: AppColors.plumTint,
                                    child: Icon(
                                      currentRole == AppConstants.roleVendor
                                          ? Icons.storefront_rounded
                                          : Icons.person_rounded,
                                      color: AppColors.primaryPlum,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nameText,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${profile['phone']} • ${profile['email']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryPlum,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.stars_rounded,
                                              size: 12,
                                              color: AppColors.royalGold,
                                            ),
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
                                      Flexible(
                                        child: Text(
                                          currentRole == AppConstants.roleVendor
                                              ? '${profile['city']}, ${profile['district']}, Tamil Nadu'
                                              : 'Hub: ${repository.selectedLocation}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.deepGold,
                                          ),
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
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showEditProfileDialog(context, currentRole),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(
                              repository.isTamil
                                  ? 'சுயவிவரத்தை திருத்து'
                                  : 'Edit Profile',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.borderLight),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _counterItem(
                              '$bookingsCount',
                              repository.isTamil ? 'முன்பதிவுகள்' : 'Bookings',
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: AppColors.borderLight,
                            ),
                            _counterItem(
                              '$wishlistCount',
                              repository.isTamil ? 'சேமித்தவை' : 'Shortlisted',
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: AppColors.borderLight,
                            ),
                            _counterItem(
                              '$reviewsCount',
                              repository.isTamil ? 'மதிப்புரைகள்' : 'Reviews',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (currentRole == AppConstants.roleVendor)
                    _vendorRequestPanel(context, repository, pendingRequests),
                  if (currentRole == AppConstants.roleVendor)
                    _vendorBusinessSections(repository, profile),
                  if (currentRole != AppConstants.roleVendor)
                    _customerBookingSummary(repository, repository.bookings),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          color: AppColors.primaryPlum,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Language / மொழி',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: false, label: Text('English')),
                            ButtonSegment(value: true, label: Text('தமிழ்')),
                          ],
                          selected: {repository.isTamil},
                          onSelectionChanged: (value) =>
                              repository.setTamil(value.first),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                              MaterialPageRoute(
                                builder: (_) => const LocationSelectionScreen(),
                              ),
                            );
                          },
                        ),
                        _divider(),
                        _menuTile(
                          icon: Icons.favorite_border_rounded,
                          title: 'Saved & Shortlisted Vendors',
                          subtitle:
                              '${repository.wishlistVendorIds.length} vendors saved for your wedding',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const VendorListingScreen(
                                  initialCategory: 'All',
                                ),
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
                            repository.logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _vendorBusinessSections(
    MockWeddingRepository repository,
    Map<String, dynamic> profile,
  ) {
    final services = repository.myServices;
    final approvedServiceCount = services
        .where((service) => service['status'] == 'approved')
        .length;
    final imageUrls = <String>{
      ...((profile['galleryImages'] as List?) ?? const []).map(
        (image) => image.toString(),
      ),
      ...services.expand(
        (service) => (service['images'] as List? ?? const []).map(
          (image) => image.toString(),
        ),
      ),
    }.where((image) => image.isNotEmpty).toList();
    final hours = (profile['businessHours'] ?? '').toString();
    final experience = (profile['experienceYears'] as num?)?.toInt() ?? 0;
    final rating = (profile['rating'] as num?)?.toDouble() ?? 0;
    final isVerified = profile['isVerified'] == true;

    Widget infoCard(String title, Widget content) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryPlum,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        infoCard(
          'About',
          Text(
            (profile['description'] ?? 'Add an introduction to your business.')
                .toString(),
          ),
        ),
        const SizedBox(height: 10),
        infoCard(
          'Business details',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Services: ${(profile['services'] ?? 'Add your services').toString()}',
              ),
              const SizedBox(height: 5),
              Text(
                'Location: ${profile['city'] ?? ''}, ${profile['district'] ?? ''}, Tamil Nadu',
              ),
              const SizedBox(height: 5),
              Text(
                'Area / pincode: ${profile['area']?.toString().isNotEmpty == true ? profile['area'] : 'Not added'} · ${profile['pincode']?.toString().isNotEmpty == true ? profile['pincode'] : 'No pincode'}',
              ),
              const SizedBox(height: 5),
              Text(
                'Business hours: ${hours.isEmpty ? 'Not added yet' : hours}',
              ),
              const SizedBox(height: 5),
              Text(
                'Experience: ${experience > 0 ? '$experience years' : 'Not added yet'}',
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.secondaryPurple,
                    size: 18,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      rating > 0 ? rating.toStringAsFixed(1) : 'Not rated',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isVerified
                        ? Icons.verified_rounded
                        : Icons.hourglass_top_rounded,
                    color: AppColors.primaryPlum,
                    size: 17,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      isVerified
                          ? 'Verified vendor'
                          : approvedServiceCount > 0
                          ? '$approvedServiceCount service(s) approved'
                          : 'Approval required',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        infoCard(
          'Services',
          services.isEmpty
              ? const Text(
                  'Your submitted services and their approval status will appear here.',
                )
              : Column(
                  children: services
                      .map(
                        (service) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(service['name'].toString()),
                          subtitle: Text(
                            '${service['category']} · ${service['status']}',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 10),
        infoCard(
          'Gallery',
          imageUrls.isEmpty
              ? const Text(
                  'Approved service photos will appear in your business gallery.',
                )
              : SizedBox(
                  height: 108,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageUrls.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => SizedBox(
                      width: 132,
                      child: SafeNetworkImage(
                        imageUrl: imageUrls[index],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _customerBookingSummary(
    MockWeddingRepository repo,
    List<Booking> bookings,
  ) {
    final visible = bookings.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryPlum,
          ),
        ),
        const SizedBox(height: 10),
        if (visible.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Text(
              'No bookings yet. Explore wedding halls and services!',
            ),
          )
        else
          ...visible.map((booking) => _bookingCard(booking)),
      ],
    );
  }

  Widget _vendorRequestPanel(
    BuildContext context,
    MockWeddingRepository repo,
    List<Booking> pendingRequests,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking Requests',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryPlum,
          ),
        ),
        const SizedBox(height: 10),
        if (pendingRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Text('No pending booking requests right now.'),
          )
        else
          ...pendingRequests.map(
            (booking) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softChampagne,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.status,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${booking.customerContact} • ${booking.hallName}'),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(booking.eventDate)} • ${booking.timeSlot}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Guests: ${booking.guestCount} • Notes: ${booking.customerMessage.isEmpty ? 'No notes' : booking.customerMessage}',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final accepted = repo.acceptBookingRequest(
                              booking.id,
                            );
                            if (accepted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Booking accepted and confirmed.',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Booking could not be accepted because the date is no longer available.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Accept'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            repo.declineBookingRequest(
                              booking.id,
                              reason: 'No longer available',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Booking request declined.'),
                              ),
                            );
                          },
                          child: const Text('Decline'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
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
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _bookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.vendorName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.plumTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPlum,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${booking.location} • ${DateFormat('dd MMM yyyy').format(booking.eventDate)}',
          ),
          const SizedBox(height: 6),
          Text('Reference: ${booking.id} • ${booking.packageName}'),
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
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 56, color: AppColors.borderLight);
  }
}
