import '../models/child_model.dart';
import '../models/planning_day_kind.dart';
import '../services/academy_service.dart';
import '../services/school_holiday_service.dart';

class PlanningDayResolver {
  PlanningDayResolver({
    AcademyService? academyService,
    SchoolHolidayService? schoolHolidayService,
  }) : _academyService = academyService ?? AcademyService(),
       _schoolHolidayService = schoolHolidayService ?? SchoolHolidayService();

  final AcademyService _academyService;
  final SchoolHolidayService _schoolHolidayService;

  Future<PlanningDayKind> resolve({
    required DateTime date,
    ChildModel? child,
  }) async {
    final academyId = await _academyService.normalizeAcademyId(
      child?.academyId ?? '',
    );
    final holiday = await _schoolHolidayService.holidayFor(
      date: date,
      academyId: academyId,
    );

    if (holiday.isHoliday) {
      return PlanningDayKind.vacation;
    }

    final rhythm = child?.weeklyRhythmByWeekday[date.weekday];

    if (rhythm != null) {
      return PlanningDayKind.fromValue(rhythm);
    }

    return switch (date.weekday) {
      DateTime.monday ||
      DateTime.tuesday ||
      DateTime.thursday ||
      DateTime.friday => PlanningDayKind.school,
      DateTime.wednesday => PlanningDayKind.wednesday,
      _ => PlanningDayKind.weekend,
    };
  }
}
