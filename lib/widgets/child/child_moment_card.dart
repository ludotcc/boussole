import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/child_day_progress_provider.dart';

class ChildMomentCard extends StatelessWidget {
  const ChildMomentCard({
    super.key,
    required this.title,
    this.image,
    this.icon,
    required this.color,
    required this.status,
    required this.onStart,
    required this.onComplete,
    this.todoLabel,
    this.inProgressLabel,
    this.childTimeDisplayType = 'none',
    this.timerMinutes,
    this.maxDurationMinutes,
    this.endTime,
    this.startedAt,
    this.remainingUses,
    this.onTap,
    this.onImageTap,
    this.readOnly = false,
    this.isSensitive = false,
    this.compact = false,
  });

  final String title;
  final String? image;
  final IconData? icon;
  final Color color;
  final ChildMomentStatus status;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final String? todoLabel;
  final String? inProgressLabel;
  final String childTimeDisplayType;
  final int? timerMinutes;
  final int? maxDurationMinutes;
  final String? endTime;
  final DateTime? startedAt;
  final int? remainingUses;
  final VoidCallback? onTap;
  final VoidCallback? onImageTap;
  final bool readOnly;
  final bool isSensitive;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isCurrent = status == ChildMomentStatus.inProgress;
    final isDone = status == ChildMomentStatus.done;
    final isMultiUse = remainingUses != null;
    final isUseLimitReached = isMultiUse && remainingUses == 0 && !isCurrent;
    final cardRadius = compact ? 24.0 : 32.0;
    final visualSize = compact ? 64.0 : 96.0;
    final visualRadius = compact ? 20.0 : 28.0;

    return TweenAnimationBuilder<double>(
      key: ValueKey(status),
      tween: Tween(begin: isDone ? .96 : 1, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        final sensitiveScale = isSensitive && isCurrent ? .985 : 1.0;

        return Transform.scale(scale: scale * sensitiveScale, child: child);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: isSensitive ? 420 : 260),
        curve: isSensitive ? Curves.easeInOut : Curves.easeOut,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .82),
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: isCurrent
                ? isSensitive
                      ? const Color(0xFFC8B8FF)
                      : const Color(0xFF9EC9FF)
                : isDone
                ? const Color(0xFFA9DEC2)
                : isMultiUse
                ? const Color(0xFFFFD59E)
                : const Color(0xFFE8DDFD),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSensitive ? AppColors.violet : AppColors.violet)
                  .withValues(alpha: isSensitive ? .14 : .10),
              blurRadius: isSensitive ? 28 : 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: readOnly || isDone || isUseLimitReached ? null : onTap,
                borderRadius: BorderRadius.circular(cardRadius),
                child: Padding(
                  padding: EdgeInsets.all(compact ? 12 : 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _MomentVisual(
                            image: image,
                            icon: icon,
                            color: isDone ? AppColors.success : color,
                            size: visualSize,
                            radius: visualRadius,
                            onTap: onImageTap,
                          ),
                          SizedBox(width: compact ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: compact ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.cardTitle,
                                ),
                                SizedBox(height: compact ? 7 : 10),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: _StatusPill(
                                    key: ValueKey(status),
                                    status: status,
                                    todoLabel: todoLabel,
                                    inProgressLabel: inProgressLabel,
                                  ),
                                ),
                                if (isMultiUse) ...[
                                  const SizedBox(height: 8),
                                  _MultiUseCue(remainingUses: remainingUses!),
                                ],
                              ],
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: isDone
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    key: ValueKey('done-icon'),
                                    color: AppColors.success,
                                    size: 30,
                                  )
                                : const SizedBox(
                                    key: ValueKey('empty-icon'),
                                    width: 0,
                                  ),
                          ),
                        ],
                      ),
                      if (!readOnly) ...[
                        if (isCurrent &&
                            childTimeDisplayType != 'none' &&
                            startedAt != null &&
                            (timerMinutes != null ||
                                maxDurationMinutes != null)) ...[
                          SizedBox(height: compact ? 10 : 16),
                          _GentleTimeCue(
                            displayType: childTimeDisplayType,
                            timerMinutes: timerMinutes,
                            maxDurationMinutes: maxDurationMinutes,
                            startedAt: startedAt!,
                          ),
                        ],
                        if (isUseLimitReached) ...[
                          SizedBox(height: compact ? 10 : 16),
                          const _UseLimitMessage(),
                        ],
                        SizedBox(height: compact ? 12 : 18),
                        SizedBox(
                          width: double.infinity,
                          height: compact ? 46 : 52,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: DecoratedBox(
                              key: ValueKey(status),
                              decoration: BoxDecoration(
                                gradient: isDone
                                    ? null
                                    : LinearGradient(
                                        colors: isSensitive
                                            ? [
                                                Color(0xFFBBA7FF),
                                                Color(0xFFAECFFF),
                                              ]
                                            : [
                                                Color(0xFF6EA8FF),
                                                Color(0xFF8EC5FF),
                                              ],
                                      ),
                                color: isDone ? AppColors.cardSecondary : null,
                                borderRadius: BorderRadius.circular(
                                  compact ? 18 : 22,
                                ),
                              ),
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      compact ? 18 : 22,
                                    ),
                                  ),
                                ),
                                onPressed: isDone || isUseLimitReached
                                    ? null
                                    : (isCurrent ? onComplete : onStart),
                                icon: Icon(
                                  isDone
                                      ? Icons.check_circle_rounded
                                      : isCurrent
                                      ? Icons.done_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                                label: Text(
                                  isDone
                                      ? 'Termine'
                                      : isUseLimitReached
                                      ? 'Pour aujourd hui'
                                      : isCurrent
                                      ? 'J ai fini'
                                      : 'Commencer',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (onImageTap != null)
              const Positioned(
                top: 7,
                left: 7,
                child: IgnorePointer(child: _GuidanceBubble()),
              ),
          ],
        ),
      ),
    );
  }
}

