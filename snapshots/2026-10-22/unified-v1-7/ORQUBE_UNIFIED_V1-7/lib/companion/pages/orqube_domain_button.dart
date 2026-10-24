import 'package:flutter/material.dart';
class OrqubeDomainButton extends StatelessWidget {
  const OrqubeDomainButton({super.key});
  @override Widget build(BuildContext context) => TextButton.icon(
    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
    icon: const Icon(Icons.home_outlined, size: 15),
    label: const Text('ORQUBE', style: TextStyle(fontSize: 12)),
  );
}
