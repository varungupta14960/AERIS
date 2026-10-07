import 'dart:async';
import 'package:flutter/material.dart';
import 'models/models.dart';
import 'screens/about_screen.dart';
import 'screens/airband_screen.dart';
import 'screens/airhub_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/exposure_screen.dart';
import 'screens/profile_screen.dart';
import 'services/air_quality_service.dart';
import 'services/airhub_service.dart';
import 'services/exposure_estimation_service.dart';
import 'services/exposure_tracker.dart';
import 'services/health_profile_service.dart';
import 'services/sensor_data_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AerisApp());
}

class AerisApp extends StatelessWidget {
  const AerisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AERIS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const RootShell(),
    );
  }
}

/// Root navigation shell. Uses bottom navigation on narrow (mobile)
/// screens and a NavigationRail with an AERIS wordmark on wide
/// (desktop/web) screens. Also owns the handful of things every screen
/// needs to agree on: the demo environment scenario, the latest outdoor
/// AQI reading, and cumulative session exposure tracking.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  EnvironmentScenario _scenario = EnvironmentScenario.good;
  AirQualityData? _outdoor;

  // Services are created once and shared across screens.
  final _sensorService = MockSensorDataService();
  final _airQualityService = MockAirQualityService();
  final _airHubService = MockAirHubService();
  final _healthProfileService = HealthProfileService();
  final _exposureTracker = ExposureTracker();

  Timer? _outdoorTimer;
  StreamSubscription<SensorReading>? _exposureSub;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.timeline_outlined), selectedIcon: Icon(Icons.timeline), label: 'Exposure'),
    NavigationDestination(icon: Icon(Icons.sensors_outlined), selectedIcon: Icon(Icons.sensors), label: 'AirBand'),
    NavigationDestination(icon: Icon(Icons.air_outlined), selectedIcon: Icon(Icons.air), label: 'AirHub'),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'About'),
  ];

  @override
  void initState() {
    super.initState();
    _refreshOutdoor();
    _outdoorTimer = Timer.periodic(const Duration(seconds: 6), (_) => _refreshOutdoor());
    _exposureSub = _sensorService.readings.listen(_onReading);
  }

  Future<void> _refreshOutdoor() async {
    final result = await _airQualityService.getCurrent();
    if (mounted) setState(() => _outdoor = result);
  }

  void _onReading(SensorReading reading) {
    final outdoor = _outdoor;
    if (outdoor == null) return;
    final profile = _healthProfileService.profile.value;
    final estimate = ExposureEstimationService.estimate(ExposureInput(
      age: profile.age,
      respiratoryCondition: profile.respiratoryCondition,
      allergyLevel: profile.allergyLevel,
      activityLevel: profile.activityLevel,
      outdoorExposure: profile.outdoorExposure,
      pm25: reading.pm25,
      pm10: reading.pm10,
      aqi: outdoor.aqi,
      temperature: reading.temperature,
      humidity: reading.humidity,
      airHubActive: _airHubService.status.value.fanOn,
    ));
    _exposureTracker.record(estimate.riskLevel);
  }

  void _setScenario(EnvironmentScenario scenario) {
    setState(() => _scenario = scenario);
    _sensorService.setScenario(scenario);
    _airQualityService.setScenario(scenario);
    _refreshOutdoor();
  }

  void _goToExposure() => setState(() => _index = 1);

  @override
  void dispose() {
    _outdoorTimer?.cancel();
    _exposureSub?.cancel();
    _sensorService.dispose();
    _airHubService.dispose();
    _healthProfileService.dispose();
    _exposureTracker.dispose();
    super.dispose();
  }

  Widget _screenFor(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(
          sensorService: _sensorService,
          airHubService: _airHubService,
          healthProfileService: _healthProfileService,
          outdoor: _outdoor,
          scenario: _scenario,
          onScenarioChanged: _setScenario,
          onViewExposure: _goToExposure,
        );
      case 1:
        return ExposureScreen(
          sensorService: _sensorService,
          airHubService: _airHubService,
          healthProfileService: _healthProfileService,
          exposureTracker: _exposureTracker,
          outdoor: _outdoor,
        );
      case 2:
        return AirBandScreen(sensorService: _sensorService);
      case 3:
        return AirHubScreen(
          airHubService: _airHubService,
          sensorService: _sensorService,
          healthProfileService: _healthProfileService,
          outdoor: _outdoor,
        );
      case 4:
        return ProfileScreen(healthProfileService: _healthProfileService);
      default:
        return const AboutScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 800;
      final scheme = Theme.of(context).colorScheme;

      if (isWide) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                labelType: NavigationRailLabelType.all,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(Icons.eco_outlined, color: scheme.primary, size: 22),
                      const SizedBox(height: 4),
                      Text('AERIS',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.8,
                            color: scheme.primary,
                          )),
                    ],
                  ),
                ),
                destinations: _destinations
                    .map((d) => NavigationRailDestination(icon: d.icon, selectedIcon: d.selectedIcon, label: Text(d.label)))
                    .toList(),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: _screenFor(_index)),
            ],
          ),
        );
      }

      return Scaffold(
        body: _screenFor(_index),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: _destinations,
        ),
      );
    });
  }
}
