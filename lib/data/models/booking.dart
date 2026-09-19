class Booking {
  final String id;
  final String vendorId;
  final String vendorName;
  final String vendorCategory;
  final String vendorImage;
  final String location;
  final String packageName;
  final DateTime eventDate;
  final String timeSlot;
  final int guestCount;
  final double totalPrice;
  final String status; // 'Confirmed', 'Pending', 'Completed'
  final DateTime bookingDate;
  final String specialNotes;

  const Booking({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.vendorCategory,
    required this.vendorImage,
    required this.location,
    required this.packageName,
    required this.eventDate,
    required this.timeSlot,
    required this.guestCount,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
    this.specialNotes = '',
  });

  Booking copyWith({
    String? id,
    String? vendorId,
    String? vendorName,
    String? vendorCategory,
    String? vendorImage,
    String? location,
    String? packageName,
    DateTime? eventDate,
    String? timeSlot,
    int? guestCount,
    double? totalPrice,
    String? status,
    DateTime? bookingDate,
    String? specialNotes,
  }) {
    return Booking(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      vendorCategory: vendorCategory ?? this.vendorCategory,
      vendorImage: vendorImage ?? this.vendorImage,
      location: location ?? this.location,
      packageName: packageName ?? this.packageName,
      eventDate: eventDate ?? this.eventDate,
      timeSlot: timeSlot ?? this.timeSlot,
      guestCount: guestCount ?? this.guestCount,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      specialNotes: specialNotes ?? this.specialNotes,
    );
  }
}
