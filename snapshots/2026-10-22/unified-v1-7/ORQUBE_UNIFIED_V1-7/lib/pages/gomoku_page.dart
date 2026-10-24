import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../games/gomoku_engine.dart';
import '../games/game_text.dart';

class GomokuPage extends StatefulWidget {
  const GomokuPage({super.key, required this.language});
  final String language;
  @override
  State<GomokuPage> createState() => _GomokuPageState();
}

class _GomokuPageState extends State<GomokuPage> {
  var game = GomokuEngine();
  Point<int>? selected;
  String difficulty = 'easy', activeDifficulty = 'easy';
  bool thinking = false;
  Timer? timer;
  StreamSubscription<User?>? authSubscription;
  String? ownerUid;
  String tr(String ko, String en) => gameText(widget.language, ko, en);
  @override
  void initState() {
    super.initState();
    ownerUid = FirebaseAuth.instance.currentUser?.uid;
    authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user?.uid != ownerUid) {
        timer?.cancel();
        if (mounted) Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    authSubscription?.cancel();
    super.dispose();
  }

  void restart() {
    timer?.cancel();
    setState(() {
      game = GomokuEngine();
      selected = null;
      thinking = false;
      activeDifficulty = difficulty;
    });
  }

  Future<void> requestRestart() async {
    if (game.moves.isEmpty) {
      restart();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('새로 시작할까요?', 'Start a new game?')),
        content: Text(
          tr('현재 판의 진행 내용은 지워집니다.', 'This will clear the current board.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('취소', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('새로 시작', 'New game')),
          ),
        ],
      ),
    );
    if (mounted && confirmed == true) restart();
  }

  void place() {
    if (selected == null ||
        thinking ||
        game.finished ||
        FirebaseAuth.instance.currentUser?.uid != ownerUid ||
        ownerUid == null)
      return;
    final p = selected!;
    if (!game.place(p.x, p.y, 1)) return;
    setState(() {
      selected = null;
      thinking = !game.finished;
    });
    if (!thinking) return;
    timer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final p = game.chooseAi(difficulty: activeDifficulty);
      setState(() {
        if (p != null) game.place(p.x, p.y, 2);
        thinking = false;
      });
    });
  }

  String get status => game.winner == 1
      ? tr('축하합니다! 이겼습니다.', 'Congratulations! You won.')
      : game.winner == 2
      ? tr('AI 승리 · 다시 도전해보세요.', 'AI wins. Try again!')
      : game.finished
      ? tr('무승부입니다.', 'It is a draw.')
      : thinking
      ? tr('AI가 생각 중…', 'AI is thinking…')
      : tr('● 내 차례입니다', '● Your turn');
  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF20553F),
        brightness: Brightness.light,
      ),
    ),
    child: Scaffold(
      backgroundColor: const Color(0xFFF4F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5EF),
        foregroundColor: const Color(0xFF183E31),
        title: Text(tr('오목 한 판', 'Gomoku')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tr(
                      '나의 흑돌 ● · AI의 백돌 ○ · 시간 제한 없음',
                      'You: black ● · AI: white ○ · No time limit',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF526B59),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Text(tr('AI 난이도', 'AI difficulty')),
                          DropdownButton<String>(
                            value: difficulty,
                            items: [
                              DropdownMenuItem(
                                value: 'easy',
                                child: Text(tr('쉬움', 'Easy')),
                              ),
                              DropdownMenuItem(
                                value: 'normal',
                                child: Text(tr('보통', 'Normal')),
                              ),
                              DropdownMenuItem(
                                value: 'hard',
                                child: Text(tr('어려움', 'Hard')),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null)
                                setState(() {
                                  difficulty = value;
                                  if (game.moves.isEmpty)
                                    activeDifficulty = value;
                                });
                            },
                          ),
                          Text(
                            tr('새 판부터 적용', 'Applies to a new game'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF647569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF183E31),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '${game.moves.length}${tr('수', ' moves')}',
                                style: const TextStyle(
                                  color: Color(0xFF647569),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final side = constraints.maxWidth;
                              return Semantics(
                                label: tr(
                                  '오목판. 교차점을 눌러 위치를 고르세요.',
                                  'Gomoku board. Tap an intersection to select a move.',
                                ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapUp: thinking || game.finished
                                      ? null
                                      : (details) {
                                          final margin = side * .05,
                                              cell = side * .9 / 14;
                                          final x =
                                              ((details.localPosition.dx -
                                                          margin) /
                                                      cell)
                                                  .round();
                                          final y =
                                              ((details.localPosition.dy -
                                                          margin) /
                                                      cell)
                                                  .round();
                                          if (game.inside(x, y) &&
                                              game.board[y][x] == 0)
                                            setState(
                                              () => selected = Point(x, y),
                                            );
                                        },
                                  child: CustomPaint(
                                    size: Size.square(side),
                                    painter: _GomokuPainter(game, selected),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            selected == null
                                ? tr(
                                    '교차점을 눌러 위치를 고르세요.',
                                    'Tap an intersection to select your move.',
                                  )
                                : tr(
                                    '${selected!.y + 1}행 · ${selected!.x + 1}열 — 위치를 확인하세요.',
                                    'Row ${selected!.y + 1} · Column ${selected!.x + 1} — Confirm the position.',
                                  ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF526B59),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF20553F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(18),
                            ),
                            onPressed:
                                selected == null || thinking || game.finished
                                ? null
                                : place,
                            child: Text(tr('이곳에 돌 놓기', 'Place stone here')),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: thinking || game.moves.isEmpty
                                    ? null
                                    : () => setState(() {
                                        game.undoRound();
                                        selected = null;
                                      }),
                                child: Text(tr('한 수 되돌리기', 'Undo a round')),
                              ),
                              OutlinedButton(
                                onPressed: requestRestart,
                                child: Text(tr('새로 시작', 'New game')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(
                      '선이 만나는 곳 선택 → 위치 확인 → 돌 놓기\n가로·세로·대각선으로 5개 이상 이어지면 승리합니다.\n금수 없는 자유 오목 · 체험 전용 · 토큰 지급 없음',
                      'Select an intersection → Check the position → Place stone\nConnect 5 or more stones horizontally, vertically or diagonally to win.\nFreestyle Gomoku · Practice only · No token rewards',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF526B59),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _GomokuPainter extends CustomPainter {
  _GomokuPainter(this.game, this.selected);
  final GomokuEngine game;
  final Point<int>? selected;
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.width, margin = side * .05, cell = side * .9 / 14;
    Offset at(int x, int y) => Offset(margin + x * cell, margin + y * cell);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      Paint()..color = const Color(0xFFDFBA7D),
    );
    final grid = Paint()
      ..color = const Color(0xFF97703F)
      ..strokeWidth = .8;
    for (var i = 0; i < 15; i++) {
      canvas.drawLine(at(i, 0), at(i, 14), grid);
      canvas.drawLine(at(0, i), at(14, i), grid);
    }
    for (final x in [3, 7, 11]) {
      for (final y in [3, 7, 11]) {
        canvas.drawCircle(at(x, y), max(1.5, cell * .06), grid);
      }
    }
    for (var y = 0; y < 15; y++) {
      for (var x = 0; x < 15; x++) {
        if (game.board[y][x] == 0) continue;
        final center = at(x, y), radius = cell * .44;
        canvas.drawCircle(
          center.translate(0, 2),
          radius,
          Paint()..color = const Color(0x33000000),
        );
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-.35, -.4),
              colors: game.board[y][x] == 1
                  ? [const Color(0xFF555555), const Color(0xFF111111)]
                  : [Colors.white, const Color(0xFFD7D6CE)],
            ).createShader(Rect.fromCircle(center: center, radius: radius)),
        );
      }
    }
    if (game.moves.isNotEmpty) {
      final m = game.moves.last;
      canvas.drawCircle(
        at(m.x, m.y),
        cell * .12,
        Paint()..color = const Color(0xFFD09B3C),
      );
    }
    if (selected != null && !game.finished) {
      canvas.drawCircle(
        at(selected!.x, selected!.y),
        cell * .47,
        Paint()
          ..color = const Color(0xFF146C49)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
    }
    if (game.winningLine.isNotEmpty) {
      final a = game.winningLine.first, b = game.winningLine.last;
      canvas.drawLine(
        at(a.x, a.y),
        at(b.x, b.y),
        Paint()
          ..color = const Color(0xFFBF4C32)
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GomokuPainter oldDelegate) => true;
}
