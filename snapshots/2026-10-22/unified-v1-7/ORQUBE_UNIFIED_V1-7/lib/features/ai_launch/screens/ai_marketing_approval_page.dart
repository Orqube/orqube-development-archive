import 'package:flutter/material.dart';
import '../../../admin/marketing_approval_page.dart';

class AiMarketingApprovalPage extends StatelessWidget {
  const AiMarketingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MarketingApprovalPage(
      onlyTokenLaunch: true,
      title: 'AI TOKEN LAUNCH Approval',
    );
  }
}
