import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Holds the user's health profile for the current demo session only.
/// No backend, no persistence — values reset when the app restarts.
/// Consumed by [ExposureEstimationService] to personalize the prototype
/// exposure estimate shown on the Dashboard.
class HealthProfileService {
  final ValueNotifier<HealthProfile> profile = ValueNotifier(const HealthProfile());

  void update(HealthProfile updated) {
    profile.value = updated;
  }

  void dispose() {
    profile.dispose();
  }
}
