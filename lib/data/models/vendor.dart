class VendorPackage {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> features;
  final bool isPopular;

  const VendorPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.features,
    this.isPopular = false,
  });
}

class Vendor {
  final String id;
  final String name;
  final String category;
  final String location;
  final double rating;
  final int reviewCount;
  final double startingPrice;
  final String priceUnit;
  final bool isFeatured;
  final bool isVerified;
  final String heroImage;
  final List<String> galleryImages;
  final String description;
  final String address;
  final String phone;
  final String email;
  final int experienceYears;
  final List<String> amenities;
  final List<VendorPackage> packages;
  final int capacity; // for halls or catering capacity
  final bool isAvailable;

  const Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.startingPrice,
    this.priceUnit = 'per day',
    this.isFeatured = false,
    this.isVerified = true,
    required this.heroImage,
    required this.galleryImages,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    required this.experienceYears,
    required this.amenities,
    required this.packages,
    this.capacity = 1000,
    this.isAvailable = true,
  });
}
