import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haventra_wedding_planner/data/models/booking.dart';
import 'package:haventra_wedding_planner/data/models/location.dart';
import 'package:haventra_wedding_planner/data/models/vendor_earnings.dart';
import 'package:haventra_wedding_planner/data/repositories/mock_wedding_repository.dart';
import 'package:haventra_wedding_planner/ui/screens/categories/categories_screen.dart';
import 'package:haventra_wedding_planner/ui/screens/home/home_screen.dart';
import 'package:haventra_wedding_planner/ui/screens/location/location_selection_screen.dart';
import 'package:haventra_wedding_planner/ui/screens/main_navigation_screen.dart';
import 'package:haventra_wedding_planner/ui/screens/profile/profile_screen.dart';
import 'package:haventra_wedding_planner/ui/screens/vendors/vendor_dashboard_screen.dart';
import 'package:haventra_wedding_planner/ui/screens/vendors/vendor_listing_screen.dart';

void main() {
  test('Tamil Nadu location catalog keeps district and city data reusable', () {
    expect(
      TamilNaduLocationCatalog.places.any(
        (place) => place.city == 'Kumbakonam' && place.district == 'Thanjavur',
      ),
      isTrue,
    );
    expect(
      TamilNaduLocationCatalog.places.any((place) => place.city == 'Madurai'),
      isTrue,
    );
    expect(
      MockWeddingRepository().matchesLocation('Kumbakonam', 'Thanjavur'),
      isTrue,
    );
  });

  test('earnings summarize completed and active booking values', () {
    final now = DateTime.now();
    Booking booking(String id, String status, double value) => Booking(
      id: id,
      vendorId: 'vendor-1',
      vendorName: 'Vendor',
      vendorCategory: 'Photography',
      vendorImage: '',
      location: 'Madurai',
      packageName: 'Package',
      eventDate: now,
      timeSlot: 'Morning',
      guestCount: 100,
      totalPrice: value,
      status: status,
      bookingDate: now,
      updatedAt: now,
    );

    final summary = VendorEarningsSummary(
      bookings: [
        booking('completed', 'Completed', 25000),
        booking('confirmed', 'Confirmed', 12000),
        booking('pending', 'Pending', 8000),
      ],
      asOf: now,
    );

    expect(summary.totalEarnings, 25000);
    expect(summary.thisMonth, 25000);
    expect(summary.pendingAmount, 20000);
    expect(summary.pendingRequests, 1);
  });

  test('customers only discover services after admin approval', () {
    final repo = MockWeddingRepository();
    repo.setCurrentRole('Wedding Vendor');
    final approvedId = repo.submitService(
      name: 'Test photo service',
      description: 'Test listing',
      category: 'Photography',
      location: 'Madurai',
      price: 10000,
      images: const [],
    )!;
    expect(
      repo.publicServices.any((service) => service['id'] == approvedId),
      isFalse,
    );

    repo.setCurrentRole('Administrator');
    expect(repo.reviewService(approvedId, approve: true), isTrue);
    expect(
      repo.publicServices.any((service) => service['id'] == approvedId),
      isTrue,
    );

    repo.setCurrentRole('Wedding Vendor');
    final rejectedId = repo.submitService(
      name: 'Test rejected service',
      description: 'Test listing',
      category: 'Photography',
      location: 'Madurai',
      price: 10000,
      images: const [],
    )!;
    repo.setCurrentRole('Administrator');
    expect(repo.reviewService(rejectedId, approve: false), isTrue);
    expect(
      repo.publicServices.any((service) => service['id'] == rejectedId),
      isFalse,
    );
    repo.setCurrentRole('Customer');
  });

  test('vendors can complete their own confirmed bookings', () {
    final repo = MockWeddingRepository();
    repo.setCurrentRole('Wedding Vendor');
    final id = 'TEST-${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now();
    repo.addBooking(
      Booking(
        id: id,
        vendorId: repo.currentUserId,
        vendorName: 'Test Vendor',
        vendorCategory: 'Photography',
        vendorImage: '',
        location: 'Madurai',
        packageName: 'Test package',
        eventDate: now,
        timeSlot: 'Morning',
        guestCount: 100,
        totalPrice: 22000,
        status: 'Confirmed',
        bookingDate: now,
        updatedAt: now,
      ),
    );
    expect(repo.completeVendorBooking(id), isTrue);
    expect(repo.getBookingById(id)?.status, 'Completed');
    expect(repo.vendorEarnings.totalEarnings, greaterThanOrEqualTo(22000));
    repo.setCurrentRole('Customer');
  });

  for (final size in const [Size(390, 844), Size(800, 1024), Size(1440, 960)]) {
    testWidgets('home, categories and vendor dashboard fit at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);
      for (var page = 0; page < 4; page++) {
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -1200),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      }

      await tester.pumpWidget(
        const MaterialApp(home: LocationSelectionScreen()),
      );
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const MaterialApp(home: CategoriesScreen()));
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        const MaterialApp(home: VendorListingScreen(initialCategory: 'All')),
      );
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);

      MockWeddingRepository().setCurrentRole('Wedding Vendor');
      await tester.pumpWidget(
        const MaterialApp(home: VendorBusinessDashboardScreen()),
      );
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);
      MockWeddingRepository().setCurrentRole('Customer');

      await tester.pumpWidget(const MaterialApp(home: MainNavigationScreen()));
      await tester.pump(const Duration(milliseconds: 350));
      if (size.width >= 900) {
        expect(find.byType(NavigationRail), findsOneWidget);
      } else {
        expect(find.byType(NavigationBar), findsOneWidget);
      }
      expect(tester.takeException(), isNull);

      MockWeddingRepository().setCurrentRole('Wedding Vendor');
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      MockWeddingRepository().setCurrentRole('Customer');
    });
  }
}
