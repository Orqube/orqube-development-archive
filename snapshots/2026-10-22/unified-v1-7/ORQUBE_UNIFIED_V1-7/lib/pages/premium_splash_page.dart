import 'dart:math' as math;

import 'package:flutter/material.dart';

/// ORQUBE V14 Premium Splash Animation
///
/// 외부 이미지 파일 없이 Flutter 위젯만으로 동작합니다.
/// 약 2.8초 후 [nextPage]로 자동 이동합니다.
class PremiumSplashPage extends StatefulWidget {
  const PremiumSplashPage({
    super.key,
    required this.nextPage,
    this.duration = const Duration(milliseconds: 2800),
  });

  final Widget nextPage;
  final Duration duration;

  @override
  State<PremiumSplashPage> createState() => _PremiumSplashPageState();
}

class _PremiumSplashPageState extends State<PremiumSplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _rotationController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.58, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.48, curve: Curves.easeOutBack),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.32, 0.72, curve: Curves.easeOut),
      ),
    );
    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.20, 0.94, curve: Curves.easeInOut),
      ),
    );

    _mainController.forward();
    Future<void>.delayed(widget.duration, _openDashboard);
  }

  void _openDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, animation, __) => widget.nextPage,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.025, end: 1).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02030A),
      body: Stack(
        children: [
          const Positioned.fill(child: _SplashBackground()),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _mainController,
                    _rotationController,
                  ]),
                  builder: (context, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: SizedBox(
                              width: 210,
                              height: 210,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle:
                                        _rotationController.value * math.pi * 2,
                                    child: const _OrbitRing(size: 205),
                                  ),
                                  Transform.rotate(
                                    angle:
                                        -_rotationController.value *
                                        math.pi *
                                        1.35,
                                    child: const _OrbitRing(
                                      size: 174,
                                      thin: true,
                                    ),
                                  ),
                                  Container(
                                    width: 126,
                                    height: 126,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const RadialGradient(
                                        colors: [
                                          Color(0xFF8B2CF6),
                                          Color(0xFF35106E),
                                          Color(0xFF090B19),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFCB7BFF),
                                        width: 2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xAA8B2CF6),
                                          blurRadius: 38,
                                          spreadRadius: 7,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/logo/orqube_plane_logo.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.flight_rounded,
                                          size: 73,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Opacity(
                          opacity: _titleOpacity.value,
                          child: const Column(
                            children: [
                              Text(
                                'ORQUBE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3.2,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'AIRSOFT & WEB3 ECOSYSTEM',
                                style: TextStyle(
                                  color: Color(0xFFD7FF35),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              SizedBox(height: 7),
                              Text(
                                'V15 PREMIUM',
                                style: TextStyle(
                                  color: Color(0xFFB85CFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 42),
                        Opacity(
                          opacity: _titleOpacity.value,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: Container(
                                  width: 230,
                                  height: 5,
                                  color: Colors.white10,
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: _progress.value.clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF8B2CF6),
                                            Color(0xFFCB7BFF),
                                            Color(0xFFD7FF35),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xAA8B2CF6),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _progress.value < 0.95
                                    ? 'INITIALIZING ORQUBE SYSTEM...'
                                    : 'READY',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitRing extends StatelessWidget {
  const _OrbitRing({required this.size, this.thin = false});

  final double size;
  final bool thin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _OrbitRingPainter(thin: thin)),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  const _OrbitRingPainter({required this.thin});

  final bool thin;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 4;
    final base =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = thin ? 1.2 : 2
          ..color = const Color(0x447E40FF);
    canvas.drawCircle(center, radius, base);

    final glow =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = thin ? 2 : 4
          ..shader = const SweepGradient(
            colors: [
              Colors.transparent,
              Color(0xFFD7FF35),
              Color(0xFFB85CFF),
              Colors.transparent,
            ],
            stops: [0.0, 0.27, 0.58, 0.76],
          ).createShader(rect);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.9,
      thin ? 2.0 : 2.55,
      false,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) => false;
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.15),
          radius: 1.1,
          colors: [Color(0xFF32106A), Color(0xFF0B0C1C), Color(0xFF02030A)],
        ),
      ),
      child: CustomPaint(painter: _StarPainter()),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(1407);
    for (var i = 0; i < 130; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = 0.35 + random.nextDouble() * 1.15;
      final opacity = 0.18 + random.nextDouble() * 0.58;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
