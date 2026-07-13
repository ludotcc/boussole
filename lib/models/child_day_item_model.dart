import 'family_event_model.dart';
import 'moment_model.dart';

enum ChildDayItemType { moment, event }

class ChildDayItemModel {
  final String id;
  final ChildDayItemType itemType;
  final String title;
  final String iconKey;
  final String? colorKey;
  final int? orderMinutes;
  final bool isSensitive;
  final String childTimeDisplayType;
  final int? timerMinutes;
  final int? maxDurationMinutes;
  final String? endTime;
  final MomentModel? moment;
  final FamilyEventModel? event;

  const ChildDayItemModel({
    required this.id,
    required this.itemType,
    required this.title,
    required this.iconKey,
    this.colorKey,
    required this.orderMinutes,
    required this.isSensitive,
    this.childTimeDisplayType = 'none',
    this.timerMinutes,
    this.maxDurationMinutes,
    this.endTime,
    this.moment,
    this.event,
  });

  bool get isMoment => itemType == ChildDayItemType.moment;

  bool get isEvent => itemType == ChildDayItemType.event;
}
