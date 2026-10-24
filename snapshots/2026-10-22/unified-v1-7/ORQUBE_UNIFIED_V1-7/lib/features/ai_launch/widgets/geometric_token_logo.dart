import 'dart:math' as math;
import 'package:flutter/material.dart';

Map<String, String> defaultTokenLogo(String symbol) {
  final seed = symbol.codeUnits.fold<int>(0, (n, c) => (n * 31 + c) & 0x7fffffff);
  return {
    'shape': const ['circle', 'hexagon', 'diamond'][seed % 3],
    'palette': const ['green', 'blue', 'purple', 'orange'][(seed ~/ 3) % 4],
  };
}

class GeometricTokenLogo extends StatelessWidget {
  const GeometricTokenLogo({super.key, required this.symbol, this.spec, this.size = 64});
  final String symbol;
  final Map? spec;
  final double size;

  @override
  Widget build(BuildContext context) {
    final settings = spec ?? defaultTokenLogo(symbol);
    final colors = <String, List<Color>>{
      'green': [const Color(0xff106456), const Color(0xff56ebbd)],
      'blue': [const Color(0xff174293), const Color(0xff63dcff)],
      'purple': [const Color(0xff542ba8), const Color(0xffd192ff)],
      'orange': [const Color(0xff9b3d20), const Color(0xffffcf73)],
    };
    final text = symbol.trim().toUpperCase();
    return SizedBox(width: size, height: size, child: ClipPath(
      clipper: _TokenShape((settings['shape'] ?? 'circle').toString()),
      child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: colors[settings['palette']] ?? colors['blue']!,
      )), child: Center(child: Padding(padding: EdgeInsets.all(size * .18),
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(
          text.isEmpty ? 'Q' : text.substring(0, math.min(3, text.length)),
          style: TextStyle(color: Colors.white, fontSize: size * .3, fontWeight: FontWeight.w900),
        )),
      ))),
    ));
  }
}

class _TokenShape extends CustomClipper<Path> {
  const _TokenShape(this.shape);
  final String shape;
  @override
  Path getClip(Size size) {
    if (shape == 'circle') return Path()..addOval(Offset.zero & size);
    final count = shape == 'diamond' ? 4 : 6;
    final path = Path();
    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / count;
      final x = size.width / 2 + math.cos(angle) * size.width / 2;
      final y = size.height / 2 + math.sin(angle) * size.height / 2;
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    return path..close();
  }
  @override
  bool shouldReclip(_TokenShape oldClipper) => shape != oldClipper.shape;
}
