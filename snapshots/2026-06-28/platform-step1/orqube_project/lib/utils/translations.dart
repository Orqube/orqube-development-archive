class T {
  static String get(String lang, String key) {
    final ko = {
      'join': '가입', 'login': '로그인', 'startMining': '채굴 시작하기',
      'dashboard': '대시보드', 'profile': '프로필', 'community': '커뮤니티', 'ranking': '랭킹',
      'walletTitle': 'ORQUBE 지갑 설정', 'walletSub': '기존 Kaia 지갑을 연결하거나 새 ORQUBE 지갑을 생성하세요.',
      'connectWallet': '기존 Kaia 지갑 연결', 'createWallet': '새 ORQUBE 지갑 생성', 'later': '나중에 설정',
    };
    final en = {'join':'Join','login':'Login','startMining':'Start Mining','dashboard':'Dashboard','profile':'Profile','community':'Community','ranking':'Ranking','walletTitle':'ORQUBE Wallet Setup','walletSub':'Connect Kaia Wallet or create ORQUBE Wallet.','connectWallet':'Connect Kaia Wallet','createWallet':'Create ORQUBE Wallet','later':'Later'};
    return (lang == 'ko' ? ko : en)[key] ?? key;
  }
}
