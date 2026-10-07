import '../models/models.dart';
import 'exposure_estimation_service.dart';

/// A single, data-driven suggestion shown on the Dashboard. Generated
/// from current readings — never static placeholder text.
class Recommendation {
  final String title;
  final String body;
  final RiskLevel level;
  final bool suggestAirHub;

  const Recommendation({
    required this.title,
    required this.body,
    required this.level,
    this.suggestAirHub = false,
  });
}

/// Centralized, deterministic recommendation logic. Conservative,
/// non-diagnostic wording only — this is a prototype demonstration of
/// how AERIS could respond to conditions, not medical guidance.
class RecommendationService {
  static Recommendation generate({
    required SensorReading reading,
    required AirQualityData outdoor,
    required ExposureEstimate exposure,
    required HealthProfile profile,
    required bool airHubOn,
  }) {
    final sensitive = profile.respiratoryCondition != RespiratoryCondition.none ||
        profile.allergyLevel == AllergyLevel.moderate ||
        profile.allergyLevel == AllergyLevel.severe;

    switch (exposure.riskLevel) {
      case RiskLevel.low:
        return const Recommendation(
          title: 'Conditions look good',
          body: 'Air quality is good right now. No special precautions are suggested — '
              'continue your normal activity.',
          level: RiskLevel.low,
        );

      case RiskLevel.moderate:
        return Recommendation(
          title: 'Monitor conditions',
          body: sensitive
              ? 'Particulate levels are moderate. Given your profile, consider keeping an eye on '
                  'how you feel and limiting prolonged exertion outdoors.'
              : 'Particulate levels are moderate. Most people can continue normal activity; '
                  'sensitive individuals may want to pace outdoor exertion.',
          level: RiskLevel.moderate,
        );

      case RiskLevel.elevated:
        return Recommendation(
          title: 'Consider reducing exposure',
          body: airHubOn
              ? 'Particulate levels are elevated. AirHub purification is already active, which '
                  'simulates a modest indoor improvement — consider also limiting prolonged '
                  'outdoor exertion.'
              : 'Particulate levels are elevated${sensitive ? ', and your profile indicates higher sensitivity' : ''}. '
                  'Consider limiting prolonged outdoor exertion and activating AirHub for indoor air.',
          level: RiskLevel.elevated,
          suggestAirHub: !airHubOn,
        );

      case RiskLevel.high:
        return Recommendation(
          title: 'Reduce time in this environment',
          body: airHubOn
              ? 'Conditions are poor. AirHub is running (prototype simulation of a modest '
                  'improvement) — it is still advisable to reduce time in this environment and '
                  'avoid strenuous outdoor activity.'
              : 'Conditions are poor. Consider reducing time in this environment, avoiding '
                  'strenuous outdoor activity, and activating AirHub for filtered indoor air.',
          level: RiskLevel.high,
          suggestAirHub: !airHubOn,
        );
    }
  }
}
