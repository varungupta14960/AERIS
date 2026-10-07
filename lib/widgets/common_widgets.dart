import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/alert_service.dart';
import '../services/exposure_estimation_service.dart';
import '../services/recommendation_service.dart';
import '../theme/app_theme.dart';

/// Small uppercase section label used to introduce a group of content
/// (e.g. "SUPPORTING DATA", "DEVICE STATUS").
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

/// Minimal metric tile — muted uppercase label + a large value. No large
/// colored icon backgrounds, to keep the grid visually quiet next to the
/// dominant air-quality card.
class StatusCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const StatusCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    color: valueColor ?? scheme.onSurface,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// The dominant status badge on device screens ("Connected / Demo",
/// "Active", "Standby") — a small dot + label, not a big colored icon.
class StatusDot extends StatelessWidget {
  final String label;
  final Color color;
  const StatusDot({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Compact badge marking simulated data, used consistently across
/// every screen. Understated by design — a small pill, not a banner.
class DemoModeBadge extends StatelessWidget {
  const DemoModeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_outlined, size: 13, color: scheme.onSecondaryContainer),
          const SizedBox(width: 5),
          Text(
            'DEMO MODE',
            style: TextStyle(
              color: scheme.onSecondaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// One-line note clarifying that data is simulated, for use under
/// specific values/sections rather than as a full banner everywhere.
class SimulatedNote extends StatelessWidget {
  final String text;
  const SimulatedNote({super.key, this.text = 'Simulated sensor data — not from physical hardware.'});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.info_outline, size: 13, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// Grid that lays out children as 1 column on narrow screens and more on
/// wide screens, keeping the responsiveness logic in one simple place.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int wideColumns;
  const ResponsiveGrid({super.key, required this.children, this.wideColumns = 2});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 700 ? wideColumns : 1;
      return GridView.count(
        crossAxisCount: columns,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: columns >= 2 ? 2.6 : 3.2,
        children: children,
      );
    });
  }
}

/// Caption used under a concept/product visual, making clear it is a
/// demonstration illustration rather than the manufactured device.
class ConceptCaption extends StatelessWidget {
  final String title;
  const ConceptCaption(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          'Concept visual — demonstration only, not the manufactured device.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Simple wearable-style illustration for AERIS AirBand, built entirely
/// from basic shapes (no image asset, no extra dependency) so it can't
/// fail to load during a live demo.
class AirBandConceptVisual extends StatelessWidget {
  const AirBandConceptVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget band(double height) => Container(
          width: 46,
          height: height,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
          ),
        );

    return SizedBox(
      height: 190,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          band(28),
          Container(
            width: 108,
            height: 78,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.primary.withOpacity(0.6), width: 2),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.air, size: 22, color: scheme.primary),
            ),
          ),
          band(28),
        ],
      ),
    );
  }
}

/// Simple cube-appliance illustration for AERIS AirHub, built entirely
/// from basic shapes (no image asset, no extra dependency).
class AirHubConceptVisual extends StatelessWidget {
  const AirHubConceptVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 190,
      child: Center(
        child: Container(
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.9), width: 1.5),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppTheme.categoryColor('Good'),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple architecture flow diagram: a vertical chain of labeled steps
/// connected by arrows. Used on device screens and About.
class FlowDiagram extends StatelessWidget {
  final List<String> steps;
  const FlowDiagram({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
              borderRadius: BorderRadius.circular(AppTheme.radius - 4),
            ),
            child: Text(
              steps[i],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (i != steps.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.arrow_downward, size: 16, color: scheme.onSurfaceVariant),
            ),
        ],
      ],
    );
  }
}

/// The Estimated Exposure card. Used in compact form on the Dashboard
/// and in detailed form (with the extra explanatory paragraph) on the
/// Exposure screen, so both stay visually and logically consistent.
class ExposureEstimateCard extends StatelessWidget {
  final ExposureEstimate? estimate;
  final bool airHubActive;
  final bool detailed;

  const ExposureEstimateCard({
    super.key,
    required this.estimate,
    required this.airHubActive,
    this.detailed = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final est = estimate;
    final color = est == null ? scheme.onSurfaceVariant : AppTheme.categoryColor(est.riskLevel.categoryName);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ESTIMATED EXPOSURE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            Text(
              est == null ? '—' : '~${est.formatted}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 32, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              'Current conditions: ${est?.riskLevel.label ?? 'Loading'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (est != null) ...[
              const SizedBox(height: 10),
              Text(est.explanation, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: est.factors
                    .map((f) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${f.label}: ${f.value}', style: Theme.of(context).textTheme.bodySmall),
                        ))
                    .toList(),
              ),
              if (airHubActive) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.air, size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('AirHub purification active — reflects a simulated indoor improvement.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ),
                  ],
                ),
              ],
              if (detailed) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Exposure is not the same as AQI. The same outdoor AQI can mean a shorter or '
                  'longer personal exposure window depending on how long you spend in it, your '
                  'activity level, and factors in your health profile.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
            const SizedBox(height: 12),
            Text(
              'Based on your health profile and current air-quality conditions.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 2),
            Text(
              'Prototype exposure estimate — not medical advice.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard recommendation card — generated text, not static copy.
class RecommendationCard extends StatelessWidget {
  final Recommendation? recommendation;
  final VoidCallback? onActivateAirHub;

  const RecommendationCard({super.key, required this.recommendation, this.onActivateAirHub});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rec = recommendation;
    if (rec == null) return const SizedBox.shrink();
    final color = AppTheme.categoryColor(rec.level.categoryName);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(rec.title, style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(rec.body, style: Theme.of(context).textTheme.bodyMedium),
            if (rec.suggestAirHub && onActivateAirHub != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onActivateAirHub,
                icon: const Icon(Icons.air, size: 16),
                label: const Text('Activate AirHub (Demo)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact alerts list — severity-colored left border, capped length
/// (handled by AlertService), no dedicated screen needed.
class AlertsList extends StatelessWidget {
  final List<AppAlert> alerts;
  const AlertsList({super.key, required this.alerts});

  Color _colorFor(BuildContext context, AlertSeverity s) {
    final scheme = Theme.of(context).colorScheme;
    return switch (s) {
      AlertSeverity.critical => AppTheme.categoryColor('Unhealthy'),
      AlertSeverity.warning => AppTheme.categoryColor('Moderate'),
      AlertSeverity.info => scheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: alerts
          .map((a) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border(left: BorderSide(color: _colorFor(context, a.severity), width: 3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(a.message, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

/// Understated demo control letting a presenter switch between
/// representative environmental states without exposing raw sensor
/// controls.
class ScenarioSelector extends StatelessWidget {
  final EnvironmentScenario value;
  final ValueChanged<EnvironmentScenario> onChanged;
  const ScenarioSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text('Demo scenario', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<EnvironmentScenario>(
              segments: EnvironmentScenario.values
                  .map((s) => ButtonSegment(value: s, label: Text(s.label)))
                  .toList(),
              selected: {value},
              showSelectedIcon: false,
              onSelectionChanged: (s) => onChanged(s.first),
            ),
          ),
        ),
      ],
    );
  }
}
