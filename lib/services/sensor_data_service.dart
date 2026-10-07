import 'dart:async';
import 'dart:math';
import '../models/models.dart';

/// Abstraction for AirBand sensor data (PM2.5, temperature, humidity).
///
/// Replace [MockSensorDataService] with a real implementation once the
/// ESP32 + PMS7003 + SHT30 hardware (AirBand) is connected, e.g. over
/// BLE/Wi-Fi. The rest of the app only depends on this interface.
abstract class SensorDataService {
  bool get isConnected;
  Stream<SensorReading> get readings;
  List<SensorReading> get history;

  /// Switches the simulated environment (Good/Moderate/Poor/High).
  /// A real hardware-backed implementation can simply ignore this.
  void setScenario(EnvironmentScenario scenario) {}

  void dispose();
}

class MockSensorDataService implements SensorDataService {
  final _controller = StreamController<SensorReading>.broadcast();
  final _random = Random();
  final List<SensorReading> _history = [];
  Timer? _timer;

  double _pm25 = 18;
  double _pm10 = 27; // PM10 generally runs higher than PM2.5
  double _temp = 27.4;
  double _humidity = 61;

  // Target baselines the simulation gradually drifts toward whenever the
  // demo scenario changes, so transitions feel like a real changing
  // environment rather than an instant jump.
  double _targetPm25 = 18;
  double _targetTemp = 27.4;
  double _targetHumidity = 61;

  MockSensorDataService() {
    _emit(); // seed an initial reading
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _emit());
  }

  @override
  void setScenario(EnvironmentScenario scenario) {
    switch (scenario) {
      case EnvironmentScenario.good:
        _targetPm25 = 10;
        _targetTemp = 24;
        _targetHumidity = 50;
      case EnvironmentScenario.moderate:
        _targetPm25 = 28;
        _targetTemp = 27;
        _targetHumidity = 60;
      case EnvironmentScenario.poor:
        _targetPm25 = 55;
        _targetTemp = 30;
        _targetHumidity = 68;
      case EnvironmentScenario.high:
        _targetPm25 = 95;
        _targetTemp = 32;
        _targetHumidity = 75;
    }
  }

  void _emit() {
    // Drift gradually toward the current target (changes with scenario),
    // plus a small random wobble — avoids both "frozen" values and
    // erratic frame-to-frame jumps.
    _pm25 = (_pm25 + (_targetPm25 - _pm25) * 0.25 + (_random.nextDouble() - 0.5) * 2)
        .clamp(5, 150)
        .toDouble();
    // PM10 tracks PM2.5 (coarse + fine particles) and stays >= PM2.5.
    final targetPm10 = _targetPm25 * 1.5;
    _pm10 = (_pm10 + (targetPm10 - _pm10) * 0.25 + (_random.nextDouble() - 0.5) * 3)
        .clamp(_pm25 + 4, 220)
        .toDouble();
    _temp = (_temp + (_targetTemp - _temp) * 0.2 + (_random.nextDouble() - 0.5) * 0.3)
        .clamp(18, 38)
        .toDouble();
    _humidity = (_humidity + (_targetHumidity - _humidity) * 0.2 + (_random.nextDouble() - 0.5) * 1.5)
        .clamp(25, 95)
        .toDouble();

    final reading = SensorReading(
      pm25: double.parse(_pm25.toStringAsFixed(1)),
      pm10: double.parse(_pm10.toStringAsFixed(1)),
      temperature: double.parse(_temp.toStringAsFixed(1)),
      humidity: double.parse(_humidity.toStringAsFixed(0)),
      timestamp: DateTime.now(),
    );

    _history.add(reading);
    if (_history.length > 30) _history.removeAt(0);
    _controller.add(reading);
  }

  @override
  bool get isConnected => true; // simulated AirBand is always "connected" in demo mode

  @override
  Stream<SensorReading> get readings => _controller.stream;

  @override
  List<SensorReading> get history => List.unmodifiable(_history);

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
