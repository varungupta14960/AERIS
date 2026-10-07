import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A minimal, non-interactive line chart for a single metric (PM2.5,
/// temperature, or humidity). Deliberately undecorated — no tooltips,
/// zoom, or touch handling — per project scope.
class MetricChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;

  const MetricChart({
    super.key,
    required this.values,
    required this.color,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text('Waiting for data...',
              style: Theme.of(context).textTheme.bodySmall),
        ),
      );
    }

    final spots = <FlSpot>[
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              color: color,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.10),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