class _GuidanceBubble extends StatelessWidget {
  const _GuidanceBubble();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F8FF),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.chat_bubble_rounded,
          color: AppColors.primary,
          size: 14,
        ),
      ),
    );
  }
}

class _MomentVisual extends StatefulWidget {
  const _MomentVisual({
    required this.image,
    required this.icon,
    required this.color,
    required this.size,
    required this.radius,
    required this.onTap,
  });

  final String? image;
  final IconData? icon;
  final Color color;
  final double size;
  final double radius;
  final VoidCallback? onTap;

  @override
  State<_MomentVisual> createState() => _MomentVisualState();
}

class _MomentVisualState extends State<_MomentVisual>
    with TickerProviderStateMixin {
  AnimationController? _haloController;

  bool get _hasGuidance => widget.onTap != null;

  @override
  void initState() {
    super.initState();
    _updateHaloAnimation();
  }

  @override
  void didUpdateWidget(covariant _MomentVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.onTap != null) != _hasGuidance) {
      _updateHaloAnimation();
    }
  }

  void _updateHaloAnimation() {
    if (_hasGuidance) {
      _haloController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2700),
      )..repeat(reverse: true);
    } else {
      _haloController?.dispose();
      _haloController = null;
    }
  }

  @override
  void dispose() {
    _haloController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visual = SizedBox.square(
      dimension: widget.size,
      child: Padding(
        padding: EdgeInsets.all(widget.size <= 64 ? 2 : 3),
        child: widget.image == null
            ? Icon(
                widget.icon ?? Icons.auto_awesome_rounded,
                color: widget.color,
                size: widget.size <= 64 ? 32 : 42,
              )
            : Image.asset(widget.image!, fit: BoxFit.contain),
      ),
    );

    final controller = _haloController;
    final decoratedVisual = controller == null
        ? visual
        : AnimatedBuilder(
            animation: controller,
            child: visual,
            builder: (context, child) {
              final intensity = Curves.easeInOut.transform(controller.value);

              return RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.radius),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: .12 + (.12 * intensity),
                        ),
                        blurRadius: 18 + (8 * intensity),
                        spreadRadius: 1 + (2 * intensity),
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
          );

    return Semantics(
      excludeSemantics: true,
      button: _hasGuidance,
      label: _hasGuidance
          ? 'Illustration avec un conseil à découvrir'
          : 'Illustration du moment',
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(widget.radius),
        child: decoratedVisual,
      ),
    );
  }
}

