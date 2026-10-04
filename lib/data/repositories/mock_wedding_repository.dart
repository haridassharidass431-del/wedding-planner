import 'package:flutter/material.dart';
import '../models/service_category.dart';
import '../models/vendor.dart';
import '../models/booking.dart';
import '../models/review.dart';
import '../models/location.dart';
import '../models/app_notification.dart';
import '../models/vendor_earnings.dart';

class MockWeddingRepository extends ChangeNotifier {
  static final MockWeddingRepository _instance =
      MockWeddingRepository._internal();
  factory MockWeddingRepository() => _instance;
  MockWeddingRepository._internal() {
    _accounts['admin@haventra.local'] = {
      'name': 'Haventra Admin',
      'email': 'admin@haventra.local',
      'username': 'admin',
      'password': 'Admin123!',
      'role': 'Administrator',
    };
    _initializeData();
  }

  String _selectedLocation = 'Thiruvarur';
  String get selectedLocation => _selectedLocation;

  String _currentRole = 'Customer';
  String get currentRole => _currentRole;
  String currentUserName = 'Guest';
  String currentUsername = 'guest';
  String currentEmail = '';
  String currentUserId = 'guest';

  final Map<String, Map<String, String>> _accounts = {};
  final List<Map<String, dynamic>> _services = [];
  int _serviceSequence = 0;
  List<Map<String, dynamic>> get services => List.unmodifiable(_services);

