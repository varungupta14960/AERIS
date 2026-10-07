import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/sensor_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/metric_chart.dart';

class AirBandScreen extends StatelessWidget {
  final SensorDataService sensorService;
  const AirBandScreen({super.key, required this.sensorService});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AERIS AirBand'),
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
                Text('Personal environmental sensing',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const AirBandConceptVisual(),
                        const SizedBox(height: 12),
                        const ConceptCaption('AERIS AirBand — Concept Prototype'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                StreamBuilder<SensorReading>(
                  stream: sensorService.readings,
                  builder: (context, snapshot) {
                    final reading = snapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ResponsiveGrid(wideColumns: 3, children: [
                          StatusCard(
                            label: 'Connection',
                            value: sensorService.isConnected ? 'Connected · Demo' : 'Offline',
                            icon: Icons.sensors_outlined,
                            valueColor: AppTheme.categoryColor('Good'),
                          ),
                          StatusCard(
                            label: 'Air quality',
                            value: reading?.airQualityCategory ?? '—',
                            icon: Icons.eco_outlined,
                            valueColor: reading == null ? null : AppTheme.categoryColor(reading.airQualityCategory),
                          ),
                          StatusCard(
                            label: 'PM2.5',
                            value: reading == null ? '—' : '${reading.pm25.toStringAsFixed(1)} µg/m³',
                            icon: Icons.blur_on,
                          ),
                          StatusCard(
                            label: 'PM10',
                            value: reading == null ? '—' : '${reading.pm10.toStringAsFixed(1)} µg/m³',
                            icon: Icons.grain,
                          ),
                          StatusCard(
                            label: 'AQI proxy (local)',
                            value: reading == null ? '—' : (reading.pm25 * 4.3).round().clamp(0, 500).toString(),
                            icon: Icons.speed_outlined,
                          ),
                          StatusCard(
                            label: 'Last update',
                            value: reading == null ? '—' : _relativeTime(reading.timestamp),
                            icon: Icons.update,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _MetricChartCard(
                          title: 'PM2.5 — Last readings',
                          currentValue: reading == null ? '—' : '${reading.pm25.toStringAsFixed(1)} µg/m³',
                          color: scheme.primary,
                          values: sensorService.history.map((r) => r.pm25).toList(),
                        ),
                        const SizedBox(height: 16),
                        _MetricChartCard(
                          title: 'PM10 — Last readings',
                          currentValue: reading == null ? '—' : '${reading.pm10.toStringAsFixed(1)} µg/m³',
                          color: const Color(0xFF7A5AC7),
                          values: sensorService.history.map((r) => r.pm10).toList(),
                        ),
                        const SizedBox(height: 16),
                        _MetricChartCard(
                          title: 'Temperature — Last readings',
                          currentValue: reading == null ? '—' : '${reading.temperature.toStringAsFixed(1)} °C',
                          color: const Color(0xFFCB6E17),
                          values: sensorService.history.map((r) => r.temperature).toList(),
                        ),
                        const SizedBox(height: 16),
                        _MetricChartCard(
                          title: 'Humidity — Last readings',
                          currentValue: reading == null ? '—' : '${reading.humidity.toStringAsFixed(0)}%',
                          color: const Color(0xFF2C6FA6),
                          values: sensorService.history.map((r) => r.humidity).toList(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('How a reading reaches the app', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 14),
                        const FlowDiagram(steps: [
                          'AirBand sensors (PMS7003 + SHT30)',
                          'ESP32 (concept)',
                          'AQI / exposure estimation',
                          'AERIS app',
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SimulatedNote(
                  text: 'Readings above are simulated in this prototype and are not '
                      'currently coming from the physical AirBand device.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _relativeTime(DateTime timestamp) {
  final seconds = DateTime.now().difference(timestamp).inSeconds;
  if (seconds < 5) return 'Just now';
  if (seconds < 60) return '${seconds}s ago';
  return '${(seconds / 60).floor()}m ago';
}

class _MetricChartCard extends StatelessWidget {
  final String title;
  final String currentValue;
  final Color color;
  final List<double> values;

  const _MetricChartCard({
    required this.title,
    required this.currentValue,
    required this.color,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ),
                Text(currentValue, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            MetricChart(values: values, color: color, height: 110),
          ],
        ),
      ),
    );
  }
}
