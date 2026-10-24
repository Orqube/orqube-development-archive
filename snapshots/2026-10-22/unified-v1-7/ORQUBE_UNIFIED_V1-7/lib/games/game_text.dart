String gameText(
  String language,
  String ko,
  String en, {
  String? ja,
  String? zh,
  String? fr,
  String? pt,
}) {
  switch (language.split(RegExp('[-_]')).first) {
    case 'ko':
      return ko;
    case 'ja':
      return ja ?? en;
    case 'zh':
      return zh ?? en;
    case 'fr':
      return fr ?? en;
    case 'pt':
      return pt ?? en;
    default:
      return en;
  }
}

String gameBoothTitle(String language) => gameText(
  language,
  '게임 부스',
  'Game booth',
  ja: 'ゲームブース',
  zh: '游戏专区',
  fr: 'Espace jeux',
  pt: 'Espaço de jogos',
);
