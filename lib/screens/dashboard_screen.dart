import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/airhub_service.dart';
import '../services/alert_service.dart';
import '../services/exposure_estimation_service.dart';
import '../services/health_profile_service.dart';
import '../services/recommendation_service.dart';
import '../services/sensor_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final SensorDataService sensorService;
  final AirHubService airHubService;
  final HealthProfileService healthProfileService;
  final AirQualityData? outdoor;
  final EnvironmentScenario scenario;
  final ValueChanged<EnvironmentScenario> onScenarioChanged;
  final VoidCallback onViewExposure;

  const DashboardScreen({
    super.key,
    required this.sensorService,
    required this.airHubService,
    required this.healthProfileService,
    required this.outdoor,
    required this.scenario,
    required this.onScenarioChanged,
    required this.onViewExposure,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                const SizedBox(height: 14),
                ScenarioSelector(value: scenario, onChanged: onScenarioChanged),
                const SizedBox(height: 20),
                StreamBuilder<SensorReading>(
                  stream: sensorService.readings,
                  builder: (context, snapshot) => _PrimaryAirQualityCard(reading: snapshot.data),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<HealthProfile>(
                  valueListenable: healthProfileService.profile,
                  builder: (context, profile, _) {
                    return StreamBuilder<SensorReading>(
                      stream: sensorService.readings,
                      builder: (context, snapshot) {
                        final reading = snapshot.data;
                        return ValueListenableBuilder<AirHubStatus>(
                          valueListenable: airHubService.status,
                          builder: (context, hubStatus, _) {
                            ExposureEstimate? estimate;
                            Recommendation? recommendation;
                            List<AppAlert> alerts = const [];
                            if (reading != null && outdoor != null) {
                              estimate = ExposureEstimationService.estimate(ExposureInput(
                                age: profile.age,
                                respiratoryCondition: profile.respiratoryCondition,
                                allergyLevel: profile.allergyLevel,
                                activityLevel: profile.activityLevel,
                                outdoorExposure: profile.outdoorExposure,
                                pm25: reading.pm25,
                                pm10: reading.pm10,
                                aqi: outdoor!.aqi,
                                temperature: reading.temperature,
                                humidity: reading.humidity,
                                airHubActive: hubStatus.fanOn,
                              ));
                              recommendation = RecommendationService.generate(
                                reading: reading,
                                outdoor: outdoor!,
                                exposure: estimate,
                                profile: profile,
                                airHubOn: hubStatus.fanOn,
                              );
                              alerts = AlertService.generate(reading: reading, hub: hubStatus, exposure: estimate);
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ExposureEstimateCard(estimate: estimate, airHubActive: hubStatus.fanOn),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: onViewExposure,
                                    icon: const Icon(Icons.arrow_forward, size: 16),
                                    label: const Text('View exposure details'),
                                  ),
                                ),
                                if (alerts.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  AlertsList(alerts: alerts),
                                ],
                                const SizedBox(height: 8),
                                RecommendationCard(
                                  recommendation: recommendation,
                                  onActivateAirHub: hubStatus.fanOn ? null : airHubService.toggleFan,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                const SectionLabel('Supporting data'),
                StreamBuilder<SensorReading>(
                  stream: sensorService.readings,
                  builder: (context, snapshot) {
                    final reading = snapshot.data;
                    return ResponsiveGrid(wideColumns: 3, children: [
                      StatusCard(
                        label: 'Temperature',
                        value: reading == null ? '—' : '${reading.temperature.toStringAsFixed(1)} °C',
                        icon: Icons.thermostat_outlined,
                      ),
                      StatusCard(
                        label: 'Humidity',
                        value: reading == null ? '—' : '${reading.humidity.toStringAsFixed(0)}%',
                        icon: Icons.water_drop_outlined,
                      ),
                      StatusCard(
                        label: 'Outdoor AQI',
                        value: outdoor == null ? '—' : '${outdoor!.aqi} · ${outdoor!.category}',
                        icon: Icons.public_outlined,
                      ),
                    ]);
                  },
                ),
                const SizedBox(height: 24),
                const SectionLabel('Device status'),
                ValueListenableBuilder<AirHubStatus>(
                  valueListenable: airHubService.status,
                  builder: (context, hubStatus, _) {
                    return ResponsiveGrid(children: [
                      StatusCard(
                        label: 'AERIS AirBand',
                        value: sensorService.isConnected ? 'Connected · Demo' : 'Offline',
                        icon: Icons.sensors_outlined,
                        valueColor: AppTheme.categoryColor('Good'),
                      ),
                      StatusCard(
                        label: 'AERIS AirHub',
                        value: hubStatus.isConnected ? 'Connected · Demo' : 'Offline',
                        icon: Icons.air_outlined,
                        valueColor: AppTheme.categoryColor('Good'),
                      ),
                      StatusCard(
                        label: 'Fan',
                        value: hubStatus.fanOn ? 'Running' : 'Off',
                        icon: Icons.toys_outlined,
                      ),
                      StatusCard(
                        label: 'Filter',
                        value: '${hubStatus.filterHealthPercent}% remaining',
                        icon: Icons.filter_alt_outlined,
                      ),
                    ]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AERIS',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 26,
                        letterSpacing: 0.5,
                      )),
              Text('Personal Air Intelligence',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
        const DemoModeBadge(),
      ],
    );
  }
}

class _PrimaryAirQualityCard extends StatelessWidget {
  final SensorReading? reading;
  const _PrimaryAirQualityCard({required this.reading});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final category = reading?.airQualityCategory ?? 'Loading';
    final color = AppTheme.categoryColor(category);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text('AIR QUALITY',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              category,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 32,
                    color: color,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  reading == null ? '—' : reading!.pm25.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 40),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('µg/m³ · PM2.5',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  reading == null ? '—' : reading!.pm10.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                ),
                const SizedBox(width: 6),
                Text('µg/m³ · PM10',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
