import 'package:flutter_test/flutter_test.dart';
import 'package:haventra_wedding_planner/data/repositories/mock_wedding_repository.dart';

void main() {
  test(
    'pending booking request is not auto-confirmed and availability blocks duplicates',
    () {
      final repo = MockWeddingRepository();
      final vendorId = repo.vendors.first.id;
      final baseDate = DateTime.now().add(const Duration(days: 45));

      final firstRequest = repo.submitBookingRequest(
        vendorId: vendorId,
        hallName: repo.getVendorById(vendorId)?.name ?? 'Hall',
        customerName: 'Test Customer',
        customerContact: '+91 99999 00000',
        bookingDate: baseDate,
        requestedTime: 'Evening Reception',
        guestCount: 300,
        customerMessage: 'Need a family hall',
      );

      expect(firstRequest, isNotNull);
      expect(firstRequest!.status, 'Pending');
      expect(repo.isDateAvailable(vendorId, baseDate), isFalse);

      final accepted = repo.acceptBookingRequest(firstRequest.id);
      expect(accepted, isTrue);
      expect(repo.getBookingById(firstRequest.id)?.status, 'Confirmed');
      expect(repo.isDateAvailable(vendorId, baseDate), isFalse);

      final duplicate = repo.submitBookingRequest(
        vendorId: vendorId,
        hallName: repo.getVendorById(vendorId)?.name ?? 'Hall',
        customerName: 'Second Customer',
        customerContact: '+91 88888 00000',
        bookingDate: baseDate,
        requestedTime: 'Morning Muhurtham',
        guestCount: 200,
        customerMessage: 'Second request',
      );

      expect(duplicate, isNull);
    },
  );

  test('pending booking blocks a second request for the same day', () {
    final repo = MockWeddingRepository();
    final vendorId = repo.vendors.first.id;
    final requestedDate = DateTime.now().add(const Duration(days: 20));

    final firstRequest = repo.submitBookingRequest(
      vendorId: vendorId,
      hallName: repo.getVendorById(vendorId)?.name ?? 'Hall',
      customerName: 'Customer One',
      customerContact: '+91 90000 11111',
      bookingDate: requestedDate,
      requestedTime: 'Morning Muhurtham',
      guestCount: 250,
      customerMessage: 'Family event',
    );

    expect(firstRequest, isNotNull);
    expect(repo.isDateAvailable(vendorId, requestedDate), isFalse);

    final secondRequest = repo.submitBookingRequest(
      vendorId: vendorId,
      hallName: repo.getVendorById(vendorId)?.name ?? 'Hall',
      customerName: 'Customer Two',
      customerContact: '+91 90000 22222',
      bookingDate: requestedDate,
      requestedTime: 'Evening Reception',
      guestCount: 400,
      customerMessage: 'Another request',
    );

    expect(secondRequest, isNull);
  });
}
