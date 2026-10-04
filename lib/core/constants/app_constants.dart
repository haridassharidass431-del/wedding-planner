/// Application-wide constants for Haventra Wedding Planner
class AppConstants {
  AppConstants._();

  static const String appName = 'Haventra Wedding Planner';
  static const String companyName = 'Artigence Ai Hub';
  static const String appTagline = 'PLAN • CONNECT • CELEBRATE';
  static const String logoAssetPath = 'assets/images/haventra_logo.jpg';

  /// Initial regional hubs across Tamil Nadu
  static const List<String> defaultLocations = [
    'Thiruvarur',
    'Nagapattinam',
    'Thanjavur',
    'Mayiladuthurai',
    'Thiruthuraipoondi',
  ];

  /// 9 primary customer service categories
  static const List<String> serviceCategories = [
    'Wedding Halls',
    'Photography',
    'Catering',
    'Decoration',
    'Makeup',
    'Mehendi',
    'Bridal Wear',
    'Groom Wear',
    'Jewellery',
    'Wedding Invitations',
    'DJ/Music',
    'Other Wedding Services',
  ];

  /// User persona roles
  static const String roleCustomer = 'Customer';
  static const String roleVendor = 'Wedding Vendor';
  static const String roleAdmin = 'Administrator';
}
