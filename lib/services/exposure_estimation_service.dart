import '../models/models.dart';

/// Coarse risk category for the current estimated conditions.
enum RiskLevel { low, moderate, elevated, high }

extension RiskLevelLabel on RiskLevel {
  String get label => switch (this) {
        RiskLevel.low => 'LOW',
        RiskLevel.moderate => 'MODERATE',
        RiskLevel.elevated => 'ELEVATED',
        RiskLevel.high => 'HIGH',
      };

  /// Maps to the same category names used by [AppTheme.categoryColor],
  /// so exposure risk and air-quality status share one color source.
  String get categoryName => switch (this) {
        RiskLevel.low => 'Good',
        RiskLevel.moderate => 'Moderate',
        RiskLevel.elevated => 'Unhealthy (Sensitive)',
        RiskLevel.high => 'Unhealthy',
      };
}

/// One labeled input that contributed to the estimate, shown in the UI
/// so the result is explainable rather than a bare number.
class ExposureFactor {
  final String label;
  final String value;
  const ExposureFactor(this.label, this.value);
}

/// Inputs to the prototype exposure model. All fields are either current
/// sensor/outdoor readings or values from the local (non-medical) health
/// profile.
class ExposureInput {
  final int? age;
  final RespiratoryCondition respiratoryCondition;
  final AllergyLevel allergyLevel;
  final ActivityLevel activityLevel;
  final OutdoorExposureLevel outdoorExposure;
  final double pm25;
  final double pm10;
  final int aqi;
  final double temperature;
  final double humidity;

  /// Whether AirHub is currently running. Used only to apply a small,
  /// clearly simulated indoor-improvement factor — this does NOT mean
  /// the physical device is actually purifying the room.
  final bool airHubActive;

  const ExposureInput({
    this.age,
    this.respiratoryCondition = RespiratoryCondition.none,
    this.allergyLevel = AllergyLevel.none,
    this.activityLevel = ActivityLevel.moderate,
    this.outdoorExposure = OutdoorExposureLevel.moderate,
    required this.pm25,
    required this.pm10,
    required this.aqi,
    required this.temperature,
    required this.humidity,
    this.airHubActive = false,
  });
}

/// Result of the prototype exposure model.
class ExposureEstimate {
  final int estimatedMinutes;
  final RiskLevel riskLevel;
  final String explanation;
  final List<ExposureFactor> factors;

  const ExposureEstimate({
    required this.estimatedMinutes,
    required this.riskLevel,
    required this.explanation,
    required this.factors,
  });

