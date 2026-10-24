import 'dart:math';

/// Freestyle Gomoku: five or more connected stones win, no forbidden moves.
/// Local practice only; never authorizes a token reward.
class GomokuMove {
  const GomokuMove(this.x, this.y, this.player);
  final int x, y, player;
}

class GomokuEngine {
  static const size = 15;
  static const directions = [
    [1, 0],
    [0, 1],
    [1, 1],
    [1, -1],
  ];
  final board = List.generate(size, (_) => List.filled(size, 0));
  final List<GomokuMove> moves = [];
  final List<Point<int>> winningLine = [];
  int winner = 0;
  bool get finished => winner != 0 || moves.length == size * size;
  int get nextPlayer => moves.length.isEven ? 1 : 2;
  bool inside(int x, int y) => x >= 0 && x < size && y >= 0 && y < size;

  bool place(int x, int y, int player) {
    if (finished || !inside(x, y) || board[y][x] != 0 || player != nextPlayer)
      return false;
    board[y][x] = player;
    moves.add(GomokuMove(x, y, player));
    for (final d in directions) {
      final line = <Point<int>>[Point(x, y)];
      for (final sign in [-1, 1]) {
        var a = x + d[0] * sign, b = y + d[1] * sign;
        while (inside(a, b) && board[b][a] == player) {
          if (sign == -1) {
            line.insert(0, Point(a, b));
          } else {
            line.add(Point(a, b));
          }
          a += d[0] * sign;
          b += d[1] * sign;
        }
      }
      if (line.length >= 5) {
        winner = player;
        winningLine.addAll(line);
        break;
      }
    }
    return true;
  }

  void undoRound() {
    if (moves.isEmpty) return;
    var count = moves.last.player == 2 ? 2 : 1;
    while (count-- > 0 && moves.isNotEmpty) {
      final m = moves.removeLast();
      board[m.y][m.x] = 0;
    }
    winner = 0;
    winningLine.clear();
  }

  int _score(int x, int y, int player) {
    var total = 0;
    for (final d in directions) {
      var count = 1, open = 0;
      for (final sign in [-1, 1]) {
        var a = x + d[0] * sign, b = y + d[1] * sign;
        while (inside(a, b) && board[b][a] == player) {
          count++;
          a += d[0] * sign;
          b += d[1] * sign;
        }
        if (inside(a, b) && board[b][a] == 0) open++;
      }
      total += count >= 5
          ? 1000000
          : count == 4
          ? (open == 2
                ? 80000
                : open == 1
                ? 12000
                : 0)
          : count == 3
          ? (open == 2
                ? 5000
                : open == 1
                ? 300
                : 0)
          : count == 2
          ? (open == 2
                ? 200
                : open == 1
                ? 30
                : 0)
          : open * 3;
    }
    return total;
  }

  Point<int>? chooseAi({String difficulty = 'easy', Random? random}) {
    if (finished || nextPlayer != 2) return null;
    final candidates =
        <({int x, int y, int attack, int defense, double value})>[];
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        if (board[y][x] != 0 ||
            !moves.any((m) => max((m.x - x).abs(), (m.y - y).abs()) <= 2))
          continue;
        final attack = _score(x, y, 2), defense = _score(x, y, 1);
        candidates.add((
          x: x,
          y: y,
          attack: attack,
          defense: defense,
          value:
              attack +
              defense * (difficulty == 'hard' ? 1.2 : .95) +
              14 -
              (x - 7).abs() -
              (y - 7).abs(),
        ));
      }
    }
    if (candidates.isEmpty) return null;
    for (final c in candidates) {
      if (c.attack >= 1000000) return Point(c.x, c.y);
    }
    for (final c in candidates) {
      if (c.defense >= 1000000) return Point(c.x, c.y);
    }
    candidates.sort((a, b) => b.value.compareTo(a.value));
    final pool = min(
      candidates.length,
      difficulty == 'easy'
          ? 4
          : difficulty == 'normal'
          ? 2
          : 1,
    );
    final chosen = candidates[(random ?? Random()).nextInt(pool)];
    return Point(chosen.x, chosen.y);
  }
}
