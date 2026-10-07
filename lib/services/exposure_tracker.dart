import 'package:flutter/foundation.dart';
import 'exposure_estimation_service.dart';

/// Tracks cumulative simulated exposure for the current demo session
/// only — resets when the app restarts. Each recorded tick stands in
/// for one simulated minute of time-weighted exposure above "Good"
/// conditions, so the dashboard can show that exposure is not simply a
/// snapshot of current AQI.
class ExposureTracker {
  final ValueNotifier<int> elevatedMinutes = ValueNotifier<int>(0);

  void record(RiskLevel level) {
    if (level != RiskLevel.low) {
      elevatedMinutes.value = elevatedMinutes.value + 1;
    }
  }

  void dispose() {
    elevatedMinutes.dispose();
  }
}
