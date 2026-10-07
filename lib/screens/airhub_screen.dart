import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/airhub_service.dart';
import '../services/exposure_estimation_service.dart';
import '../services/health_profile_service.dart';
import '../services/sensor_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AirHubScreen extends StatelessWidget {
  final AirHubService airHubService;
  final SensorDataService sensorService;
  final HealthProfileService healthProfileService;
  final AirQualityData? outdoor;

  const AirHubScreen({
    super.key,
    required this.airHubService,
    required this.sensorService,
    required this.healthProfileService,
    required this.outdoor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AERIS AirHub'),
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
                Text('Active air purification',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const AirHubConceptVisual(),
                        const SizedBox(height: 12),
                        const ConceptCaption('AERIS AirHub — Concept Prototype'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<AirHubStatus>(
                  valueListenable: airHubService.status,
                  builder: (context, status, _) {
                    final purifying = status.fanOn;
                    final statusColor = purifying ? AppTheme.categoryColor('Good') : scheme.onSurfaceVariant;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dominant purification-status card, mirroring the
                        // primary card pattern used on the Dashboard.
                        Card(
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
                                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('PURIFICATION',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(color: scheme.onSurfaceVariant)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  purifying ? 'Active' : 'Standby',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontSize: 32,
                                        color: statusColor,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  status.isConnected ? 'AirHub connected · Demo' : 'AirHub offline',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: 20),
                                Text('AirHub Control — Demo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: scheme.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: airHubService.toggleFan,
                                    icon: Icon(purifying ? Icons.power_settings_new : Icons.play_arrow),
                                    label: Text(purifying ? 'Turn fan off' : 'Turn fan on'),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const SimulatedNote(
                                  text: 'Updates on-screen state only; no command is sent to physical '
                                      'hardware.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const SectionLabel('Device status'),
                        ResponsiveGrid(wideColumns: 3, children: [
                          StatusCard(
                            label: 'Fan',
                            value: status.fanOn ? 'On' : 'Off',
                            icon: Icons.toys_outlined,
                          ),
                          StatusCard(
                            label: 'Filter life',
                            value: '${status.filterHealthPercent}%',
                            icon: Icons.filter_alt_outlined,
                            valueColor: status.filterHealthPercent >= 20
                                ? AppTheme.categoryColor('Good')
                                : AppTheme.categoryColor('Unhealthy'),
                          ),
                          StatusCard(
                            label: 'Estimated life left',
                            value: '${status.estimatedFilterLifeDays} days',
                            icon: Icons.schedule_outlined,
                          ),
                          const StatusCard(
                            label: 'HEPA filter',
                            value: 'Good',
                            icon: Icons.filter_1_outlined,
                          ),
                          const StatusCard(
                            label: 'Activated carbon',
                            value: 'Good',
                            icon: Icons.filter_2_outlined,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        const SectionLabel('Effect on current environment'),
                        ValueListenableBuilder<HealthProfile>(
                          valueListenable: healthProfileService.profile,
                          builder: (context, profile, _) {
                            return StreamBuilder<SensorReading>(
                              stream: sensorService.readings,
                              builder: (context, snapshot) {
                                final reading = snapshot.data;
                                if (reading == null || outdoor == null) {
                                  return const SizedBox.shrink();
                                }
                                final baseline = ExposureEstimationService.estimate(ExposureInput(
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
                                  airHubActive: false,
                                ));
                                final withHub = ExposureEstimationService.estimate(ExposureInput(
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
                                  airHubActive: true,
                                ));
                                final deltaMinutes = withHub.estimatedMinutes - baseline.estimatedMinutes;

                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          purifying ? 'AirHub purification active' : 'AirHub in standby',
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Estimated indoor improvement — prototype simulation',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: scheme.onSurfaceVariant)),
                                        const SizedBox(height: 14),
                                        if (purifying)
                                          Text(
                                            'Estimated exposure with AirHub running: ~${withHub.formatted} '
                                            '(+${deltaMinutes}m vs. AirHub off).',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          )
                                        else
                                          Text(
                                            'Baseline estimated exposure (AirHub off): ~${baseline.formatted}. '
                                            'Turning AirHub on simulates a modest improvement.',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        const SizedBox(height: 12),
                                        const SimulatedNote(
                                          text: 'AirHub control is currently simulated because the physical '
                                              'hardware is not yet connected.',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
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
