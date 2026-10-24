import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_assets.dart';

class MiningCircle extends StatefulWidget {
  final int points;
  final double orbs;
  final double orbsPerHour;
  final bool mining;
  final VoidCallback onMine;
  const MiningCircle({super.key, required this.points, required this.orbs, required this.orbsPerHour, required this.mining, required this.onMine});

  @override
  State<MiningCircle> createState() => _MiningCircleState();
}

class _MiningCircleState extends State<MiningCircle> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  @override void dispose(){c.dispose(); super.dispose();}

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: widget.onMine,
        child: AnimatedBuilder(
          animation: c,
          builder: (_, __) => Container(
            width: 310, height: 310,
            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(.45), blurRadius: 38)]),
            child: CustomPaint(
              painter: _RingPainter(c.value),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(AppAssets.logo, width: 70, height: 70, errorBuilder: (_,__,___)=>const Icon(Icons.hexagon, color: AppColors.white, size: 62)),
                const SizedBox(height: 8),
                const Text('ORBS', style: TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.w900, letterSpacing: 2)),
                Text(widget.mining ? 'MINING...' : 'READY', style: const TextStyle(color: AppColors.purple, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text(widget.orbs.toStringAsFixed(4), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900)),
                const Text('ORBS', style: TextStyle(color: AppColors.purple, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('${widget.orbsPerHour.toStringAsFixed(2)} ORBS / hour  ?', style: const TextStyle(color: AppColors.muted, fontSize: 14)),
              ]),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: 340, height: 64,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepPurple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: widget.onMine,
          icon: const Icon(Icons.flash_on),
          label: Text(widget.mining ? '채굴 중...' : '채굴 시작', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
        ),
      )
    ]);
  }
}

class _RingPainter extends CustomPainter {
  final double t; _RingPainter(this.t);
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width/2, size.height/2); final r = size.width/2 - 12;
    final bg = Paint()..color=AppColors.line..style=PaintingStyle.stroke..strokeWidth=7;
    final fg = Paint()..shader=SweepGradient(colors:[AppColors.purple, Colors.white, AppColors.purple], transform: GradientRotation(t*math.pi*2)).createShader(Rect.fromCircle(center:center, radius:r))..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeWidth=8;
    canvas.drawCircle(center, r, bg);
    canvas.drawArc(Rect.fromCircle(center:center, radius:r), -math.pi*.8, math.pi*1.6, false, fg);
  }
  @override bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.t != t;
}
