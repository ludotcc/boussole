import 'companion_moment.dart';

class CompanionSuggestionResult {
  const CompanionSuggestionResult({
    required this.ideas,
    this.isMyDayAvailable = true,
  });

  final List<CompanionMoment> ideas;
  final bool isMyDayAvailable;
}
