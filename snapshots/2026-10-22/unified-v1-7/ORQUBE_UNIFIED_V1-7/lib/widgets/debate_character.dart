import 'package:flutter/material.dart';

/// Original vector characters, drawn locally without external image assets.
class DebateCharacter extends StatelessWidget {
  const DebateCharacter({super.key, required this.panel, required this.color,
    this.size = 48, this.active = false});
  final int panel;
  final Color color;
  final double size;
  final bool active;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '가상 인물 ${['털보', '따불', '신사', '진행자'][panel.clamp(0, 3).toInt()]}${active ? ", 발언 중" : ""}',
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle,
        border: Border.all(color: active ? Colors.white : color, width: active ? 3 : 1),
        boxShadow: active ? [BoxShadow(color: color.withOpacity(.5), blurRadius: 12)] : []),
      child: ClipOval(child: CustomPaint(painter: _CharacterPainter(panel, color))),
    ),
  );
}
class _CharacterPainter extends CustomPainter {
  _CharacterPainter(this.panel, this.color);
  final int panel;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final p = Paint();
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), p..color = color.withOpacity(.18));
    canvas.drawOval(const Rect.fromLTWH(12, 70, 76, 60), p..color = color);
    canvas.drawRect(const Rect.fromLTWH(43, 60, 14, 20), p..color = const Color(0xFFD7A783));
    canvas.drawOval(const Rect.fromLTWH(29, 18, 42, 49), p..color = const Color(0xFFE9BD98));
    final hair = panel == 2 ? const Color(0xFF697180) : const Color(0xFF232832);
    canvas.drawArc(const Rect.fromLTWH(27, 12, 46, 38), 3.14, 3.14, true, p..color = hair);
    if (panel == 0) {
      canvas.drawOval(const Rect.fromLTWH(26, 13, 28, 24), p..color = hair);
    } else if (panel == 1) {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(29, 13, 42, 16), const Radius.circular(5)), p..color = hair);
    }
    p..color = const Color(0xFF292A30)..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(40, 42), 2, p);
    canvas.drawCircle(const Offset(60, 42), 2, p);
    if (panel == 2) {
      p..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawCircle(const Offset(40, 42), 8, p);
      canvas.drawCircle(const Offset(60, 42), 8, p);
      canvas.drawLine(const Offset(48, 42), const Offset(52, 42), p);
    }
    p..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0xFF805847);
    canvas.drawArc(const Rect.fromLTWH(43, 48, 14, 10), .2, 2.7, false, p);
    if (panel == 0) {
      // Independent bearded character for the fallback portrait as well.
      p..style = PaintingStyle.fill..color = hair;
      final beard = Path()..moveTo(30, 46)..lineTo(38, 52)..lineTo(44, 50)
        ..lineTo(56, 50)..lineTo(62, 52)..lineTo(70, 46)..lineTo(66, 65)
        ..quadraticBezierTo(50, 83, 34, 65)..close();
      canvas.drawPath(beard, p);
      canvas.drawOval(const Rect.fromLTWH(40, 48, 20, 6), p);
      p..color = const Color(0xFFE9BD98);
      canvas.drawOval(const Rect.fromLTWH(45, 55, 10, 3), p);
    }
    p..style = PaintingStyle.fill..color = Colors.white;
    final collar = Path()..moveTo(35, 73)..lineTo(50, 84)..lineTo(65, 73)..lineTo(55, 96)..lineTo(45, 96)..close();
    canvas.drawPath(collar, p);
    if (panel != 1) {
      final tie = Path()..moveTo(50, 82)..lineTo(55, 90)..lineTo(50, 100)..lineTo(45, 90)..close();
      canvas.drawPath(tie, p..color = const Color(0xFF242735));
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _CharacterPainter old) => old.panel != panel || old.color != color;
}
