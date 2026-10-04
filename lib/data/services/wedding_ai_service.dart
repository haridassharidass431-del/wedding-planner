import '../models/wedding_context.dart';

/// Provider boundary for a secure server-side AI integration.
/// Production providers should call an authenticated backend; never embed API keys here.
abstract interface class WeddingAiService {
  Future<String> reply({
    required String message,
    required WeddingContext context,
  });
}

/// Local demo response keeps the chat usable before a backend is configured.
class DemoWeddingAiService implements WeddingAiService {
  @override
  Future<String> reply({
    required String message,
    required WeddingContext context,
  }) async {
    final details = <String>[
      if (context.guestCount != null) '${context.guestCount} guests',
      if (context.budget != null) 'a ₹${context.budget!.round()} budget',
      if (context.location != null) 'in ${context.location}',
    ];
    final contextLine = details.isEmpty
        ? ''
        : ' I’ll keep ${details.join(' and ')} in mind.';
    return 'Start with your venue and catering, since availability and guest count affect the rest of the plan. Then confirm your date, shortlist photography and decor, and keep a small contingency in your budget.$contextLine\n\nThis is a planning preview. Connect a secure backend to enable personalized AI recommendations.';
  }
}
