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
  final String status; // Pending, Confirmed, Declined, Cancelled, Completed
  final DateTime bookingDate;
  final String specialNotes;
  final String hallName;
  final String customerName;
  final String customerId;
  final String customerContact;
  final String customerMessage;
  final String? vendorResponse;
  final String? declineReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
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
    this.hallName = '',
    this.customerName = '',
    this.customerId = '',
    this.customerContact = '',
    this.customerMessage = '',
    this.vendorResponse,
    this.declineReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

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
    String? hallName,
    String? customerName,
    String? customerId,
    String? customerContact,
    String? customerMessage,
    String? vendorResponse,
    String? declineReason,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      hallName: hallName ?? this.hallName,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      customerContact: customerContact ?? this.customerContact,
      customerMessage: customerMessage ?? this.customerMessage,
      vendorResponse: vendorResponse ?? this.vendorResponse,
      declineReason: declineReason ?? this.declineReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
