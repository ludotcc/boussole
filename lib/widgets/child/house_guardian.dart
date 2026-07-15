import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/guardian_model.dart';
import '../../models/guardian_experience_state.dart';

class HouseGuardian extends StatefulWidget {
  const HouseGuardian({
    super.key,
    required this.guardian,
    required this.pose,
    required this.onTap,
  });

  final GuardianModel guardian;
  final GuardianPose pose;
  final VoidCallback onTap;

  static const _widthFactor = .84;
  static const _minimumCanvasWidth = 180.0;
  static const _maximumCanvasWidth = 640.0;
  static const _assetAspectRatio = 3 / 2;

  @override
  State<HouseGuardian> createState() => _HouseGuardianState();
}

class _HouseGuardianState extends State<HouseGuardian> {
  GuardianId? _preloadedGuardianId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadActiveGuardian();
  }

  @override
  void didUpdateWidget(covariant HouseGuardian oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guardian.id != widget.guardian.id) {
      _preloadActiveGuardian();
    }
  }

  void _preloadActiveGuardian() {
    if (_preloadedGuardianId == widget.guardian.id) return;
    _preloadedGuardianId = widget.guardian.id;
    for (final asset in widget.guardian.poseAssets) {
      unawaited(
        precacheImage(AssetImage(asset), context).catchError((Object _) {}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsiveWidth =
            (constraints.maxWidth * HouseGuardian._widthFactor)
                .clamp(
                  HouseGuardian._minimumCanvasWidth,
                  HouseGuardian._maximumCanvasWidth,
                )
                .toDouble();
        final canvasWidth = math.min(responsiveWidth, constraints.maxWidth);
        final canvasHeight = math.min(
          canvasWidth / HouseGuardian._assetAspectRatio,
          constraints.maxHeight,
        );

        return Transform.translate(
          offset: const Offset(0, -56),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: canvasWidth,
              height: canvasHeight,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    left: canvasWidth * .08,
                    right: canvasWidth * .08,
                    bottom: canvasHeight * .02,
                    height: canvasHeight * .72,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: .3),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    image: true,
                    button: true,
                    label:
                        '${widget.guardian.name}, ton Gardien. Appuie pour lui parler.',
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: widget.onTap,
                      child: Image.asset(
                        widget.guardian.assetForPose(widget.pose),
                        width: canvasWidth,
                        height: canvasHeight,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        filterQuality: FilterQuality.high,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) {
                          final failedAsset = widget.guardian.assetForPose(
                            widget.pose,
                          );
                          if (failedAsset == widget.guardian.idleAsset) {
                            return const Icon(
                              Icons.sentiment_satisfied_alt_rounded,
                              size: 72,
                              color: Color(0xFF607D8B),
                            );
                          }
                          return Image.asset(
                            widget.guardian.idleAsset,
                            width: canvasWidth,
                            height: canvasHeight,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
