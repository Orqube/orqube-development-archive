import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

class ProfilePhotoCropPage extends StatefulWidget {
  const ProfilePhotoCropPage({super.key, required this.bytes});
  final Uint8List bytes;
  @override
  State<ProfilePhotoCropPage> createState() => _ProfilePhotoCropPageState();
}

class _ProfilePhotoCropPageState extends State<ProfilePhotoCropPage> {
  final _capture = GlobalKey();
  final _transform = TransformationController();
  bool _busy = false;
  bool _ready = false;
  @override
  void dispose() { _transform.dispose(); super.dispose(); }

  Future<void> _finish() async {
    if (_busy || !_ready) return;
    setState(() => _busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _capture.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final picture = await boundary.toImage(pixelRatio: 512 / boundary.size.width);
      final png = await picture.toByteData(format: ui.ImageByteFormat.png);
      picture.dispose();
      final decoded = img.decodePng(png!.buffer.asUint8List())!;
      Uint8List output = Uint8List(0);
      for (final quality in [85, 75, 60, 45]) {
        output = Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
        if (output.length <= 300 * 1024) break;
      }
      if (output.length > 300 * 1024) throw StateError('사진 압축에 실패했습니다.');
      if (mounted) Navigator.pop(context, output);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('사진을 처리하지 못했습니다. 다른 JPG/PNG 사진을 선택해주세요.')));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF03040B),
    appBar: AppBar(title: const Text('프로필 사진 자르기')),
    body: Column(children: [
      const Padding(padding: EdgeInsets.all(16), child: Text('사진을 드래그하고 두 손가락 또는 마우스 휠로 확대하세요.\n정사각형 안의 영역이 저장됩니다.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(16), child: AspectRatio(aspectRatio: 1, child:
        RepaintBoundary(key: _capture, child: ClipRect(child: ColoredBox(color: Colors.white, child:
          InteractiveViewer(transformationController: _transform, minScale: 1, maxScale: 5,
            child: SizedBox.expand(child: Image.memory(widget.bytes, fit: BoxFit.cover,
              frameBuilder: (context, child, frame, sync) {
                if (sync || frame != null) _ready = true;
                return child;
              }, errorBuilder: (_, __, ___) => const Center(child: Text('지원하지 않는 사진입니다.')))),
          ),
        ))),
      )))),
      Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton(onPressed: _busy ? null : () => _transform.value = Matrix4.identity(), child: const Text('위치 초기화')),
        const SizedBox(width: 16),
        FilledButton(onPressed: _busy ? null : _finish, child: Text(_busy ? '압축 중…' : '이 사진 사용')),
      ])),
    ]),
  );
}
