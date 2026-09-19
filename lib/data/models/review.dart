class Review {
  final String id;
  final String vendorId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String date;
  final String comment;
  final String serviceUsed;
  final String weddingDate;
  final int helpfulCount;
  final bool isVerifiedCustomer;

  const Review({
    required this.id,
    required this.vendorId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.date,
    required this.comment,
    required this.serviceUsed,
    required this.weddingDate,
    this.helpfulCount = 0,
    this.isVerifiedCustomer = true,
  });
}
