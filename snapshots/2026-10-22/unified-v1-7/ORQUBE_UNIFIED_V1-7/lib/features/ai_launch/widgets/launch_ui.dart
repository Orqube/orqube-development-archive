import 'package:flutter/material.dart';

class LaunchPalette {
  static const bg = Color(0xFF070A13);
  static const bg2 = Color(0xFF101528);
  static const panel = Color(0xFF151B31);
  static const panel2 = Color(0xFF1C2440);
  static const line = Color(0x334E66FF);
  static const purple = Color(0xFF7A6CFF);
  static const blue = Color(0xFF4D8DFF);
  static const cyan = Color(0xFF58D7FF);
  static const green = Color(0xFF6CE5A8);
  static const text = Color(0xFFF3F5FF);
  static const muted = Color(0xFFA8B0CC);
}

class LaunchBackground extends StatelessWidget {
  const LaunchBackground({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaunchPalette.bg,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Container(
        // Internal TOKEN LAUNCH screens intentionally use only the
        // standard dark gradient. The soldier/space hero image belongs to
        // the main ORQUBE home page only.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [LaunchPalette.bg, LaunchPalette.bg2, Color(0xFF0B1021)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -50,
              child: _Glow(size: 240, color: LaunchPalette.purple),
            ),
            Positioned(
              top: 260,
              left: -90,
              child: _Glow(size: 260, color: LaunchPalette.blue),
            ),
            Positioned.fill(child: child),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(.20),
              color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }
}

class LaunchGlassCard extends StatelessWidget {
  const LaunchGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      decoration: BoxDecoration(
        color: LaunchPalette.panel.withOpacity(.80),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LaunchPalette.line),
        boxShadow: const [
          BoxShadow(
            blurRadius: 26,
            offset: Offset(0, 12),
            color: Color(0x33000000),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) return body;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: body,
      ),
    );
  }
}

class LaunchStatusPill extends StatelessWidget {
  const LaunchStatusPill({
    super.key,
    required this.label,
    this.icon,
    this.active = false,
  });

  final String label;
  final IconData? icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: active
            ? LaunchPalette.purple.withOpacity(.18)
            : Colors.white.withOpacity(.055),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? LaunchPalette.purple.withOpacity(.55)
              : Colors.white.withOpacity(.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: LaunchPalette.muted),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: LaunchPalette.text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class LaunchSectionTitle extends StatelessWidget {
  const LaunchSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: LaunchPalette.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: const TextStyle(
                color: LaunchPalette.muted,
                fontSize: 12.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

AppBar launchAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo/orqube_plane_logo.png', width: 34, height: 34, fit: BoxFit.contain),
        const SizedBox(width: 9),
        Flexible(child: Text(title)),
      ],
    ),
    actions: actions,
    backgroundColor: LaunchPalette.bg.withOpacity(.92),
    foregroundColor: LaunchPalette.text,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  );
}
