/// Simple data models used across AERIS.
/// All values shown in the app are SIMULATED (demo mode) unless the
/// hardware integration described in the project docs is completed.

class SensorReading {
  final double pm25; // µg/m³
  final double pm10; // µg/m³
  final double temperature; // °C
  final double humidity; // %
  final DateTime timestamp;

  const SensorReading({
    required this.pm25,
    required this.pm10,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  String get airQualityCategory {
    if (pm25 <= 12) return 'Good';
    if (pm25 <= 35) return 'Moderate';
    if (pm25 <= 55) return 'Unhealthy (Sensitive)';
    return 'Unhealthy';
  }
}

class AirQualityData {
  final int aqi;
  final String category;
  final String location;
  final DateTime lastUpdated;

  const AirQualityData({
    required this.aqi,
    required this.category,
    required this.location,
    required this.lastUpdated,
  });
}

class AirHubStatus {
  final bool fanOn;
  final bool isConnected;
  final int filterHealthPercent;
  final int estimatedFilterLifeDays;

  const AirHubStatus({
    required this.fanOn,
    required this.isConnected,
    required this.filterHealthPercent,
    required this.estimatedFilterLifeDays,
  });

  String get purificationStatus => fanOn ? 'Purifying' : 'Idle';

  AirHubStatus copyWith({bool? fanOn}) {
    return AirHubStatus(
      fanOn: fanOn ?? this.fanOn,
      isConnected: isConnected,
      filterHealthPercent: filterHealthPercent,
      estimatedFilterLifeDays: estimatedFilterLifeDays,
    );
  }
}

/// Demo/simulation environmental states. Lets a presenter switch between
/// representative conditions without exposing raw sensor controls.
enum EnvironmentScenario { good, moderate, poor, high }

extension EnvironmentScenarioLabel on EnvironmentScenario {
  String get label => switch (this) {
        EnvironmentScenario.good => 'Good',
        EnvironmentScenario.moderate => 'Moderate',
        EnvironmentScenario.poor => 'Poor',
        EnvironmentScenario.high => 'High exposure',
      };
}

/// User-reported respiratory condition, used only to adjust the local
/// prototype exposure estimate. Not a medical record.
enum RespiratoryCondition { none, asthma, copd, other }

enum AllergyLevel { none, mild, moderate, severe }

enum ActivityLevel { low, moderate, high }

enum OutdoorExposureLevel { low, moderate, high }

extension RespiratoryConditionLabel on RespiratoryCondition {
  String get label => switch (this) {
        RespiratoryCondition.none => 'None',
        RespiratoryCondition.asthma => 'Asthma',
        RespiratoryCondition.copd => 'COPD',
        RespiratoryCondition.other => 'Other',
      };
}

extension AllergyLevelLabel on AllergyLevel {
  String get label => switch (this) {
        AllergyLevel.none => 'None',
        AllergyLevel.mild => 'Mild',
        AllergyLevel.moderate => 'Moderate',
        AllergyLevel.severe => 'Severe',
      };
}

extension ActivityLevelLabel on ActivityLevel {
  String get label => switch (this) {
        ActivityLevel.low => 'Low',
        ActivityLevel.moderate => 'Moderate',
        ActivityLevel.high => 'High',
      };
}

extension OutdoorExposureLevelLabel on OutdoorExposureLevel {
  String get label => switch (this) {
        OutdoorExposureLevel.low => 'Low',
        OutdoorExposureLevel.moderate => 'Moderate',
        OutdoorExposureLevel.high => 'High',
      };
}

/// Local-only health profile used to personalize the prototype exposure
/// estimate. Held in app state for the current demo session — not sent
/// anywhere, not persisted, not a medical record.
class HealthProfile {
  final String name;
  final int? age;
  final String sex;
  final double? heightCm;
  final double? weightKg;
  final RespiratoryCondition respiratoryCondition;
  final AllergyLevel allergyLevel;
  final ActivityLevel activityLevel;
  final OutdoorExposureLevel outdoorExposure;

  const HealthProfile({
    this.name = '',
    this.age,
    this.sex = 'Prefer not to say',
    this.heightCm,
    this.weightKg,
    this.respiratoryCondition = RespiratoryCondition.none,
    this.allergyLevel = AllergyLevel.none,
    this.activityLevel = ActivityLevel.moderate,
    this.outdoorExposure = OutdoorExposureLevel.moderate,
  });

  HealthProfile copyWith({
    String? name,
    int? age,
    String? sex,
    double? heightCm,
    double? weightKg,
    RespiratoryCondition? respiratoryCondition,
    AllergyLevel? allergyLevel,
    ActivityLevel? activityLevel,
    OutdoorExposureLevel? outdoorExposure,
  }) {
    return HealthProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      respiratoryCondition: respiratoryCondition ?? this.respiratoryCondition,
      allergyLevel: allergyLevel ?? this.allergyLevel,
      activityLevel: activityLevel ?? this.activityLevel,
      outdoorExposure: outdoorExposure ?? this.outdoorExposure,
    );
  }
}
