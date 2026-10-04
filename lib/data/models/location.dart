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

/// Reusable Tamil Nadu district/city/area data for location discovery.
/// Area and pincode stay optional so users are not asked for a full address.
class TamilNaduPlace {
  final String id;
  final String district;
  final String city;
  final String area;
  final String pincode;

  const TamilNaduPlace({
    required this.id,
    required this.district,
    required this.city,
    this.area = '',
    this.pincode = '',
  });
}

class TamilNaduLocationCatalog {
  TamilNaduLocationCatalog._();

  static const places = <TamilNaduPlace>[
    TamilNaduPlace(id: 'chennai', district: 'Chennai', city: 'Chennai'),
    TamilNaduPlace(
      id: 'coimbatore',
      district: 'Coimbatore',
      city: 'Coimbatore',
    ),
    TamilNaduPlace(id: 'madurai', district: 'Madurai', city: 'Madurai'),
    TamilNaduPlace(
      id: 'tiruchirappalli',
      district: 'Tiruchirappalli',
      city: 'Trichy',
    ),
    TamilNaduPlace(id: 'thanjavur', district: 'Thanjavur', city: 'Thanjavur'),
    TamilNaduPlace(
      id: 'tirunelveli',
      district: 'Tirunelveli',
      city: 'Tirunelveli',
    ),
    TamilNaduPlace(id: 'salem', district: 'Salem', city: 'Salem'),
    TamilNaduPlace(id: 'erode', district: 'Erode', city: 'Erode'),
    TamilNaduPlace(id: 'vellore', district: 'Vellore', city: 'Vellore'),
    TamilNaduPlace(
      id: 'thiruvarur',
      district: 'Thiruvarur',
      city: 'Thiruvarur',
    ),
    TamilNaduPlace(
      id: 'nagapattinam',
      district: 'Nagapattinam',
      city: 'Nagapattinam',
    ),
    TamilNaduPlace(id: 'kumbakonam', district: 'Thanjavur', city: 'Kumbakonam'),
    TamilNaduPlace(id: 'dindigul', district: 'Dindigul', city: 'Dindigul'),
    TamilNaduPlace(id: 'karur', district: 'Karur', city: 'Karur'),
    TamilNaduPlace(
      id: 'sivagangai',
      district: 'Sivagangai',
      city: 'Sivagangai',
    ),
    TamilNaduPlace(
      id: 'pudukkottai',
      district: 'Pudukkottai',
      city: 'Pudukkottai',
    ),
    TamilNaduPlace(id: 'cuddalore', district: 'Cuddalore', city: 'Cuddalore'),
    TamilNaduPlace(
      id: 'villupuram',
      district: 'Villupuram',
      city: 'Villupuram',
    ),
    TamilNaduPlace(id: 'tiruppur', district: 'Tiruppur', city: 'Tiruppur'),
  ];
}
