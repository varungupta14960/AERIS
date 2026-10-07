import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/airhub_service.dart';
import '../services/exposure_estimation_service.dart';
import '../services/exposure_tracker.dart';
import '../services/health_profile_service.dart';
import '../services/sensor_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/metric_chart.dart';

/// Personal Exposure + Analytics. Shows the current detailed exposure
/// estimate, a cumulative session-exposure counter, and simulated
/// historical trends for PM2.5/PM10/temperature/humidity plus an
/// estimated-exposure trend, so the app can demonstrate that personal
/// exposure is not simply a snapshot of current AQI.
class ExposureScreen extends StatefulWidget {
  final SensorDataService sensorService;
  final AirHubService airHubService;
  final HealthProfileService healthProfileService;
  final ExposureTracker exposureTracker;
  final AirQualityData? outdoor;

  const ExposureScreen({
    super.key,
    required this.sensorService,
    required this.airHubService,
    required this.healthProfileService,
    required this.exposureTracker,
    required this.outdoor,
  });

  @override
  State<ExposureScreen> createState() => _ExposureScreenState();
}

class _ExposureScreenState extends State<ExposureScreen> {
  late final List<SensorReading> _history;

  @override
  void initState() {
    super.initState();
    _history = _generateHistory();
  }

  // Simulated 24-hour history, clearly labeled as such in the UI. Resets
  // on app restart — no persistent storage in this prototype.
  List<SensorReading> _generateHistory() {
    final random = Random();
    double pm25 = 20;
    double pm10 = 30;
    double temp = 26;
    double humidity = 58;
    final now = DateTime.now();
    return List.generate(24, (i) {
      pm25 = (pm25 + (random.nextDouble() - 0.5) * 6).clamp(8, 70).toDouble();
      pm10 = (pm10 + (random.nextDouble() - 0.5) * 7).clamp(pm25 + 4, 110).toDouble();
      temp = (temp + (random.nextDouble() - 0.5) * 0.6).clamp(22, 31).toDouble();
      humidity = (humidity + (random.nextDouble() - 0.5) * 3).clamp(40, 80).toDouble();
      return SensorReading(
        pm25: double.parse(pm25.toStringAsFixed(1)),
        pm10: double.parse(pm10.toStringAsFixed(1)),
        temperature: double.parse(temp.toStringAsFixed(1)),
        humidity: double.parse(humidity.toStringAsFixed(0)),
        timestamp: now.subtract(Duration(hours: 23 - i)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pm25Values = _history.map((r) => r.pm25).toList();
    final pm10Values = _history.map((r) => r.pm10).toList();
    final tempValues = _history.map((r) => r.temperature).toList();
    final avgPm25 = pm25Values.reduce((a, b) => a + b) / pm25Values.length;
    final peakPm25 = pm25Values.reduce((a, b) => a > b ? a : b);
    final avgPm10 = pm10Values.reduce((a, b) => a + b) / pm10Values.length;
    final peakPm10 = pm10Values.reduce((a, b) => a > b ? a : b);
    final avgTemp = tempValues.reduce((a, b) => a + b) / tempValues.length;

    // Historical reading -> estimated tolerable-exposure trend, using the
    // same default-profile model shown elsewhere, so the chart
    // demonstrates that exposure tracks more than just raw PM2.5.
    final exposureTrend = _history
        .map((r) => ExposureEstimationService.estimate(ExposureInput(
              pm25: r.pm25,
              pm10: r.pm10,
              aqi: widget.outdoor?.aqi ?? 70,
              temperature: r.temperature,
              humidity: r.humidity,
            )).estimatedMinutes)
        .toList();
    final avgExposure = exposureTrend.reduce((a, b) => a + b) / exposureTrend.length;
    final lowestExposure = exposureTrend.reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Exposure'),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: DemoModeBadge())],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('How current conditions translate into your personal exposure',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 18),
                ValueListenableBuilder<HealthProfile>(
                  valueListenable: widget.healthProfileService.profile,
                  builder: (context, profile, _) {
                    return StreamBuilder<SensorReading>(
                      stream: widget.sensorService.readings,
                      builder: (context, snapshot) {
                        final reading = snapshot.data;
                        return ValueListenableBuilder<AirHubStatus>(
                          valueListenable: widget.airHubService.status,
                          builder: (context, hubStatus, _) {
                            ExposureEstimate? estimate;
                            if (reading != null && widget.outdoor != null) {
                              estimate = ExposureEstimationService.estimate(ExposureInput(
                                age: profile.age,
                                respiratoryCondition: profile.respiratoryCondition,
                                allergyLevel: profile.allergyLevel,
                                activityLevel: profile.activityLevel,
                                outdoorExposure: profile.outdoorExposure,
                                pm25: reading.pm25,
                                pm10: reading.pm10,
                                aqi: widget.outdoor!.aqi,
                                temperature: reading.temperature,
                                humidity: reading.humidity,
                                airHubActive: hubStatus.fanOn,
                              ));
                            }
                            return ExposureEstimateCard(
                              estimate: estimate,
                              airHubActive: hubStatus.fanOn,
                              detailed: true,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<int>(
                  valueListenable: widget.exposureTracker.elevatedMinutes,
                  builder: (context, minutes, _) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CUMULATIVE EXPOSURE THIS SESSION',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            Text('${minutes}m at Moderate or higher',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 6),
                            Text(
                              'Time-weighted tracking (simulated session clock) — not just a snapshot of '
                              'the current reading. Resets when the app restarts.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const SectionLabel('24-hour summary · simulated'),
                ResponsiveGrid(wideColumns: 3, children: [
                  StatusCard(label: 'Average PM2.5', value: '${avgPm25.toStringAsFixed(1)} µg/m³', icon: Icons.show_chart),
                  StatusCard(label: 'Peak PM2.5', value: '${peakPm25.toStringAsFixed(1)} µg/m³', icon: Icons.trending_up),
                  StatusCard(label: 'Average PM10', value: '${avgPm10.toStringAsFixed(1)} µg/m³', icon: Icons.show_chart),
                  StatusCard(label: 'Peak PM10', value: '${peakPm10.toStringAsFixed(1)} µg/m³', icon: Icons.trending_up),
                  StatusCard(label: 'Average temperature', value: '${avgTemp.toStringAsFixed(1)} °C', icon: Icons.thermostat_outlined),
                  StatusCard(
                    label: 'Average estimated exposure',
                    value: '${avgExposure.round()}m',
                    icon: Icons.hourglass_bottom,
                  ),
                  StatusCard(
                    label: 'Lowest estimated exposure',
                    value: '${lowestExposure}m',
                    icon: Icons.warning_amber_outlined,
                    valueColor: AppTheme.categoryColor('Unhealthy (Sensitive)'),
                  ),
                ]),
                const SizedBox(height: 24),
                _ChartCard(title: 'PM2.5', color: scheme.primary, values: pm25Values),
                const SizedBox(height: 16),
                _ChartCard(title: 'PM10 (µg/m³)', color: const Color(0xFF7A5AC7), values: pm10Values),
                const SizedBox(height: 16),
                _ChartCard(title: 'Temperature', color: const Color(0xFFCB6E17), values: tempValues),
                const SizedBox(height: 16),
                _ChartCard(
                  title: 'Humidity',
                  color: const Color(0xFF2C6FA6),
                  values: _history.map((r) => r.humidity).toList(),
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: 'Estimated tolerable exposure (minutes) — default profile',
                  color: const Color(0xFF2E8B57),
                  values: exposureTrend.map((m) => m.toDouble()).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<double> values;
  const _ChartCard({required this.title, required this.color, required this.values});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            MetricChart(values: values, color: color, height: 120),
          ],
        ),
      ),
    );
  }
}
