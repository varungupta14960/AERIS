import 'dart:math';
import '../models/models.dart';

/// Abstraction for outdoor air quality data.
///
/// This is currently backed by [MockAirQualityService]. Later this can be
/// replaced by an implementation that calls a real weather/AQI API (e.g.
/// AccuWeather). No API key or network request is included in this
/// prototype — only simulated values.
abstract class AirQualityService {
  Future<AirQualityData> getCurrent();

  /// Switches the simulated environment (Good/Moderate/Poor/High).
  /// A real API-backed implementation can simply ignore this.
  void setScenario(EnvironmentScenario scenario) {}
}

class MockAirQualityService implements AirQualityService {
  final _random = Random();
  EnvironmentScenario _scenario = EnvironmentScenario.good;

  @override
  void setScenario(EnvironmentScenario scenario) => _scenario = scenario;

  @override
  Future<AirQualityData> getCurrent() async {
    final baseline = switch (_scenario) {
      EnvironmentScenario.good => 35,
      EnvironmentScenario.moderate => 72,
      EnvironmentScenario.poor => 120,
      EnvironmentScenario.high => 180,
    };
    final aqi = (baseline + _random.nextInt(15) - 7).clamp(5, 300).toInt();
    return AirQualityData(
      aqi: aqi,
      category: _categoryFor(aqi),
      location: 'Hyderabad, IN',
      lastUpdated: DateTime.now(),
    );
  }

  String _categoryFor(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy (Sensitive)';
    return 'Unhealthy';
  }
}
