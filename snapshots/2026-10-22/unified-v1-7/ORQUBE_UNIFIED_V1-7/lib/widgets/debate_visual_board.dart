import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/debate_visual.dart';

class DebateVisualBoard extends StatelessWidget {
  final DebateVisual visual;
  final String speaker, subtitle;
  const DebateVisualBoard({super.key, required this.visual,
    required this.speaker, required this.subtitle});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xFF102A43),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF55E6FF))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('자료 / VISUAL · $speaker', style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
      const SizedBox(height: 8),
      Text(visual.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      Text(visual.status, style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
      const SizedBox(height: 16),
      if (visual.slogan.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 14),
        child: Text(visual.slogan, style: const TextStyle(color: Colors.cyanAccent,
          fontSize: 23, fontWeight: FontWeight.w800))),
      if (visual.kind == 'image' && visual.image != null)
        SizedBox(height: 250, width: double.infinity, child: Image.memory(visual.image!, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text('이미지를 읽을 수 없습니다.', style: TextStyle(color: Colors.white))))
      else if (visual.kind == 'table') _table()
      else if (visual.kind == 'chart') _chart()
      else if (visual.kind == 'flow') Wrap(spacing: 8, runSpacing: 10,
        children: visual.content.split('\n').where((x) => x.trim().isNotEmpty).toList().asMap().entries.map((e) =>
          Container(constraints: const BoxConstraints(maxWidth: 250), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF1C405C), borderRadius: BorderRadius.circular(10)),
            child: Text('${e.key + 1}. ${e.value}', style: const TextStyle(color: Colors.white, fontSize: 16)))).toList())
      else Text(visual.content, style: const TextStyle(color: Colors.white, fontSize: 19, height: 1.5)),
      if (visual.kind == 'image' && visual.content.isNotEmpty)
        Text(visual.content, style: const TextStyle(color: Colors.white70)),
      if (subtitle.isNotEmpty) ...[
        const Divider(color: Colors.white24, height: 26),
        Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4)),
      ],
    ]),
  );

  Widget _table() {
    final rows = visual.content.split('\n').where((x) => x.trim().isNotEmpty)
      .map((x) => x.split('|').map((v) => v.trim()).toList()).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    final columns = rows.fold<int>(1, (n, row) => row.length > n ? row.length : n);
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      headingTextStyle: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
      dataTextStyle: const TextStyle(color: Colors.white),
      columns: List.generate(columns, (i) => DataColumn(label: Text(i < rows.first.length ? rows.first[i] : ''))),
      rows: rows.skip(1).map((row) => DataRow(cells: List.generate(columns,
        (i) => DataCell(Text(i < row.length ? row[i] : ''))))).toList()));
  }

  Widget _chart() {
    final values = <MapEntry<String, double>>[];
    for (final line in visual.content.split('\n')) {
      final parts = line.split('|');
      final value = parts.length == 2 ? double.tryParse(parts[1].trim()) : null;
      if (value != null && value.isFinite && value >= 0) values.add(MapEntry(parts[0].trim(), value));
    }
    final max = values.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    return Column(children: values.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${e.key}  ${e.value}', style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: max == 0 ? 0 : e.value / max, minHeight: 14,
          color: Colors.cyanAccent, backgroundColor: Colors.white12),
      ]))).toList());
  }
}

Future<DebateVisual?> editDebateVisual(BuildContext context, DebateVisual original) async {
  final title = TextEditingController(text: original.title);
  final slogan = TextEditingController(text: original.slogan);
  final status = TextEditingController(text: original.status);
  final keywords = TextEditingController(text: original.keywords);
  final content = TextEditingController(text: original.content);
  var kind = original.kind;
  Uint8List? bytes = original.image;
  String? error;
  bool picking = false;
  Widget input(TextEditingController controller, String label, {int lines = 1, int length = 160}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: TextField(
      controller: controller, maxLines: lines, maxLength: length,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())));
  try {
    return await showDialog<DebateVisual>(context: context, barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(builder: (context, update) => AlertDialog(
        title: const Text('토론 자료 편집'),
        content: SizedBox(width: 580, child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          DropdownButtonFormField<String>(value: kind,
            items: const [DropdownMenuItem(value: 'flow', child: Text('단계 흐름도')),
              DropdownMenuItem(value: 'table', child: Text('표')),
              DropdownMenuItem(value: 'slogan', child: Text('표어')),
              DropdownMenuItem(value: 'image', child: Text('이미지')),
              DropdownMenuItem(value: 'chart', child: Text('막대 도표'))],
            onChanged: (v) => update(() => kind = v ?? 'flow')),
          input(title, '자료 제목'), input(slogan, '큰 표어'),
          input(status, '구현 상태·출처·기준일'),
          input(keywords, '자동 전환 보조 키워드 (쉼표 구분)'),
          input(content, kind == 'table' ? '첫 줄은 제목행, 각 열은 | 로 구분'
            : kind == 'chart' ? '항목 | 수치 (0 이상, 한 줄에 하나 · 단위는 제목에 표시)'
            : '설명·단계 (한 줄에 하나)', lines: 6, length: 1400),
          if (kind == 'image') ...[
            TextButton.icon(onPressed: picking ? null : () async {
              update(() => picking = true);
              try {
                final picked = await FilePicker.platform.pickFiles(type: FileType.custom,
                  allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'], withData: true);
                if (!dialogContext.mounted) return;
                if (picked != null) {
                  final file = picked.files.single;
                  if (file.size > 2 * 1024 * 1024 || file.bytes == null) {
                    update(() => error = '2MB 이하의 이미지 파일을 선택해주세요.');
                  } else {
                    update(() { bytes = file.bytes; error = null; });
                  }
                }
              } catch (_) {
                if (dialogContext.mounted) update(() => error = '이미지를 불러오지 못했습니다.');
              } finally {
                if (dialogContext.mounted) update(() => picking = false);
              }
            }, icon: const Icon(Icons.image), label: Text(picking ? '불러오는 중…' : '이미지 선택 (2MB 이하)')),
            if (bytes != null) SizedBox(height: 120, child: Image.memory(bytes!, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Text('유효한 이미지 파일을 선택해주세요.'))),
          ],
          if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
          const Text('AI는 자료를 토론 참고로 사용합니다. 수치·출처·구현 상태를 직접 확인해주세요.'),
        ]))),
        actions: [TextButton(onPressed: picking ? null : () => Navigator.pop(dialogContext), child: const Text('취소')),
          FilledButton(onPressed: picking ? null : () {
            if (title.text.trim().isEmpty || (kind == 'image' && bytes == null)) {
              update(() => error = '제목과 필요한 이미지를 입력해주세요.'); return;
            }
            if (kind == 'chart' && content.text.split('\n').where((x) => x.trim().isNotEmpty).any((line) {
              final p = line.split('|'); final n = p.length == 2 ? double.tryParse(p[1].trim()) : null;
              return n == null || !n.isFinite || n < 0;
            })) { update(() => error = '도표는 항목 | 0 이상의 숫자 형식으로 입력해주세요.'); return; }
            Navigator.pop(dialogContext, DebateVisual(id: original.id, title: title.text.trim(),
              kind: kind, slogan: slogan.text.trim(), status: status.text.trim(),
              keywords: keywords.text.trim(), content: content.text.trim(), image: kind == 'image' ? bytes : null));
          }, child: const Text('저장'))],
      )));
  } finally {
    for (final c in [title, slogan, status, keywords, content]) { c.dispose(); }
  }
}
