import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

/// Educational "About AERIS" page: the problem, the three ecosystem
/// parts, how they fit together, and current project status. Kept
/// concise and card-based rather than a wall of text.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About AERIS')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AERIS', style: textTheme.headlineSmall?.copyWith(fontSize: 26)),
                  Text('A Personal Air Exposure Management System',
                      style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  const DemoModeBadge(),
                  const SizedBox(height: 20),
                  _InfoCard(
                    icon: Icons.help_outline,
                    title: 'The problem',
                    body: 'Regional AQI describes one monitoring station, not the air around a '
                        'specific person. Two people in the same city can have very different '
                        'personal exposure depending on where they spend time, how long, and '
                        'their own sensitivity. AERIS explores sensing and estimating exposure '
                        'at the personal level.',
                  ),
                  _InfoCard(
                    icon: Icons.watch_outlined,
                    title: 'AirBand',
                    body: 'A wearable sensing concept (ESP32 + PMS7003 particulate sensor + '
                        'SHT30 temperature/humidity sensor + OLED display) intended to measure '
                        'the air immediately around the person wearing it.',
                  ),
                  _InfoCard(
                    icon: Icons.phone_iphone,
                    title: 'The mobile application',
                    body: 'Combines AirBand readings with outdoor AQI and a local, non-medical '
                        'health profile to produce a prototype personal exposure estimate, '
                        'contextual recommendations, and analytics — this app.',
                  ),
                  _InfoCard(
                    icon: Icons.air,
                    title: 'AirHub',
                    body: 'A localized mitigation concept — a compact enclosure using a '
                        'centrifugal fan, MOSFET driver, HEPA filter, and activated-carbon '
                        'filter — intended to improve air quality in the immediate space.',
                  ),
                  _InfoCard(
                    icon: Icons.hub_outlined,
                    title: 'How the ecosystem works',
                    body: 'Personal sensing → exposure estimation → user feedback → '
                        'personalized recommendation → localized mitigation. Poor conditions '
                        'can trigger an alert, a recommendation, and the option to activate '
                        'AirHub — making the sensing-to-response pipeline visible.',
                  ),
                  _InfoCard(
                    icon: Icons.science_outlined,
                    title: 'Current project status',
                    body: 'This is a conceptual/proof-of-concept stage: sensor-to-microcontroller '
                        'acquisition, ESP32-based processing concepts, exposure-estimation logic, '
                        'this mobile application, and CAD designs for both AirBand and AirHub have '
                        'been demonstrated. End-to-end physical hardware integration between '
                        'AirBand, this app, and AirHub has not yet been fully validated — the app '
                        'runs in DEMO MODE with simulated sensor data until that integration is '
                        'complete.',
                  ),
                  _InfoCard(
                    icon: Icons.upcoming_outlined,
                    title: 'Future integration',
                    body: 'Planned next steps include validating live AirBand → app connectivity, '
                        'closing the loop so the app can command AirHub directly, and refining '
                        'the exposure model with real measured data.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _InfoCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(body, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