  /// "3h 20m" / "1h" / "45m" style formatting for display.
  String get formatted {
    final h = estimatedMinutes ~/ 60;
    final m = estimatedMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

/// Deterministic, transparent, heuristic prototype exposure model.
///
/// NOT a medical device and NOT clinically validated — this exists to
/// demonstrate how personalization *could* work once real hardware and a
/// properly validated model are available. All thresholds/weights are
/// centralized here so they're easy to explain and adjust.
class ExposureEstimationService {
  static const int _baselineMinutes = 240; // best-case baseline, good air
  static const int _minMinutes = 15;
  static const int _maxMinutes = 480;

  // Simulated indoor improvement while AirHub is running. Conservative
  // and clearly a demo simplification, not a measured filtration rate.
  static const double _airHubSimulatedReduction = 0.20;

  // Risk-level thresholds against the 0-100 pollution score below.
  static const double _moderateThreshold = 25;
  static const double _elevatedThreshold = 50;
  static const double _highThreshold = 75;

  static ExposureEstimate estimate(ExposureInput input) {
    final effectivePm25 =
        input.airHubActive ? input.pm25 * (1 - _airHubSimulatedReduction) : input.pm25;
    final effectivePm10 =
        input.airHubActive ? input.pm10 * (1 - _airHubSimulatedReduction) : input.pm10;

    final aqiScore = (input.aqi / 300 * 100).clamp(0.0, 100.0);
    final pm25Score = (effectivePm25 / 250 * 100).clamp(0.0, 100.0);
    final pm10Score = (effectivePm10 / 430 * 100).clamp(0.0, 100.0);
    final pollutionScore = (aqiScore + pm25Score + pm10Score) / 3;

    final riskLevel = _riskLevelFor(pollutionScore);

    double minutes = _baselineMinutes - pollutionScore * 2;
    minutes = minutes.clamp(_minMinutes.toDouble(), _baselineMinutes.toDouble());

    double multiplier = 1.0;
    final reasons = <String>[];

    if (input.age != null && (input.age! < 12 || input.age! > 65)) {
      multiplier *= 0.85;
      reasons.add('your age group');
    }

    switch (input.respiratoryCondition) {
      case RespiratoryCondition.asthma:
        multiplier *= 0.70;
        reasons.add('asthma noted in your profile');
      case RespiratoryCondition.copd:
        multiplier *= 0.55;
        reasons.add('COPD noted in your profile');
      case RespiratoryCondition.other:
        multiplier *= 0.85;
        reasons.add('a respiratory condition noted in your profile');
      case RespiratoryCondition.none:
        break;
    }

    switch (input.allergyLevel) {
      case AllergyLevel.mild:
        multiplier *= 0.95;
      case AllergyLevel.moderate:
        multiplier *= 0.85;
        reasons.add('moderate allergy sensitivity');
      case AllergyLevel.severe:
        multiplier *= 0.70;
        reasons.add('severe allergy sensitivity');
      case AllergyLevel.none:
        break;
    }

    switch (input.activityLevel) {
      case ActivityLevel.high:
        multiplier *= 0.80;
        reasons.add('a high activity level');
      case ActivityLevel.moderate:
        multiplier *= 0.90;
      case ActivityLevel.low:
        break;
    }

    switch (input.outdoorExposure) {
      case OutdoorExposureLevel.high:
        multiplier *= 0.90;
      case OutdoorExposureLevel.moderate:
        multiplier *= 0.95;
      case OutdoorExposureLevel.low:
        break;
    }

    final estimatedMinutes = ((minutes * multiplier).round()).clamp(_minMinutes, _maxMinutes).toInt();

    final airQualityNote = pollutionScore > _elevatedThreshold
        ? 'PM2.5/PM10 and outdoor AQI are elevated'
        : pollutionScore > _moderateThreshold
            ? 'PM2.5/PM10 are moderately elevated'
            : 'current air quality is good';

    final explanation = reasons.isEmpty
        ? 'Estimated exposure reflects current air-quality conditions — $airQualityNote.'
        : 'Estimated exposure is shorter because $airQualityNote, and because of ${reasons.join(', ')}.';

    return ExposureEstimate(
      estimatedMinutes: estimatedMinutes,
      riskLevel: riskLevel,
      explanation: explanation,
      factors: [
        ExposureFactor('PM2.5', _bandLabel(pm25Score)),
        ExposureFactor('PM10', _bandLabel(pm10Score)),
        ExposureFactor('Outdoor AQI', input.aqi.toString()),
        ExposureFactor('Respiratory sensitivity', _respiratorySensitivityLabel(input)),
        ExposureFactor('Activity level', input.activityLevel.label),
      ],
    );
  }

  static RiskLevel _riskLevelFor(double pollutionScore) {
    if (pollutionScore > _highThreshold) return RiskLevel.high;
    if (pollutionScore > _elevatedThreshold) return RiskLevel.elevated;
    if (pollutionScore > _moderateThreshold) return RiskLevel.moderate;
    return RiskLevel.low;
  }

  static String _bandLabel(double score) {
    if (score > _highThreshold) return 'High';
    if (score > _elevatedThreshold) return 'Elevated';
    if (score > _moderateThreshold) return 'Moderate';
    return 'Good';
  }

  static String _respiratorySensitivityLabel(ExposureInput input) {
    if (input.respiratoryCondition == RespiratoryCondition.copd) return 'High';
    if (input.respiratoryCondition == RespiratoryCondition.asthma ||
        input.respiratoryCondition == RespiratoryCondition.other ||
        input.allergyLevel == AllergyLevel.severe) {
      return 'Moderate';
    }
    if (input.allergyLevel == AllergyLevel.moderate) return 'Mild';
    return 'Low';
  }
}
