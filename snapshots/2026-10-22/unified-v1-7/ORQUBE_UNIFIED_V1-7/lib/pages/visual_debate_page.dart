import 'package:flutter/material.dart';
import 'ai_three_way_debate_page.dart';

/// Separate route; reuses the proven timer, speech and recorder lifecycle.
class VisualDebatePage extends StatelessWidget {
  const VisualDebatePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const AiThreeWayDebatePage(presentation: true);
}
