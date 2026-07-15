import '../core/constants/companion_moments_catalog.dart';
import '../models/companion_context.dart';
import '../models/companion_memory.dart';
import '../models/companion_moment.dart';
import '../models/companion_suggestion_result.dart';

class CompanionBrainService {
  const CompanionBrainService({this.catalog = companionMomentsCatalog});

  final List<CompanionMoment> catalog;

  CompanionSuggestionResult selectIdeas(CompanionContext context) {
    final candidates =
        catalog
            .where((moment) => _isCompatible(moment, context))
            .map((moment) => _RankedMoment(moment, _score(moment, context)))
            .toList()
          ..sort((a, b) {
            final score = b.score.compareTo(a.score);
            return score != 0 ? score : a.moment.id.compareTo(b.moment.id);
          });

    final selected = <CompanionMoment>[];
    final selectedFamilies = <CompanionMomentFamily>{};
    for (final candidate in candidates) {
      if (selected.length == 3) break;
      if (selectedFamilies.add(candidate.moment.family)) {
        selected.add(candidate.moment);
      }
    }
    if (selected.length < 3) {
      for (final candidate in candidates) {
        if (selected.length == 3) break;
        if (!selected.contains(candidate.moment)) {
          selected.add(candidate.moment);
        }
      }
    }

    return CompanionSuggestionResult(ideas: selected);
  }

  bool _isCompatible(CompanionMoment moment, CompanionContext context) {
    if (!moment.active || !moment.isSafe) return false;
    if (moment.compatibleContexts.isNotEmpty &&
        !_intersects(moment.compatibleContexts, context.availableContexts)) {
      return false;
    }
    if (moment.compatibleMainMoments.isNotEmpty &&
        !moment.compatibleMainMoments.contains(context.mainMoment)) {
      return false;
    }
    if (moment.primaryNeed != context.primaryNeed) return false;
    if (context.child.age < moment.minimumAge ||
        context.child.age > moment.maximumAge) {
      return false;
    }
    if (moment.durationMinutes > context.availableDurationMinutes) return false;
    if (!context.availableParticipants.contains(moment.participants)) {
      return false;
    }
    if (!context.availableMaterials.containsAll(moment.requiredMaterials)) {
      return false;
    }
    final profile = context.child.companionProfile;
    if (_intersects(
      moment.incompatibleAvoidedActivities,
      profile.activitiesToAvoid.toSet(),
    )) {
      return false;
    }
    if (_intersects(
      moment.incompatibleSensitiveSituations,
      profile.sensitiveSituations.toSet(),
    )) {
      return false;
    }
    return true;
  }

  int _score(CompanionMoment moment, CompanionContext context) {
    final profile = context.child.companionProfile;
    var score = 0;
    score += _matches(moment.compatibleInterests, profile.interests) * 8;
    score += _matches(moment.tags, profile.likedActivities) * 10;
    score += _matches(moment.compatibleParentGoals, profile.parentGoals) * 6;
    for (final memory in context.validatedMemories.where(
      (memory) => memory.status == CompanionMemoryStatus.validated,
    )) {
      if (_matchesMemory(moment, memory)) {
        score += 12 + memory.priority + (memory.reliability * 10).round();
      }
    }
    final recentIndex = context.recentMomentIds.indexOf(moment.id);
    if (recentIndex >= 0) score -= 30 - recentIndex.clamp(0, 20);
    return score;
  }

  bool _matchesMemory(CompanionMoment moment, CompanionMemory memory) {
    final value = _normalize(memory.value);
    return moment.tags.any((tag) => value.contains(_normalize(tag))) ||
        moment.compatibleInterests.any(
          (interest) => value.contains(_normalize(interest)),
        );
  }

  int _matches(Set<String> values, List<String> expected) {
    final normalized = values.map(_normalize).toSet();
    return expected.map(_normalize).where(normalized.contains).length;
  }

  bool _intersects(Set<String> first, Set<String> second) {
    final normalizedSecond = second.map(_normalize).toSet();
    return first.map(_normalize).any(normalizedSecond.contains);
  }

  String _normalize(String value) => value.trim().toLowerCase();
}

class _RankedMoment {
  const _RankedMoment(this.moment, this.score);

  final CompanionMoment moment;
  final int score;
}
