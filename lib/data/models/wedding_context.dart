/// User wedding details shared with planning and AI features.
class WeddingContext {
  final DateTime? weddingDate;
  final int? guestCount;
  final double? budget;
  final String? location;
  final String? weddingType;
  final List<String> preferences;

  const WeddingContext({
    this.weddingDate,
    this.guestCount,
    this.budget,
    this.location,
    this.weddingType,
    this.preferences = const [],
  });
}
