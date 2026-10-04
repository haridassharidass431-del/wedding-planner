import 'booking.dart';

/// Business metrics derived from booking records. This is not a payment ledger.
class VendorEarningsSummary {
  final List<Booking> bookings;
  final DateTime asOf;

  VendorEarningsSummary({required this.bookings, DateTime? asOf})
    : asOf = asOf ?? DateTime.now();

  List<Booking> get completed => bookings
      .where((booking) => booking.status.toLowerCase() == 'completed')
      .toList();

  List<Booking> get active => bookings.where((booking) {
    final status = booking.status.toLowerCase();
    return status == 'pending' || status == 'confirmed';
  }).toList();

  double get totalEarnings =>
      completed.fold<double>(0, (total, booking) => total + booking.totalPrice);

  double get thisMonth => _earnedSince(DateTime(asOf.year, asOf.month));
  double get thisWeek => _earnedSince(asOf.subtract(const Duration(days: 6)));
  double get pendingAmount =>
      active.fold<double>(0, (total, booking) => total + booking.totalPrice);

  int get pendingRequests => bookings
      .where((booking) => booking.status.toLowerCase() == 'pending')
      .length;

  int get confirmedBookings => bookings
      .where((booking) => booking.status.toLowerCase() == 'confirmed')
      .length;

  int get cancelledBookings => bookings.where((booking) {
    final status = booking.status.toLowerCase();
    return status == 'cancelled' || status == 'declined';
  }).length;

  List<double> get dailyEarnings => List<double>.generate(7, (index) {
    final day = DateTime(
      asOf.year,
      asOf.month,
      asOf.day,
    ).subtract(Duration(days: 6 - index));
    return completed
        .where((booking) {
          final date = booking.updatedAt;
          return date.year == day.year &&
              date.month == day.month &&
              date.day == day.day;
        })
        .fold<double>(0, (total, booking) => total + booking.totalPrice);
  });

  double _earnedSince(DateTime from) => completed
      .where((booking) => !booking.updatedAt.isBefore(from))
      .fold<double>(0, (total, booking) => total + booking.totalPrice);
}
