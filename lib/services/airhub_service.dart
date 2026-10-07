import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Abstraction for AirHub (the purifier unit: ESP32 + MOSFET +
/// centrifugal fan + HEPA/carbon filters).
///
/// Replace [MockAirHubService] with a real implementation once the ESP32
/// on AirHub can be commanded directly. For now, toggling the fan only
/// changes local state.
abstract class AirHubService {
  ValueListenable<AirHubStatus> get status;
  void toggleFan();
  void dispose();
}

class MockAirHubService implements AirHubService {
  final ValueNotifier<AirHubStatus> _status = ValueNotifier(
    const AirHubStatus(
      fanOn: true,
      isConnected: true,
      filterHealthPercent: 94,
      estimatedFilterLifeDays: 42,
    ),
  );

  @override
  ValueListenable<AirHubStatus> get status => _status;

  @override
  void toggleFan() {
    _status.value = _status.value.copyWith(fanOn: !_status.value.fanOn);
  }

  @override
  void dispose() {
    _status.dispose();
  }
}
