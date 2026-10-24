import 'dart:math' as math;

import 'package:flutter/material.dart';

class MiningCircle extends StatelessWidget {
  final Animation<double> ringAnimation;
  final Animation<double> pulseAnimation;
  final bool isMining;
  final double orbs;
  final String timeText;
  final String logoAssetPath;

  const MiningCircle({
    super.key,
    required this.ringAnimation,
    required this.pulseAnimation,
    required this.isMining,
    required this.orbs,
    required this.timeText,
    this.logoAssetPath = 'assets/images/logo/orqube_plane_logo.png',
  });

  static const Color bg = Color(0xFF050510);
  static const Color purple = Color(0xFF8B2CF6);
  static const Color violet = Color(0xFFB85CFF);
  static const Color lime = Color(0xFFD7FF35);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ringAnimation, pulseAnimation]),
      builder: (context, child) {
        final pulse = 0.55 + pulseAnimation.value * 0.45;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: ringAnimation.value * math.pi * 2,
                child: Container(
                  width: 304,
                  height: 304,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        purple.withOpacity(0.00),
                        violet.withOpacity(0.75),
                        lime.withOpacity(0.90),
                        purple.withOpacity(0.00),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 286,
                height: 286,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bg,
                  border: Border.all(
                    color: isMining ? lime.withOpacity(pulse) : Colors.white12,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isMining ? lime : purple).withOpacity(0.34),
                      blurRadius: isMining ? 40 : 22,
                      spreadRadius: isMining ? 8 : 2,
                    ),
                  ],
                ),
              ),
              Container(
                width: 244,
                height: 244,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFF2B145A), Color(0xFF111126), bg],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: ringAnimation.value * math.pi * 2,
                      child: _RoundLogo(path: logoAssetPath, size: 68),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      orbs.toStringAsFixed(6),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ORBS',
                      style: TextStyle(
                        color: lime,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      timeText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isMining ? 'MINING ACTIVE' : 'READY TO MINE',
                      style: TextStyle(
                        color: isMining ? lime : Colors.white38,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoundLogo extends StatelessWidget {
  final String path;
  final double size;

  const _RoundLogo({required this.path, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: MiningCircle.lime, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x558B2CF6), blurRadius: 16, spreadRadius: 2),
        ],
      ),
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF8B2CF6),
                    Color(0xFF2E1065),
                    MiningCircle.bg,
                  ],
                ),
              ),
              child: Icon(
                Icons.flight_takeoff_rounded,
                color: Colors.white,
                size: size * 0.54,
              ),
            ),
      ),
    );
  }
}
