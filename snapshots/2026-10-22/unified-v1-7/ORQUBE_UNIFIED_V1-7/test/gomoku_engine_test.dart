// Standalone: dart test/gomoku_engine_test.dart (no Firebase or Flutter needed).
import 'dart:math';

import '../lib/games/gomoku_engine.dart';

void check(bool value, String message) {
  if (!value) throw StateError(message);
}

void main() {
  var g = GomokuEngine();
  check(!g.place(-1, 0, 1), 'reject out of bounds');
  check(!g.place(0, 0, 2), 'black starts');
  check(g.place(0, 0, 1), 'first move');
  check(!g.place(0, 0, 2), 'occupied');
  check(!g.place(1, 0, 1), 'enforce turn');
  g = GomokuEngine();
  for (var x = 0; x < 4; x++) {
    check(g.place(x, 7, 1), 'black');
    check(g.place(x, 0, 2), 'white');
  }
  final defense = g.chooseAi();
  // It is the human turn after 4 full rounds, so AI cannot move.
  check(defense == null, 'AI cannot play on human turn');
  check(
    g.place(4, 7, 1) && g.winner == 1 && g.winningLine.length == 5,
    'horizontal win',
  );
  check(!g.place(10, 10, 2), 'no moves after win');
  g.undoRound();
  check(
    !g.finished && g.moves.length == 8 && g.nextPlayer == 1,
    'undo winning move',
  );
  g = GomokuEngine();
  for (var i = 0; i < 4; i++) {
    g.place(i, i, 1);
    g.place(14, i, 2);
  }
  g.place(4, 4, 1);
  check(g.winner == 1, 'diagonal win');
  g = GomokuEngine();
  for (var i = 0; i < 4; i++) {
    g.place(2, i, 1);
    g.place(14, i, 2);
  }
  g.place(2, 4, 1);
  check(g.winner == 1, 'vertical win');
  g = GomokuEngine();
  for (var i = 0; i < 3; i++) {
    g.place(3 + i, 7, 1);
    g.place(i, 0, 2);
  }
  g.place(6, 7, 1);
  final block = g.chooseAi(difficulty: 'hard')!;
  check(
    block.y == 7 && (block.x == 2 || block.x == 7),
    'AI blocks immediate threat',
  );
  g = GomokuEngine();
  for (var i = 0; i < 4; i++) {
    g.place(i, 10, 1);
    g.place(i, 1, 2);
  }
  g.place(14, 14, 1);
  final win = g.chooseAi(difficulty: 'hard')!;
  check(g.place(win.x, win.y, 2) && g.winner == 2, 'AI wins before defending');
  g = GomokuEngine();
  g.place(7, 7, 1);
  final ai = g.chooseAi(random: Random(1))!;
  check(g.place(ai.x, ai.y, 2), 'AI legal move');
  g.undoRound();
  check(g.moves.isEmpty && g.board[7][7] == 0, 'undo full round');
  final r = Random(42);
  for (var n = 0; n < 8; n++) {
    g = GomokuEngine();
    while (!g.finished) {
      if (g.nextPlayer == 1) {
        final empty = <Point<int>>[];
        for (var y = 0; y < 15; y++)
          for (var x = 0; x < 15; x++)
            if (g.board[y][x] == 0) empty.add(Point(x, y));
        final p = empty[r.nextInt(empty.length)];
        check(g.place(p.x, p.y, 1), 'random human move');
      } else {
        final p = g.chooseAi(random: r)!;
        check(g.place(p.x, p.y, 2), 'AI plays only legal cells');
      }
    }
  }
  print(
    'PASS: turn order, bounds, occupied cells, wins, undo, AI tactics, 8 simulated games',
  );
}
