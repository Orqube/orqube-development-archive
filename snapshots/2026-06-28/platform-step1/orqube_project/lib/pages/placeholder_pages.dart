import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SimplePage extends StatelessWidget {
  final String title;
  final IconData icon;
  const SimplePage({super.key, required this.title, required this.icon});
  @override Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: AppColors.purple, size: 70), const SizedBox(height: 16), Text(title, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)), const SizedBox(height: 8), const Text('다음 단계에서 실제 기능을 연결합니다.', style: TextStyle(color: AppColors.muted))]));
}
