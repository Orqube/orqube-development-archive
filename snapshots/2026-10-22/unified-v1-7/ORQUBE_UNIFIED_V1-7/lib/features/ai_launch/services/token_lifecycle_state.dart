class TokenLifecycleState {
  static String label(Map<String, dynamic> data) {
    final contract = (data['contractAddress'] ?? '').toString().trim();
    final archive = data['deploymentArchive'];
    final rootVerify = (data['verificationStatus'] ?? '').toString().toUpperCase();
    final archiveVerify = archive is Map
        ? (archive['verificationStatus'] ?? '').toString().toUpperCase()
        : '';
    if (rootVerify == 'VERIFIED' || archiveVerify == 'VERIFIED') return 'VERIFIED';
    if (contract.isNotEmpty) return 'DEPLOYED';
    return 'INTERNAL';
  }

  static String description(Map<String, dynamic> data) => switch (label(data)) {
    'VERIFIED' => '온체인 배포 + 소스검증 완료',
    'DEPLOYED' => '온체인 배포 완료 · 소스검증 전',
    _ => 'ORQUBE 내부 토큰 · 배포 없이 사용 가능',
  };
}