class _MultiUseCue extends StatelessWidget {
  const _MultiUseCue({required this.remainingUses});

  final int remainingUses;

  @override
  Widget build(BuildContext context) {
    final label = remainingUses <= 0
        ? 'Plus de lancement aujourd hui'
        : remainingUses == 1
        ? 'Encore 1 fois aujourd hui'
        : 'Encore $remainingUses fois aujourd hui';

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFDFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.repeat_rounded, color: Color(0xFF4D96FF), size: 17),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UseLimitMessage extends StatelessWidget {
  const _UseLimitMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD59E)),
      ),
      child: Text(
        'Ce moment a deja ete utilise aujourd hui.',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyles.small.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    super.key,
    required this.status,
    this.todoLabel,
    this.inProgressLabel,
  });

  final ChildMomentStatus status;
  final String? todoLabel;
  final String? inProgressLabel;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      ChildMomentStatus.todo => todoLabel ?? 'Tu peux faire',
      ChildMomentStatus.inProgress => inProgressLabel ?? 'En cours',
      ChildMomentStatus.done => 'Termine',
    };
    final color = switch (status) {
      ChildMomentStatus.todo => const Color(0xFF8A7FA3),
      ChildMomentStatus.inProgress => const Color(0xFF6EA8FF),
      ChildMomentStatus.done => AppColors.success,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GentleTimeCue extends StatefulWidget {
  const _GentleTimeCue({
    required this.displayType,
    required this.timerMinutes,
    required this.maxDurationMinutes,
    required this.startedAt,
  });

  final String displayType;
  final int? timerMinutes;
  final int? maxDurationMinutes;
  final DateTime startedAt;

  @override
  State<_GentleTimeCue> createState() => _GentleTimeCueState();
}

class _GentleTimeCueState extends State<_GentleTimeCue> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = switch (widget.displayType) {
      'timer' => widget.timerMinutes,
      'maxDuration' => widget.maxDurationMinutes,
      _ => null,
    };

    if (minutes == null || minutes <= 0) {
      return const SizedBox.shrink();
    }

    final totalSeconds = minutes * 60;
    final elapsedSeconds = _now.difference(widget.startedAt).inSeconds;
    final progress = (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
    final visualProgress = progress <= 0 ? .05 : progress.clamp(.05, 1.0);
    final isComplete = progress >= 1;

    if (widget.displayType == 'maxDuration') {
      return _MaxDurationCue(
        endTime: _formatEndTime(widget.startedAt, minutes),
        isComplete: isComplete,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8CBFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .75),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: AppColors.violet,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'On avance tranquillement',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isComplete
                      ? 'Tu peux terminer ce moment.'
                      : 'Encore un petit moment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 9,
                    color: Colors.white.withValues(alpha: .74),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: visualProgress),
                      duration: const Duration(milliseconds: 850),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: value,
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF7CC7FF),
                              Color(0xFFFFC27A),
                              Color(0xFFFF8C8C),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaxDurationCue extends StatelessWidget {
  const _MaxDurationCue({required this.endTime, required this.isComplete});

  final String endTime;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8CBFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu as jusqu\'à : $endTime',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (isComplete) ...[
            const SizedBox(height: 3),
            Text(
              'Tu peux terminer ce moment.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatEndTime(DateTime startedAt, int minutes) {
  final endTime = startedAt.add(Duration(minutes: minutes));
  final hour = endTime.hour.toString().padLeft(2, '0');
  final minute = endTime.minute.toString().padLeft(2, '0');

  return '${hour}h$minute';
}
