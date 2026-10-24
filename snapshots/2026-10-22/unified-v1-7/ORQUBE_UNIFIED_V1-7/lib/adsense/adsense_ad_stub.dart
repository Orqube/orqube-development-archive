import 'package:flutter/widgets.dart';

class OrqubeAdSenseAd extends StatelessWidget {
  const OrqubeAdSenseAd({
    super.key,
    required this.placement,
    this.maxWidth = 1180,
  });

  final String placement;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