  bool registerAccount({
    required String name,
    required String email,
    required String username,
    required String password,
    required String role,
  }) {
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key) ||
        (role != 'Customer' && role != 'Wedding Vendor')) {
      return false;
    }
    _accounts[key] = {
      'name': name.trim(),
      'email': key,
      'username': username.trim(),
      'password': password,
      'role': role,
    };
    notifyListeners();
    return true;
  }

  bool login({required String email, required String password}) {
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account['password'] != password) {
      return false;
    }
    currentUserName = account['name']!;
    currentUsername = account['username']!;
    currentEmail = account['email']!;
    currentUserId = account['email']!;
    setCurrentRole(account['role']!);
    final nameParts = currentUserName.split(RegExp(r'\s+'));
    if (_currentRole == 'Wedding Vendor') {
      _vendorProfile = {
        ..._vendorProfile,
        'businessName': currentUserName,
        'ownerFirstName': nameParts.first,
        'ownerLastName': nameParts.skip(1).join(' '),
        'username': currentUsername,
        'email': currentEmail,
      };
    } else {
      _customerProfile = {
        ..._customerProfile,
        'firstName': nameParts.first,
        'lastName': nameParts.skip(1).join(' '),
        'username': currentUsername,
        'email': currentEmail,
      };
    }
    notifyListeners();
    return true;
  }

  void logout() {
    currentUserName = 'Guest';
    currentUsername = 'guest';
    currentEmail = '';
    currentUserId = 'guest';
    setCurrentRole('Customer');
  }

  String? submitService({
    required String name,
    required String description,
    required String category,
    required String location,
    required double price,
    required List<String> images,
  }) {
    if (_currentRole != 'Wedding Vendor') return null;
    final place = TamilNaduLocationCatalog.places
        .where(
          (item) => item.city.toLowerCase() == location.trim().toLowerCase(),
        )
        .firstOrNull;
    final service = <String, dynamic>{
      'id': 'SV-${DateTime.now().millisecondsSinceEpoch}-${++_serviceSequence}',
      'vendorId': currentUserId,
      'vendorName': currentUserName,
      'name': name,
      'description': description,
      'category': category,
      'location': location,
      'city': place?.city ?? location,
      'district': place?.district ?? location,
      'area': '',
      'pincode': '',
      'price': price,
      'images': images,
      'status': 'pending',
      'submittedAt': DateTime.now(),
      'rejectionReason': '',
    };
    _services.insert(0, service);
    notifyListeners();
    return service['id'] as String;
  }

  bool updateService({
    required String id,
    required String name,
    required String description,
    required String category,
    required String location,
    required double price,
    required List<String> images,
  }) {
    if (_currentRole != 'Wedding Vendor') return false;
    final index = _services.indexWhere(
      (service) => service['id'] == id && service['vendorId'] == currentUserId,
    );
    if (index < 0) return false;
    final place = TamilNaduLocationCatalog.places
        .where(
          (item) => item.city.toLowerCase() == location.trim().toLowerCase(),
        )
        .firstOrNull;
    _services[index] = {
      ..._services[index],
      'name': name,
      'description': description,
      'category': category,
      'location': location,
      'city': place?.city ?? location,
      'district': place?.district ?? location,
      'price': price,
      'images': images,
      'status': 'pending',
      'submittedAt': DateTime.now(),
      'rejectionReason': '',
    };
    notifyListeners();
    return true;
  }

  bool reviewService(String id, {required bool approve, String reason = ''}) {
    if (_currentRole != 'Administrator') return false;
    final index = _services.indexWhere(
      (service) => service['id'] == id && service['status'] == 'pending',
    );
    if (index < 0) return false;
    _services[index] = {
      ..._services[index],
      'status': approve ? 'approved' : 'rejected',
      'rejectionReason': reason,
    };
    notifyListeners();
    return true;
  }

  List<Map<String, dynamic>> get publicServices =>
      _services.where((service) => service['status'] == 'approved').toList();
  List<Map<String, dynamic>> get myServices => _services
      .where((service) => service['vendorId'] == currentUserId)
      .toList();
  List<Map<String, dynamic>> get pendingServices =>
      _currentRole == 'Administrator'
      ? _services.where((service) => service['status'] == 'pending').toList()
      : const [];

  Map<String, dynamic> _customerProfile = {
    'profilePhoto':
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
    'firstName': 'Ananya',
    'lastName': 'Vignesh',
    'dateOfBirth': '1994-05-14',
    'email': 'ananya.v@email.com',
    'phone': '+91 98400 12345',
    'address': '12 Temple Street',
    'city': 'Thiruvarur',
    'district': 'Thiruvarur',
    'pincode': '610001',
    'preferredLanguage': 'English',
  };

  Map<String, dynamic> _vendorProfile = {
    'profilePhoto': '',
    'businessName': 'Haventra Wedding Venue',
    'ownerFirstName': 'Sundar',
    'ownerLastName': 'Rajan',
    'email': 'vendor@haventra.com',
    'phone': '+91 90000 11111',
    'address': 'Main Road, Thiruvarur',
    'city': 'Thiruvarur',
    'district': 'Thiruvarur',
    'area': 'Main Road',
    'pincode': '610001',
    'category': 'Wedding Halls',
    'description':
        'Luxury wedding venue with heritage mandapam and premium event support.',
    'services': 'Hall booking, catering, decor support',
    'budgetRange': '₹1,20,000 - ₹2,40,000',
    'capacity': '1500 guests',
    'facilities': 'Parking, bridal suite, AC, generator',
    'businessHours': '',
    'experienceYears': 0,
    'rating': 0.0,
    'isVerified': false,
    'galleryImages': <String>[],
    'preferredLanguage': 'English',
  };

  Map<String, dynamic> get customerProfile => _customerProfile;
  Map<String, dynamic> get vendorProfile => _vendorProfile;

  bool _isTamil = false;
  bool get isTamil => _isTamil;

  final Set<String> _wishlistVendorIds = {'v1', 'v3', 'v5'};
  Set<String> get wishlistVendorIds => _wishlistVendorIds;

  late List<ServiceCategory> _categories;
  List<ServiceCategory> get categories => _categories;

  late List<ServiceLocation> _locations;
  List<ServiceLocation> get locations => _locations;

  late List<Vendor> _vendors;
  List<Vendor> get vendors => _vendors;

  late List<Booking> _bookings;
  List<Booking> get bookings => _bookings;

  late List<Review> _reviews;
  List<Review> get reviews => _reviews;

  late List<AppNotificationItem> _notifications;
  List<AppNotificationItem> get notifications => _notifications;

  void setSelectedLocation(String location) {
    if (_selectedLocation != location) {
      _selectedLocation = location;
      notifyListeners();
    }
  }

  bool matchesLocation(String vendorLocation, String selectedLocation) {
    if (selectedLocation.isEmpty || selectedLocation == 'All Locations') {
      return true;
    }
    final vendor = vendorLocation.trim().toLowerCase();
    final selected = selectedLocation.trim().toLowerCase();
    if (vendor == selected || vendor.contains(selected)) return true;
    final selectedPlaces = TamilNaduLocationCatalog.places.where(
      (place) =>
          place.city.toLowerCase() == selected ||
          place.district.toLowerCase() == selected,
    );
    final vendorPlace = TamilNaduLocationCatalog.places.where(
      (place) =>
          place.city.toLowerCase() == vendor ||
          place.district.toLowerCase() == vendor,
    );
    return selectedPlaces.any(
      (selectedPlace) => vendorPlace.any(
        (vendorPlace) => selectedPlace.district == vendorPlace.district,
      ),
    );
  }

  List<Booking> getVendorBookings() {
    final serviceIds = myServices.map((service) => service['id']).toSet();
    return _bookings
        .where(
          (booking) =>
              booking.vendorId == currentUserId ||
              serviceIds.contains(booking.vendorId),
        )
        .toList();
  }

  VendorEarningsSummary get vendorEarnings =>
      VendorEarningsSummary(bookings: getVendorBookings());

  void setCurrentRole(String role) {
    if (role != 'Customer' &&
        role != 'Wedding Vendor' &&
        role != 'Administrator') {
      return;
    }
    if (_currentRole != role) {
      _currentRole = role;
      notifyListeners();
    }
  }

  void setTamil(bool value) {
    if (_isTamil != value) {
      _isTamil = value;
      notifyListeners();
    }
  }

  void updateCustomerProfile(Map<String, dynamic> values) {
    _customerProfile = {..._customerProfile, ...values};
    notifyListeners();
  }

  void updateVendorProfile(Map<String, dynamic> values) {
    _vendorProfile = {..._vendorProfile, ...values};
    notifyListeners();
  }

  void toggleWishlist(String vendorId) {
    if (_wishlistVendorIds.contains(vendorId)) {
      _wishlistVendorIds.remove(vendorId);
    } else {
      _wishlistVendorIds.add(vendorId);
    }
    notifyListeners();
  }

  bool isWishlisted(String vendorId) => _wishlistVendorIds.contains(vendorId);

  List<Vendor> getVendorsForCurrentLocation({String? category}) {
    return _vendors.where((v) {
      final locationMatches = matchesLocation(v.location, _selectedLocation);
      final matchesCategory =
          category == null ||
          v.category.toLowerCase() == category.toLowerCase();
      return locationMatches && matchesCategory;
    }).toList();
  }

  List<Vendor> getFeaturedVendors() {
    return _vendors.where((v) => v.isFeatured).toList();
  }

  List<Vendor> getWishlistedVendors() {
    return _vendors.where((v) => _wishlistVendorIds.contains(v.id)).toList();
  }

  Vendor? getVendorById(String id) {
    try {
      return _vendors.firstWhere((v) => v.id == id);
    } catch (_) {
      return _vendors.isNotEmpty ? _vendors.first : null;
    }
  }

  List<Review> getReviewsForVendor(String vendorId) {
    return _reviews.where((r) => r.vendorId == vendorId).toList();
  }

  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isDateAvailable(
    String vendorId,
    DateTime date, {
    String? excludeBookingId,
  }) {
    final normalized = DateTime(date.year, date.month, date.day);
    final blockedStatuses = {'Pending', 'Confirmed', 'Completed'};

    return !_bookings.any((booking) {
      if (booking.vendorId != vendorId) return false;
      if (booking.id == excludeBookingId) return false;

      final bookingDay = DateTime(
        booking.eventDate.year,
        booking.eventDate.month,
        booking.eventDate.day,
      );

      return bookingDay == normalized &&
          blockedStatuses.contains(booking.status);
    });
  }

  List<DateTime> getAvailableDatesForVendor(
    String vendorId, {
    int daysAhead = 60,
  }) {
    final today = DateTime.now();
    final dates = <DateTime>[];
    for (int i = 0; i < daysAhead; i++) {
      final date = DateTime(today.year, today.month, today.day + i);
      if (isDateAvailable(vendorId, date)) {
        dates.add(date);
      }
    }
    return dates;
  }

  List<Booking> getPendingBookingRequests({String? vendorId}) {
    return _bookings.where((booking) {
      final matchesVendor = vendorId == null || booking.vendorId == vendorId;
      return matchesVendor && booking.status == 'Pending';
    }).toList();
  }

  bool completeVendorBooking(String bookingId) {
    if (_currentRole != 'Wedding Vendor') return false;
    final serviceIds = myServices.map((service) => service['id']).toSet();
    final index = _bookings.indexWhere(
      (booking) =>
          booking.id == bookingId &&
          (booking.vendorId == currentUserId ||
              serviceIds.contains(booking.vendorId)) &&
          booking.status == 'Confirmed',
    );
    if (index < 0) return false;
    _bookings[index] = _bookings[index].copyWith(
      status: 'Completed',
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  List<AppNotificationItem> get unreadNotifications =>
      _notifications.where((item) => !item.isRead).toList();

  void markNotificationRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  Booking? submitBookingRequest({
    required String vendorId,
    required String hallName,
    required String customerName,
    required String customerContact,
    required DateTime bookingDate,
    required String requestedTime,
    required int guestCount,
    String customerMessage = '',
    String? packageName,
    String? venueLocation,
    String? vendorName,
    String? vendorCategory,
    String? vendorImage,
    double totalPrice = 0,
  }) {
    final vendor = getVendorById(vendorId);
    if (vendor == null) return null;
    if (bookingDate.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    )) {
      return null;
    }
    if (!isDateAvailable(vendorId, bookingDate)) {
      return null;
    }

    final bookingId = 'BK-${DateTime.now().millisecondsSinceEpoch % 9000000}';
    final newBooking = Booking(
      id: bookingId,
      vendorId: vendorId,
      vendorName: vendorName ?? vendor.name,
      vendorCategory: vendorCategory ?? vendor.category,
      vendorImage: vendorImage ?? vendor.heroImage,
      location: venueLocation ?? vendor.location,
      packageName: packageName ?? 'Standard Booking',
      eventDate: bookingDate,
      timeSlot: requestedTime,
      guestCount: guestCount,
      totalPrice: totalPrice,
      status: 'Pending',
      bookingDate: DateTime.now(),
      hallName: hallName,
      customerName: customerName,
      customerId: currentUserId,
      customerContact: customerContact,
      customerMessage: customerMessage,
      specialNotes: customerMessage,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _bookings.insert(0, newBooking);
    _notifications.insert(
      0,
      AppNotificationItem(
        id: 'notify_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Booking request submitted',
        message:
            'Your request for ${vendor.name} on ${_formatDate(bookingDate)} is pending vendor review.',
        relatedBookingId: bookingId,
        createdAt: DateTime.now(),
      ),
    );
    _notifications.insert(
      0,
      AppNotificationItem(
        id: 'notify_vendor_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New booking request',
        message:
            '$customerName requested ${vendor.name} on ${_formatDate(bookingDate)}.',
        relatedBookingId: bookingId,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return newBooking;
  }

  bool acceptBookingRequest(String bookingId) {
    final booking = getBookingById(bookingId);
    if (booking == null) return false;
    if (!isDateAvailable(
      booking.vendorId,
      booking.eventDate,
      excludeBookingId: bookingId,
    )) {
      final otherConfirmed = _bookings.any((item) {
        if (item.id == bookingId) return false;
        final sameDay =
            item.vendorId == booking.vendorId &&
            item.eventDate.year == booking.eventDate.year &&
            item.eventDate.month == booking.eventDate.month &&
            item.eventDate.day == booking.eventDate.day;
        return sameDay && item.status == 'Confirmed';
      });
      if (otherConfirmed) {
        return false;
      }
    }

    final index = _bookings.indexWhere((item) => item.id == bookingId);
    if (index < 0) return false;
    _bookings[index] = _bookings[index].copyWith(
      status: 'Confirmed',
      vendorResponse: 'Accepted by vendor',
      updatedAt: DateTime.now(),
    );
    _notifications.insert(
      0,
      AppNotificationItem(
        id: 'notify_accept_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Booking accepted',
        message:
            'Your booking for ${booking.vendorName} on ${_formatDate(booking.eventDate)} has been confirmed.',
        relatedBookingId: bookingId,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }

  bool declineBookingRequest(String bookingId, {String reason = ''}) {
    final index = _bookings.indexWhere((item) => item.id == bookingId);
    if (index < 0) return false;
    _bookings[index] = _bookings[index].copyWith(
      status: 'Declined',
      declineReason: reason,
      updatedAt: DateTime.now(),
    );
    _notifications.insert(
      0,
      AppNotificationItem(
        id: 'notify_decline_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Booking declined',
        message:
            'Your booking request for ${_bookings[index].vendorName} was declined${reason.isNotEmpty ? ': $reason' : ''}.',
        relatedBookingId: bookingId,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }

  void addReview(Review review) {
    _reviews.insert(0, review);
    notifyListeners();
  }

  List<Booking> getCustomerBookings(String customerName) {
    return _bookings
        .where((booking) => booking.customerId == currentUserId)
        .toList();
  }

  List<Vendor> searchVendors(
    String query, {
    String? category,
    String? location,
    double? maxPrice,
    double? minRating,
  }) {
    return _vendors.where((v) {
      final matchesQuery =
          query.isEmpty ||
          v.name.toLowerCase().contains(query.toLowerCase()) ||
          v.category.toLowerCase().contains(query.toLowerCase()) ||
          v.location.toLowerCase().contains(query.toLowerCase());

      final matchesCategory =
          category == null ||
          category == 'All' ||
          v.category.toLowerCase() == category.toLowerCase();
      final isLocationMatch =
          location == null ||
          location == 'All' ||
          matchesLocation(v.location, location);
      final matchesPrice = maxPrice == null || v.startingPrice <= maxPrice;
      final matchesRating = minRating == null || v.rating >= minRating;

      return matchesQuery &&
          matchesCategory &&
          isLocationMatch &&
          matchesPrice &&
          matchesRating;
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _initializeData() {
    _categories = [
      const ServiceCategory(
        id: 'c1',
        name: 'Wedding Halls',
        subtitle: 'Royal Mandapams & Palaces',
        icon: Icons.castle_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=600&q=80',
        vendorCount: 42,
        startingPrice: 75000,
        priceUnit: 'per day',
        isPopular: true,
      ),
      const ServiceCategory(
        id: 'c2',
        name: 'Photography',
        subtitle: 'Cinematic & Candid Moments',
        icon: Icons.camera_alt_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=600&q=80',
        vendorCount: 56,
        startingPrice: 40000,
        priceUnit: 'per event',
        isPopular: true,
      ),
      const ServiceCategory(
        id: 'c3',
        name: 'Catering',
        subtitle: 'Authentic Traditional Feasts',
        icon: Icons.restaurant_menu_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=80',
        vendorCount: 38,
        startingPrice: 350,
        priceUnit: 'per plate',
        isPopular: true,
      ),
      const ServiceCategory(
        id: 'c4',
        name: 'Decoration',
        subtitle: 'Floral & Thematic Stages',
        icon: Icons.auto_awesome_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=600&q=80',
        vendorCount: 45,
        startingPrice: 30000,
        priceUnit: 'per setup',
        isPopular: true,
      ),
      const ServiceCategory(
        id: 'c5',
        name: 'Makeup',
        subtitle: 'Bridal & Groom Styling',
        icon: Icons.brush_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=600&q=80',
        vendorCount: 29,
        startingPrice: 15000,
        priceUnit: 'per session',
      ),
      const ServiceCategory(
        id: 'c6',
        name: 'Bridal Wear',
        subtitle: 'Pure Kanchipuram Silks',
        icon: Icons.woman_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=600&q=80',
        vendorCount: 24,
        startingPrice: 18000,
        priceUnit: 'starting from',
      ),
      const ServiceCategory(
        id: 'c7',
        name: 'Groom Wear',
        subtitle: 'Royal Sherwanis & Silk Dhotis',
        icon: Icons.man_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=600&q=80',
        vendorCount: 18,
        startingPrice: 12000,
        priceUnit: 'starting from',
      ),
      const ServiceCategory(
        id: 'c8',
        name: 'Wedding Invitations',
        subtitle: 'Traditional & Digital Cards',
        icon: Icons.mark_email_read_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=600&q=80',
        vendorCount: 31,
        startingPrice: 45,
        priceUnit: 'per card',
      ),
      const ServiceCategory(
        id: 'c9',
        name: 'Other Wedding Services',
        subtitle: 'Nadaswaram, DJ, Vintage Cars',
        icon: Icons.celebration_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?auto=format&fit=crop&w=600&q=80',
        vendorCount: 22,
        startingPrice: 10000,
        priceUnit: 'per service',
      ),
    ];

    _locations = [
      const ServiceLocation(
        id: 'loc_thiruvarur',
        name: 'Thiruvarur',
        district: 'Thiruvarur District',
        tagline: 'The Temple Chariot Capital & Heritage Mandapams',
        description:
            'Famous for grand classical marriage halls, rich heritage rituals, and temple view wedding setups.',
        totalVendors: 68,
        weddingHallsCount: 22,
        imageUrl:
            'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=600&q=80',
        isFeatured: true,
      ),
      const ServiceLocation(
        id: 'loc_nagapattinam',
        name: 'Nagapattinam',
        district: 'Nagapattinam District',
        tagline: 'Coastal Elegance & Grand Seaside Celebrations',
        description:
            'Vibrant coastal destination offering modern convention centers and beachside wedding venues.',
        totalVendors: 54,
        weddingHallsCount: 18,
        imageUrl:
            'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=600&q=80',
        isFeatured: true,
      ),
      const ServiceLocation(
        id: 'loc_thanjavur',
        name: 'Thanjavur',
        district: 'Thanjavur District',
        tagline: 'The Chola Royal Capital of Weddings',
        description:
            'The pinnacle of Cauvery Delta luxury, housing palatial mandapams, premier silk ateliers, and legendary feasts.',
        totalVendors: 112,
        weddingHallsCount: 38,
        imageUrl:
            'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=600&q=80',
        isFeatured: true,
      ),
      const ServiceLocation(
        id: 'loc_mayiladuthurai',
        name: 'Mayiladuthurai',
        district: 'Mayiladuthurai District',
        tagline: 'Traditional Delta Sacred Union Hub',
        description:
            'Renowned for Vedic traditional ceremonies, classic Cauvery riverbank venues, and authentic culinary masters.',
        totalVendors: 49,
        weddingHallsCount: 16,
        imageUrl:
            'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=80',
      ),
      const ServiceLocation(
        id: 'loc_thiruthuraipoondi',
        name: 'Thiruthuraipoondi',
        district: 'Thiruvarur District',
        tagline: 'Serene Green Weddings & Classic Delta Halls',
        description:
            'Peaceful community celebration centers with spacious open-air grounds, heritage architecture, and personal care.',
        totalVendors: 32,
        weddingHallsCount: 12,
        imageUrl:
            'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?auto=format&fit=crop&w=600&q=80',
      ),
      ...TamilNaduLocationCatalog.places
          .where(
            (place) => !const {
              'thiruvarur',
              'nagapattinam',
              'thanjavur',
            }.contains(place.city.toLowerCase()),
          )
          .map(
            (place) => ServiceLocation(
              id: 'loc_${place.id}',
              name: place.city,
              district: '${place.district} District',
              tagline: 'Wedding services across ${place.district} District',
              description:
                  'Discover wedding professionals serving ${place.city} and nearby areas.',
              totalVendors: 0,
              weddingHallsCount: 0,
              imageUrl:
                  'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=600&q=80',
            ),
          ),
    ];

    _vendors = [
      Vendor(
        id: 'v1',
        name: 'Raja Rajan Royal Palace',
        category: 'Wedding Halls',
        location: 'Thiruvarur',
        rating: 4.9,
        reviewCount: 148,
        startingPrice: 120000,
        priceUnit: 'per day',
        isFeatured: true,
        isVerified: true,
        heroImage:
            'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=900&q=80',
        galleryImages: [
          'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?auto=format&fit=crop&w=900&q=80',
        ],
        description:
            'A palatial wedding hall in the heart of Thiruvarur featuring majestic Dravidian pillars, high-capacity centralized air conditioning, executive bridal suites, and sprawling dining halls accommodating up to 1,500 guests.',
        address: 'Bazaar Street, Near Thyagaraja Temple, Thiruvarur, TN 610001',
        phone: '+91 94431 88920',
        email: 'info@rajarajanpalace.com',
        experienceYears: 14,
        amenities: [
          'Central Air Conditioning',
          'Valet Parking (200 Cars)',
          '12 Deluxe Guest Rooms',
          'Full Power Backup',
          'Spacious Veg & Non-Veg Dining',
          'Bridal Luxury Suite',
        ],
        capacity: 1500,
        packages: [
          const VendorPackage(
            id: 'p1_1',
            name: 'Classic Auspicious Package',
            price: 120000,
            description:
                'Full day hall booking with essential lighting and 4 air-conditioned guest rooms.',
            features: [
              'Hall access for 24 hours',
              '4 AC guest rooms',
              'Standard audio system',
              'Basic stage lighting',
              'Valet parking assistance',
            ],
          ),
          const VendorPackage(
            id: 'p1_2',
            name: 'Royal Heritage Package',
            price: 175000,
            description:
                'Comprehensive package with all 12 deluxe rooms, full generator diesel, and premium stage lighting.',
            features: [
              'Hall access for 36 hours',
              'All 12 AC guest rooms',
              'Bridal suite with makeup vanity',
              'JBL line-array sound',
              'Generator running cost included',
              'Dedicated security crew',
            ],
            isPopular: true,
          ),
          const VendorPackage(
            id: 'p1_3',
            name: 'Imperial Delta Grand Package',
            price: 240000,
            description:
                'Ultimate royal package including red carpet entry, floral entrance canopy, and 48-hour access.',
            features: [
              '48 hours access for Muhurtham & Reception',
              'Full luxury suites',
              'Chandelier stage illumination',
              'Concierge manager on site',
              'Complimentary dining hall decor',
            ],
          ),
        ],
      ),
      Vendor(
        id: 'v2',
        name: 'Kalyana Virundhu Catering Masters',
        category: 'Catering',
        location: 'Thiruvarur',
        rating: 4.8,
        reviewCount: 215,
        startingPrice: 420,
        priceUnit: 'per plate',
        isFeatured: true,
        isVerified: true,
        heroImage:
            'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=900&q=80',
        galleryImages: [
          'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=900&q=80',
        ],
        description:
            'Iconic Delta wedding caterers serving heavenly 32-item traditional banana leaf feasts, signature Thiruvarur Asoka Halwa, and royal Chettinad/Mughlai reception spreads prepared by veteran master chefs.',
        address: 'Railway Station Road, Thiruvarur',
        phone: '+91 98424 55102',
        email: 'virundhu@artigencehub.com',
        experienceYears: 22,
        amenities: [
          '100% Traditional Banana Leaf',
          'Live Dosa & Appam Counters',
          'Signature Asoka Halwa',
          'Trained Uniformed Waitstaff',
          'Mineral Water Dispensers',
        ],
        capacity: 3000,
        packages: [
          const VendorPackage(
            id: 'p2_1',
            name: 'Traditional 24-Item Ela Sappadu',
            price: 420,
            description:
                'Authentic pure vegetarian feast with 2 payasams, vadas, sweets, and variety rice.',
            features: [
              '24 Traditional Items',
              'Thiruvarur Asoka Halwa',
              'Paruppu Payasam & Paal Payasam',
              'Live Hot Medu Vada',
              'Uniformed servers',
            ],
          ),
          const VendorPackage(
            id: 'p2_2',
            name: 'Royal Cauvery Grand Feast',
            price: 580,
            description:
                'Grand 32-item royal feast including welcome drinks, dry fruit payasam, and ice cream counter.',
            features: [
              '32 Royal Items',
              'Welcome mocktail corner',
              'Elaneer Payasam & Badam Halwa',
              'Live Podi Dosa & Poori',
              'Dessert & Ice cream stall',
            ],
            isPopular: true,
          ),
        ],
      ),
      Vendor(
        id: 'v3',
        name: 'Golden Lens Wedding Cinematography',
        category: 'Photography',
        location: 'Thanjavur',
        rating: 4.95,
        reviewCount: 96,
        startingPrice: 65000,
        priceUnit: 'per event',
        isFeatured: true,
        isVerified: true,
        heroImage:
            'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=900&q=80',
        galleryImages: [
          'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1606800052052-a08af7148866?auto=format&fit=crop&w=900&q=80',
        ],
        description:
            'Award-winning wedding storytellers specializing in cinematic wedding films, 4K aerial drone coverage, and timeless candid portraiture infused with the royal heritage essence of Thanjavur.',
        address: 'South Main Street, Near Brihadeeswara Temple, Thanjavur',
        phone: '+91 97890 12345',
        email: 'stories@goldenlensweddings.com',
        experienceYears: 9,
        amenities: [
          'Dual 4K Sony FX3 Cameras',
          'DJI Mavic 3 Drone Aerials',
          'Live YouTube / LED Streaming',
          'Candid Specialists',
          'Leather Bound Premium Albums',
        ],
        packages: [
          const VendorPackage(
            id: 'p3_1',
            name: 'Classic Moments Package',
            price: 65000,
            description:
                '1 Traditional Photographer + 1 Traditional Videographer for Reception and Muhurtham.',
            features: [
              '2 Full Sessions',
              'Full HD Edited Video',
              '300-page photo album',
              'All raw photos in pen drive',
            ],
          ),
          const VendorPackage(
            id: 'p3_2',
            name: 'Cinematic Royal Package',
            price: 110000,
            description:
                '2 Candid Photographers + 2 Cinematographers + 4K Drone + Same-Day Teaser Video.',
            features: [
              'Candid & Traditional Coverage',
              '4K Drone Aerial Shoots',
              '3-5 Minute Cinematic Wedding Film',
              '2 Handcrafted Leather Albums',
              'Complimentary Pre-wedding Shoot',
            ],
            isPopular: true,
          ),
        ],
      ),
      Vendor(
        id: 'v4',
        name: 'Cauvery Delta Grand Convention Center',
        category: 'Wedding Halls',
        location: 'Nagapattinam',
        rating: 4.7,
        reviewCount: 88,
        startingPrice: 95000,
        priceUnit: 'per day',
        isFeatured: false,
        isVerified: true,
        heroImage:
            'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=900&q=80',
        galleryImages: [
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=900&q=80',
        ],
        description:
            'Modern beach-side convention hall near Velankanni-Nagapattinam highway. Boasts 1,800-seater auditorium, green lawn for open-air receptions, and 16 ocean-facing guest rooms.',
        address: 'ECR Main Road, Nagapattinam, TN',
        phone: '+91 94422 77610',
        email: 'contact@cauveryconvention.com',
        experienceYears: 7,
        amenities: [
          '1800 Guest Seating',
          'Open Air Lawn Area',
          'Ocean Breeze Balcony',
          '16 AC Deluxe Rooms',
          'Generator 250 KVA',
          'Spacious Buffet Pavilion',
        ],
        capacity: 1800,
        packages: [
          const VendorPackage(
            id: 'p4_1',
            name: 'Standard AC Hall Rental',
            price: 95000,
            description:
                'Air conditioned hall and dining with 6 guest rooms for 24 hours.',
            features: [
              'Full AC auditorium',
              '6 Deluxe AC rooms',
              'Dedicated catering kitchen',
              'Standard parking lot',
            ],
          ),
        ],
      ),
      Vendor(
        id: 'v5',
        name: 'Aparna Royal Bridal Makeover',
        category: 'Makeup',
        location: 'Thanjavur',
        rating: 4.9,
        reviewCount: 112,
        startingPrice: 18000,
        priceUnit: 'per session',
        isFeatured: true,
        isVerified: true,
        heroImage:
            'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=900&q=80',
        galleryImages: [
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=900&q=80',
        ],
        description:
            'Certified HD & Airbrush Bridal Makeup Artist skilled in traditional South Indian bridal looks, muhurtham saree draping, floral hair jadai, and modern reception glam.',
        address: 'Medical College Road, Thanjavur',
        phone: '+91 98940 33411',
        email: 'aparna@royalmakeover.in',
        experienceYears: 8,
        amenities: [
          'HD & Airbrush Makeup',
          'International Cosmetics (MAC, Huda)',
          'Intricate Jasmine Flower Jadai',
          'Silk Saree Draping Perfection',
          'On-Venue Travel Included',
        ],
        packages: [
          const VendorPackage(
            id: 'p5_1',
            name: 'Muhurtham HD Bridal Look',
            price: 18000,
            description:
                'Complete bridal transformation including hair styling, flower setting, saree draping, and jewelry setting.',
            features: [
              'HD makeup finish',
              'Traditional bridal hair jadai',
              'Kanchipuram saree draping',
              'Lens & eyelash application',
            ],
          ),
          const VendorPackage(
            id: 'p5_2',
            name: 'Twin Muhurtham + Reception Glow',
            price: 32000,
            description:
                'Two complete makeover sessions for Muhurtham (Vedic Royal) and Reception (Western Glam).',
            features: [
              '2 Full makeover sessions',
              'Airbrush premium foundation',
              'Mother of bride complimentary touch-up',
              'Premium false lashes & lenses',
            ],
            isPopular: true,
          ),
        ],
      ),
      Vendor(
        id: 'v6',
        name: 'Brindhavan Floral Stage Decors',
        category: 'Decoration',
        location: 'Mayiladuthurai',
        rating: 4.85,
        reviewCount: 74,
        startingPrice: 38000,
        priceUnit: 'per setup',
        isFeatured: true,
        isVerified: true,
        heroImage:
            'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=900&q=80',
        galleryImages: [
          'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=900&q=80',
        ],
        description:
            'Specialists in fragrant fresh lotus, marigold, and tuberose floral mandapams, LED backdrop designs, majestic archways, and royal pathway candle stands.',
        address: 'Kutchery Road, Mayiladuthurai',
        phone: '+91 97871 44520',
        email: 'brindhavan@decors.com',
        experienceYears: 11,
        amenities: [
          'Fresh Exotic Flowers',
          'Custom 3D Stage Concepts',
          'Illuminated LED Entryway Arch',
          'Traditional Brass Lamp Arrangements',
          'Photobooth Corners',
        ],
        packages: [
          const VendorPackage(
            id: 'p6_1',
            name: 'Temple Lotus Mandapam Setup',
            price: 38000,
            description:
                'Divine temple-themed mandapam with fresh lotuses, marigold strings, and traditional Vilakku setup.',
            features: [
              '20ft x 12ft Mandapam Stage',
              'Fresh natural flowers',
              'Grand entrance arch',
              'Couple chairs in royal gold',
            ],
          ),
        ],
      ),
      Vendor(
        id: 'v7',
        name: 'Cholan Heritage Bridal Silks',
        category: 'Bridal Wear',
        location: 'Thanjavur',
        rating: 4.9,
        reviewCount: 160,
        startingPrice: 22000,
        priceUnit: 'starting from',
        isFeatured: true,
        isVerified: true,
        heroImage:
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=900&q=80',
        galleryImages: [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=900&q=80',
        ],
        description:
            'Handcrafted pure zari Kanchipuram and Thirubuvanam silk sarees woven with timeless temple borders, peacock motifs, and bridal muhurtham colorways.',
        address: 'East Gate, Thanjavur, TN',
        phone: '+91 94432 99012',
        email: 'sales@cholanheritage.com',
        experienceYears: 30,
        amenities: [
          'Silk Mark Certified',
          'Custom Zari Inscriptions',
          'Private Bridal Lounge',
          'Designer Blouse Tailoring Support',
        ],
        packages: [
          const VendorPackage(
            id: 'p7_1',
            name: 'Royal Muhurtham Kanchipuram Saree',
            price: 22000,
            description:
                'Pure double-warp silk with real gold silver tested zari and bridal motifs.',
            features: [
              'Pure Mulberry Silk',
              'Silk Mark Authorized Certificate',
              'Matching unstitched designer blouse piece',
            ],
          ),
        ],
      ),
      Vendor(
        id: 'v8',
        name: 'Maharaja Groom Wear & Turbans',
        category: 'Groom Wear',
        location: 'Thiruvarur',
        rating: 4.75,
        reviewCount: 65,
        startingPrice: 14000,
        priceUnit: 'starting from',
        isFeatured: false,
        isVerified: true,
        heroImage:
            'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=900&q=80',
        galleryImages: [
          'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=900&q=80',
        ],
        description:
            'Bespoke silk dhotis, angavastrams with real zari borders, royal velvet sherwanis, jodhpuri suits, and customized wedding turbans for grooms.',
        address: 'Kamalalayam North Bank, Thiruvarur',
        phone: '+91 98421 11234',
        email: 'contact@maharajagroom.com',
        experienceYears: 12,
        amenities: [
          'Pure Silk Pattu Dhotis',
          'Hand-embroidered Sherwanis',
          'Custom Turban & Safa Tying',
          'Express Alteration Service',
        ],
        packages: [
          const VendorPackage(
            id: 'p8_1',
            name: 'Vedic Groom Silk Set',
            price: 14000,
            description:
                'Pure silk 8-muzham dhoti + 4-muzham angavastram with 2-inch Mayilkan gold border.',
            features: [
              'Pure silk dhoti & angavastram',
              'Matching silk shirt fabric',
              'Gold brooch ornament',
            ],
          ),
        ],
      ),
      Vendor(
        id: 'v9',
        name: 'Shree Krishna Wedding Invites & Crafts',
        category: 'Wedding Invitations',
        location: 'Mayiladuthurai',
        rating: 4.8,
        reviewCount: 89,
        startingPrice: 55,
        priceUnit: 'per card',
        isFeatured: false,
        isVerified: true,
        heroImage:
            'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=900&q=80',
        galleryImages: [
          'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=900&q=80',
        ],
        description:
            'Gold-foiled traditional laser-cut marriage invitations, luxury box invites with dry fruits, and animated video e-invitations with RSVP links.',
        address: 'Pattamangala Street, Mayiladuthurai',
        phone: '+91 94435 44881',
        email: 'orders@shreekrishnacards.com',
        experienceYears: 16,
        amenities: [
          'Custom Laser Cut Designs',
          'Real Gold Foil Stamping',
          'Digital Video Invite Included',
          'Eco-friendly Seed Paper Options',
        ],
        packages: [
          const VendorPackage(
            id: 'p9_1',
            name: 'Royal Gold Foil Invitation (100 Cards)',
            price: 5500,
            description:
                'Textured ivory card stock with rich gold foil religious motifs and matching inserts.',
            features: [
              '100 Premium cards & envelopes',
              'Tamil & English bilingual typesetting',
              'Digital PDF invite complimentary',
            ],
          ),
        ],
      ),
      Vendor(
        id: 'v10',
        name: 'Cauvery Classic Nadaswaram & Melam Troupe',
        category: 'Other Wedding Services',
        location: 'Thiruthuraipoondi',
        rating: 4.9,
        reviewCount: 52,
        startingPrice: 25000,
        priceUnit: 'per session',
        isFeatured: false,
        isVerified: true,
        heroImage:
            'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?auto=format&fit=crop&w=900&q=80',
        galleryImages: [
          'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?auto=format&fit=crop&w=900&q=80',
        ],
        description:
            'Renowned traditional music ensemble performing authentic auspicious ragas for Muhurtham, Oonjal, Kasi Yatrai, and evening receptions.',
        address: 'Temple Street, Thiruthuraipoondi',
        phone: '+91 97860 66722',
        email: 'melam@cauverytunes.com',
        experienceYears: 25,
        amenities: [
          'Master Nadaswaram Artistes',
          'Thavil & Shruthi Ensemble',
          'Custom Muhurtham Ragas',
          'All Religious Ritual Expertise',
        ],
        packages: [
          const VendorPackage(
            id: 'p10_1',
            name: 'Complete Muhurtham Ensemble (5 Artistes)',
            price: 25000,
            description:
                '2 Nadaswaram + 2 Thavil + 1 Talam/Shruthi from pre-dawn Muhurtham through reception.',
            features: [
              '5 Artistes ensemble',
              'Traditional temple tunes',
              'Microphone setup included',
            ],
          ),
        ],
      ),
    ];

    _bookings = [
      Booking(
        id: 'BK-78901',
        vendorId: 'v1',
        vendorName: 'Raja Rajan Royal Palace',
        vendorCategory: 'Wedding Halls',
        vendorImage:
            'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=600&q=80',
        location: 'Thiruvarur',
        packageName: 'Royal Heritage Package',
        eventDate: DateTime.now().add(const Duration(days: 75)),
        timeSlot: 'Morning Muhurtham (05:30 AM - 12:00 PM)',
        guestCount: 1200,
        totalPrice: 175000,
        status: 'Confirmed',
        bookingDate: DateTime.now().subtract(const Duration(days: 3)),
        specialNotes: 'Require early access to bridal suite at 4 AM.',
        hallName: 'Raja Rajan Royal Palace',
        customerName: 'Ananya & Vignesh',
        customerContact: '+91 98400 12345',
        customerMessage: 'Need early access to bridal suite at 4 AM.',
      ),
      Booking(
        id: 'BK-78902',
        vendorId: 'v2',
        vendorName: 'Kalyana Virundhu Catering Masters',
        vendorCategory: 'Catering',
        vendorImage:
            'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=80',
        location: 'Thiruvarur',
        packageName: 'Royal Cauvery Grand Feast',
        eventDate: DateTime.now().add(const Duration(days: 85)),
        timeSlot: 'Lunch Feast (11:30 AM - 03:30 PM)',
        guestCount: 800,
        totalPrice: 464000,
        status: 'Confirmed',
        bookingDate: DateTime.now().subtract(const Duration(days: 2)),
        specialNotes: 'Double serving of Thiruvarur Asoka Halwa requested.',
        hallName: 'Kalyana Virundhu Catering Masters',
        customerName: 'Meenakshi & Aravind',
        customerContact: '+91 91111 00000',
        customerMessage: 'Double serving of Asoka Halwa requested.',
      ),
    ];

    _notifications = [
      AppNotificationItem(
        id: 'n1',
        title: 'Booking request submitted',
        message:
            'Your request for Raja Rajan Royal Palace is pending vendor review.',
        relatedBookingId: 'BK-78901',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      AppNotificationItem(
        id: 'n2',
        title: 'Booking accepted',
        message:
            'Your booking for Kalyana Virundhu Catering Masters has been confirmed.',
        relatedBookingId: 'BK-78902',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];

    _reviews = [
      const Review(
        id: 'r1',
        vendorId: 'v1',
        userName: 'Suresh & Preeti',
        userAvatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        rating: 5.0,
        date: '2 weeks ago',
        comment:
            'Raja Rajan Royal Palace made our wedding in Thiruvarur feel like a dream! The air conditioning handled 1,300 guests effortlessly, and the bridal rooms were so comfortable and opulent.',
        serviceUsed: 'Wedding Hall (Full Muhurtham)',
        weddingDate: 'August 2026',
        helpfulCount: 24,
      ),
      const Review(
        id: 'r2',
        vendorId: 'v1',
        userName: 'Karthik Narayanan',
        userAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
        rating: 4.8,
        date: '1 month ago',
        comment:
            'Very professional management. Ample parking space which is rare in temple towns. The lighting and grand chandelier on the stage were stellar in our photos.',
        serviceUsed: 'Royal Heritage Package',
        weddingDate: 'July 2026',
        helpfulCount: 15,
      ),
      const Review(
        id: 'r3',
        vendorId: 'v2',
        userName: 'Meenakshi Sundaram',
        userAvatar:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
        rating: 5.0,
        date: '3 weeks ago',
        comment:
            'The Asoka Halwa and Elaneer Payasam were the talk of the entire marriage! Guests from Chennai are still raving about the authentic Delta taste.',
        serviceUsed: 'Royal Cauvery Grand Feast',
        weddingDate: 'August 2026',
        helpfulCount: 38,
      ),
      const Review(
        id: 'r4',
        vendorId: 'v3',
        userName: 'Anand & Divya',
        userAvatar:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
        rating: 5.0,
        date: '3 weeks ago',
        comment:
            'Golden Lens delivered a masterpiece film. The drone shots of the Thanjavur temple and our muhurtham brought tears to our families. Highly recommended!',
        serviceUsed: 'Cinematic Royal Package',
        weddingDate: 'July 2026',
        helpfulCount: 19,
      ),
    ];
  }
}
