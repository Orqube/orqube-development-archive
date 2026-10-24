import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class OrqubeDomainButton extends StatelessWidget {
  const OrqubeDomainButton({super.key});
  @override Widget build(BuildContext context) => TextButton.icon(
    onPressed: () async {
      try {
        final opened = await launchUrl(Uri.parse('https://www.orqubic.com'),
          mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: SelectableText('https://www.orqubic.com')));
        }
      } catch (_) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: SelectableText('https://www.orqubic.com')));
      }
    },
    icon: const Icon(Icons.open_in_new, size: 15),
    label: const Text('orqubic.com', style: TextStyle(fontSize: 12)),
  );
}
