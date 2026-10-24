import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../games/game_text.dart';
import '../utils/orqube_i18n.dart';
import 'login_page.dart';
import 'gomoku_page.dart';

class GameBoothBanner extends StatelessWidget {
  const GameBoothBanner({super.key, required this.language});
  final String language;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Material(
      color: const Color(0xFF132D27),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GameBoothPage(language: language)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(
                Icons.sports_esports_rounded,
                color: Color(0xFFD7FF35),
                size: 34,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORQUBE · ${gameBoothTitle(language)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      gameText(
                        language,
                        'AI 오목 오픈! 한 수씩 즐겨보세요. 체험 전용 · 토큰 지급 없음',
                        'AI Gomoku is here! Play at your pace. Practice only · No token rewards',
                        ja: 'AI五目並べ登場！練習専用・トークン報酬なし',
                        zh: 'AI五子棋上线！仅供练习 · 无代币奖励',
                        fr: 'Gomoku contre l’IA ! Entraînement sans récompense en jetons.',
                        pt: 'Gomoku com IA! Prática sem recompensas em tokens.',
                      ),
                      style: const TextStyle(
                        color: Color(0xFFD2E1D5),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    ),
  );
}

class GameBoothPage extends StatelessWidget {
  const GameBoothPage({super.key, this.language});
  final String? language;
  Future<void> _play(BuildContext context, String lang) async {
    if (FirebaseAuth.instance.currentUser == null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (loginContext) => LoginPage(
            onLoginSuccess: () async {
              Navigator.of(loginContext).pop();
            },
          ),
        ),
      );
      if (!context.mounted || FirebaseAuth.instance.currentUser == null) return;
    }
    if (context.mounted)
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => GomokuPage(language: lang)));
  }

  @override
  Widget build(BuildContext context) {
    final lang = language ?? OrqubeI18n.currentLanguage;
    return Scaffold(
      backgroundColor: const Color(0xFF070D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070D16),
        foregroundColor: Colors.white,
        title: Text(gameBoothTitle(lang)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    gameText(
                      lang,
                      '잠깐의 여유, 한 판의 즐거움',
                      'A little break. A good game.',
                      ja: 'ひと休み、一局の楽しみ',
                      zh: '休息片刻，轻松一局',
                      fr: 'Une pause, une belle partie.',
                      pt: 'Uma pausa, uma boa partida.',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    gameText(
                      lang,
                      '기존 오르큐브 계정으로 이용합니다. 로그인 상태라면 바로 시작할 수 있습니다.',
                      'Use your existing ORQUBE account. Already signed in? Start right away.',
                    ),
                    style: const TextStyle(color: Colors.white70, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF142D27),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF41634B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.grid_on_rounded,
                          size: 64,
                          color: Color(0xFFD7FF35),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          gameText(
                            lang,
                            '오목 한 판',
                            'Gomoku',
                            ja: '五目並べ',
                            zh: '五子棋',
                            fr: 'Gomoku',
                            pt: 'Gomoku',
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          gameText(
                            lang,
                            'AI 대결 · 난이도 3단계 · 놓기 전 위치 확인\n시간 제한 없음 · 한 수 되돌리기',
                            'Play against AI · 3 difficulty levels · Confirm each move\nNo time limit · Undo a round',
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD7FF35),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                          ),
                          onPressed: () => _play(context, lang),
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            gameText(
                              lang,
                              '오목 시작하기',
                              'Play Gomoku',
                              ja: '対局開始',
                              zh: '开始游戏',
                              fr: 'Jouer au Gomoku',
                              pt: 'Jogar Gomoku',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    gameText(
                      lang,
                      '체험 전용 게임입니다. 이번 버전에는 ORBS 적립·지급이 연결되어 있지 않습니다. 게임 진행은 현재 화면에서만 유지됩니다.',
                      'Practice game only. ORBS accrual and payouts are not enabled in this version. Game progress lasts only while this screen is open.',
                    ),
                    style: const TextStyle(color: Colors.white60, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
