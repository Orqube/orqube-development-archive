import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;
  const NeonCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.borderColor = AppColors.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor.withOpacity(0.9)),
        boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.08), blurRadius: 24)],
      ),
      child: child,
    );
  }
}
