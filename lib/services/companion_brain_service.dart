import '../core/constants/companion_moments_catalog.dart';
import '../models/companion_context.dart';
import '../models/companion_memory.dart';
import '../models/companion_moment.dart';
import '../models/companion_suggestion_result.dart';

class CompanionBrainService {
  const CompanionBrainService({this.catalog});

  final List<CompanionMoment>? catalog;
  List<CompanionMoment> get _moments => catalog ?? companionMomentsCatalog;

  CompanionSuggestionResult selectIdeas(CompanionContext context) {
    var candidates =
        _moments
            .where((moment) => _isCompatible(moment, context))
            .map((moment) => _RankedMoment(moment, _score(moment, context)))
            .toList()
          ..sort((a, b) {
            final score = b.score.compareTo(a.score);
            return score != 0 ? score : a.moment.id.compareTo(b.moment.id);
          });

    if (candidates.isEmpty) {
      candidates =
          _moments
              .where((moment) => _isGenericFallbackCompatible(moment, context))
              .map((moment) => _RankedMoment(moment, _score(moment, context)))
              .toList()
            ..sort((a, b) => a.moment.id.compareTo(b.moment.id));
    }

    final recentIds = context.recentMomentIds.toSet();
    final fresh = candidates.where(
      (candidate) => !recentIds.contains(candidate.moment.id),
    );
    final recycled = candidates.where(
      (candidate) => recentIds.contains(candidate.moment.id),
    );
    final selected = _selectVaried([...fresh, ...recycled]);
    _avoidPreviousGroup(selected, candidates, context.previousGroupIds);

    return CompanionSuggestionResult(ideas: selected);
  }

  List<CompanionMoment> _selectVaried(List<_RankedMoment> candidates) {
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
    return selected;
  }

  void _avoidPreviousGroup(
    List<CompanionMoment> selected,
    List<_RankedMoment> candidates,
    List<String> previousGroupIds,
  ) {
    if (selected.isEmpty ||
        !_sameIds(selected.map((idea) => idea.id), previousGroupIds)) {
      return;
    }
    final selectedIds = selected.map((idea) => idea.id).toSet();
    for (final candidate in candidates) {
      if (!selectedIds.contains(candidate.moment.id)) {
        selected[selected.length - 1] = candidate.moment;
        return;
      }
    }
    if (selected.length > 1) {
      selected.removeLast();
    }
  }

  bool _sameIds(Iterable<String> selected, List<String> previous) {
    final values = selected.toList();
    return values.length == previous.length &&
        values.asMap().entries.every(
          (entry) => entry.value == previous[entry.key],
        );
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
    if (!_matchesNeed(moment.primaryNeed, context.primaryNeed)) return false;
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

  bool _matchesNeed(CompanionNeed momentNeed, CompanionNeed requestedNeed) {
    if (requestedNeed != CompanionNeed.findIdea) {
      return momentNeed == requestedNeed;
    }
    return momentNeed != CompanionNeed.calmDown &&
        momentNeed != CompanionNeed.rest &&
        momentNeed != CompanionNeed.celebrate;
  }

  bool _isGenericFallbackCompatible(
    CompanionMoment moment,
    CompanionContext context,
  ) {
    if (!moment.tags.contains('generic-safe') ||
        !moment.active ||
        !moment.isSafe) {
      return false;
    }
    if (context.child.age < moment.minimumAge ||
        context.child.age > moment.maximumAge ||
        moment.durationMinutes > context.availableDurationMinutes ||
        !context.availableParticipants.contains(moment.participants) ||
        !context.availableMaterials.containsAll(moment.requiredMaterials)) {
      return false;
    }
    return moment.compatibleContexts.isEmpty ||
        _intersects(moment.compatibleContexts, context.availableContexts);
  }

  int _score(CompanionMoment moment, CompanionContext context) {
    final profile = context.child.companionProfile;
    var score = 0;
    if (moment.primaryNeed == context.primaryNeed) score += 4;
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
