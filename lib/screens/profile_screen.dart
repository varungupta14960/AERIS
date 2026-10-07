import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/health_profile_service.dart';
import '../theme/app_theme.dart';

/// Health Profile page. Local-only inputs used to personalize the
/// prototype exposure estimate shown on the Dashboard and Exposure
/// screens. Not a medical record, no backend, no persistence beyond
/// this demo session.
class ProfileScreen extends StatefulWidget {
  final HealthProfileService healthProfileService;
  const ProfileScreen({super.key, required this.healthProfileService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  late String _sex;
  late RespiratoryCondition _respiratoryCondition;
  late AllergyLevel _allergyLevel;
  late ActivityLevel _activityLevel;
  late OutdoorExposureLevel _outdoorExposure;

  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final p = widget.healthProfileService.profile.value;
    _nameController = TextEditingController(text: p.name);
    _ageController = TextEditingController(text: p.age?.toString() ?? '');
    _heightController = TextEditingController(text: p.heightCm?.toString() ?? '');
    _weightController = TextEditingController(text: p.weightKg?.toString() ?? '');
    _sex = p.sex;
    _respiratoryCondition = p.respiratoryCondition;
    _allergyLevel = p.allergyLevel;
    _activityLevel = p.activityLevel;
    _outdoorExposure = p.outdoorExposure;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String get _initial {
    final name = _nameController.text.trim();
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  void _save() {
    final profile = HealthProfile(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      sex: _sex,
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      respiratoryCondition: _respiratoryCondition,
      allergyLevel: _allergyLevel,
      activityLevel: _activityLevel,
      outdoorExposure: _outdoorExposure,
    );
    widget.healthProfileService.update(profile);
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Health profile saved for this session.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Health Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(initial: _initial, name: _nameController.text),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Personal information', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 14),
                        _TextField(label: 'Name', controller: _nameController, onChanged: () => setState(() {})),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _TextField(
                                label: 'Age',
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _sex,
                                decoration: const InputDecoration(labelText: 'Sex'),
                                items: const ['Female', 'Male', 'Other', 'Prefer not to say']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (v) => setState(() => _sex = v ?? _sex),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Body information', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _TextField(
                                label: 'Height (cm)',
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TextField(
                                label: 'Weight (kg)',
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Health information', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 14),
                        Text('Respiratory condition', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        SegmentedButton<RespiratoryCondition>(
                          segments: const [
                            ButtonSegment(value: RespiratoryCondition.none, label: Text('None')),
                            ButtonSegment(value: RespiratoryCondition.asthma, label: Text('Asthma')),
                            ButtonSegment(value: RespiratoryCondition.copd, label: Text('COPD')),
                            ButtonSegment(value: RespiratoryCondition.other, label: Text('Other')),
                          ],
                          selected: {_respiratoryCondition},
                          onSelectionChanged: (s) => setState(() => _respiratoryCondition = s.first),
                        ),
                        const SizedBox(height: 16),
                        Text('Allergies', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        SegmentedButton<AllergyLevel>(
                          segments: const [
                            ButtonSegment(value: AllergyLevel.none, label: Text('None')),
                            ButtonSegment(value: AllergyLevel.mild, label: Text('Mild')),
                            ButtonSegment(value: AllergyLevel.moderate, label: Text('Moderate')),
                            ButtonSegment(value: AllergyLevel.severe, label: Text('Severe')),
                          ],
                          selected: {_allergyLevel},
                          onSelectionChanged: (s) => setState(() => _allergyLevel = s.first),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Activity', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 14),
                        Text('Typical activity level', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        SegmentedButton<ActivityLevel>(
                          segments: const [
                            ButtonSegment(value: ActivityLevel.low, label: Text('Low')),
                            ButtonSegment(value: ActivityLevel.moderate, label: Text('Moderate')),
                            ButtonSegment(value: ActivityLevel.high, label: Text('High')),
                          ],
                          selected: {_activityLevel},
                          onSelectionChanged: (s) => setState(() => _activityLevel = s.first),
                        ),
                        const SizedBox(height: 16),
                        Text('Time spent outdoors', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        SegmentedButton<OutdoorExposureLevel>(
                          segments: const [
                            ButtonSegment(value: OutdoorExposureLevel.low, label: Text('Low')),
                            ButtonSegment(value: OutdoorExposureLevel.moderate, label: Text('Moderate')),
                            ButtonSegment(value: OutdoorExposureLevel.high, label: Text('High')),
                          ],
                          selected: {_outdoorExposure},
                          onSelectionChanged: (s) => setState(() => _outdoorExposure = s.first),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppTheme.radius - 2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Your profile is used to personalize AERIS's prototype exposure estimates. This "
                          'information is stored locally in this prototype and is used only for prototype '
                          'personalization — it is NOT a medical record or medical diagnosis.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(_saved ? Icons.check : Icons.save_outlined),
                    label: Text(_saved ? 'Saved for this session' : 'Save profile'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String initial;
  final String name;
  const _ProfileHeader({required this.initial, required this.name});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: scheme.primary.withOpacity(0.12),
          child: Text(
            initial,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: scheme.primary),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.trim().isEmpty ? 'My Health Profile' : name.trim(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22),
              ),
              Text('AERIS personalization',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final VoidCallback? onChanged;

  const _TextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => onChanged?.call(),
    );
  }
}
