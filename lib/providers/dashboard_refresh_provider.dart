import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'child_day_progress_provider.dart';
import 'children_provider.dart';
import 'family_events_provider.dart';
import 'family_members_provider.dart';
import 'family_provider.dart';
import 'moments_provider.dart';

class DashboardRefreshNotifier extends StateNotifier<bool> {
  DashboardRefreshNotifier(this.ref) : super(false);

  final Ref ref;

  Future<void> refresh() async {
    if (state) {
      return;
    }

    state = true;

    ref.invalidate(currentFamilyProvider);
    ref.invalidate(adultProfilesProvider);
    ref.invalidate(familyMembersProvider);
    ref.invalidate(familyChildMembersProvider);
    ref.invalidate(childrenProvider);
    ref.invalidate(selectedPlanningMomentsProvider);
    ref.invalidate(childDayItemsProvider);
    ref.invalidate(childDayProgressProvider);
    ref.invalidate(familyEventsProvider);
    ref.invalidate(upcomingFamilyEventsProvider);

    await Future<void>.delayed(const Duration(milliseconds: 250));

    state = false;
  }
}

final dashboardRefreshProvider =
    StateNotifierProvider<DashboardRefreshNotifier, bool>(
      (ref) => DashboardRefreshNotifier(ref),
    );
