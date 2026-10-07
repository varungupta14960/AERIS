import '../models/models.dart';
import 'exposure_estimation_service.dart';

enum AlertSeverity { info, warning, critical }

/// A single alert: what happened, why it matters, and what the user can
/// do about it — generated from current conditions, not static text.
class AppAlert {
  final String title;
  final String message;
  final AlertSeverity severity;

  const AppAlert({required this.title, required this.message, required this.severity});
}

/// Centralized alert rules. Capped and deduplicated so the UI never
/// turns into notification spam during a live demo.
class AlertService {
  static List<AppAlert> generate({
    required SensorReading reading,
    required AirHubStatus hub,
    required ExposureEstimate exposure,
  }) {
    final alerts = <AppAlert>[];

    if (exposure.riskLevel == RiskLevel.high) {
      alerts.add(const AppAlert(
        title: 'High exposure risk',
        message: 'Current conditions and your profile suggest a short safe exposure window. '
            'Consider reducing time in this environment.',
        severity: AlertSeverity.critical,
      ));
    } else if (exposure.riskLevel == RiskLevel.elevated) {
      alerts.add(const AppAlert(
        title: 'Prolonged exposure caution',
        message: 'Particulate levels are elevated. Avoid extended time in this environment '
            'without mitigation.',
        severity: AlertSeverity.warning,
      ));
    }

    final category = reading.airQualityCategory;
    if ((category == 'Unhealthy' || category == 'Unhealthy (Sensitive)') && !hub.fanOn) {
      alerts.add(const AppAlert(
        title: 'AirHub inactive during poor conditions',
        message: 'Air quality is degraded and AirHub is in standby. Activating it simulates a '
            'modest indoor improvement.',
        severity: AlertSeverity.warning,
      ));
    }

    if (reading.pm25 > 55) {
      alerts.add(const AppAlert(
        title: 'Elevated PM2.5',
        message: 'Fine particulate matter is elevated above typical healthy thresholds.',
        severity: AlertSeverity.warning,
      ));
    }

    if (hub.filterHealthPercent < 20) {
      alerts.add(AppAlert(
        title: 'Filter replacement reminder',
        message: 'AirHub filter life is at ${hub.filterHealthPercent}% — plan a replacement soon.',
        severity: AlertSeverity.info,
      ));
    }

    // Cap and sort so the most severe alerts surface first.
    alerts.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return alerts.take(3).toList();
  }
}
