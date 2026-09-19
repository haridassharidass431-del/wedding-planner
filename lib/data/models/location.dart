class ServiceLocation {
  final String id;
  final String name;
  final String district;
  final String tagline;
  final String description;
  final int totalVendors;
  final int weddingHallsCount;
  final String imageUrl;
  final bool isFeatured;

  const ServiceLocation({
    required this.id,
    required this.name,
    required this.district,
    required this.tagline,
    required this.description,
    required this.totalVendors,
    required this.weddingHallsCount,
    required this.imageUrl,
    this.isFeatured = false,
  });
}
