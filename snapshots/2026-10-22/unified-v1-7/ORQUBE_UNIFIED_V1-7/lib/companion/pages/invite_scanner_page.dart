import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/app_language.dart';
import '../utils/connection_invite.dart';
import 'companion_theme.dart';

class InviteScannerPage extends StatefulWidget {
  const InviteScannerPage({super.key});
  @override State<InviteScannerPage> createState() => _InviteScannerPageState();
}
class _InviteScannerPageState extends State<InviteScannerPage> with LanguageAware<InviteScannerPage> {
  final controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  bool done = false;
  String message = '상대방의 초대 QR을 네모 안에 비춰주세요.';
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Theme(data: companionLightTheme(), child: Scaffold(
    appBar: AppBar(title: AppText('초대 QR 스캔')),
    body: Column(children: [Padding(padding: const EdgeInsets.all(20), child: AppText(message, style: const TextStyle(fontSize: 18))),
      Expanded(child: MobileScanner(controller: controller,
        errorBuilder: (context, error) => Center(child: Padding(padding: const EdgeInsets.all(24), child: AppText('카메라를 사용할 수 없습니다. 카메라 권한을 확인하거나 뒤로 가서 초대 링크를 붙여넣으세요.'))),
        onDetect: (capture) {
          if (done) return;
          for (final barcode in capture.barcodes) {
            final invite = ConnectionInvite.parse(barcode.rawValue ?? '', allowId: true);
            if (invite != null) { done = true; Navigator.pop(context, invite); return; }
          }
          if (mounted) setState(() => message = '오르큐브 초대 QR이 아닙니다. 올바른 QR을 스캔하세요.');
        },
      )),
      Padding(padding: const EdgeInsets.all(20), child: AppText('스캔은 연결 정보를 읽기만 합니다. 확인 전에는 요청이나 위치 공유가 시작되지 않습니다.')),
    ]),
  ));
}
