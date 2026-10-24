import 'dart:convert';
import 'dart:typed_data';

class DebateVisual {
  final String id, title, kind, slogan, status, keywords, content;
  final Uint8List? image;
  const DebateVisual({required this.id, required this.title, this.kind = 'flow',
    this.slogan = '', this.status = '설명 예시 · 구현 상태 확인 필요',
    this.keywords = '', this.content = '', this.image});

  Map<String, dynamic> toJson({bool includeImage = true}) => {
    'id': id, 'title': title, 'kind': kind, 'slogan': slogan,
    'status': status, 'keywords': keywords, 'content': content,
    if (includeImage && image != null) 'image': base64Encode(image!),
  };
  factory DebateVisual.fromJson(Map<String, dynamic> x) => DebateVisual(
    id: x['id'] as String, title: x['title'] as String,
    kind: x['kind'] as String? ?? 'flow', slogan: x['slogan'] as String? ?? '',
    status: x['status'] as String? ?? '상태 확인 필요',
    keywords: x['keywords'] as String? ?? '', content: x['content'] as String? ?? '',
    image: x['image'] is String ? base64Decode(x['image'] as String) : null);

  static const defaults = <DebateVisual>[
    DebateVisual(id: 'overview', title: 'ORQUBE의 방향', kind: 'slogan',
      slogan: '일상 속 참여를 가치로', keywords: 'ORQUBE,오르큐브,미래,플랫폼',
      content: '커뮤니티 · 안전 · 블록체인 · AI\n실사용 중심으로 기능을 연결하는 방향'),
    DebateVisual(id: 'hiking', title: '안심산행 · 안심귀가', keywords: '산행,등산,귀가,안전,위험',
      slogan: '출발부터 귀가까지, 안전을 함께',
      content: '경로 계획\n출발·위치 공유\n위험 상황 알림\n귀가 확인'),
    DebateVisual(id: 'token', title: '자동 토큰 생성', keywords: '토큰,생성,발행,배포,검증',
      slogan: '아이디어를 설계하고, 확인 후 발행',
      content: '용도·발행량 직접 설정\nAI 설계 초안\n테스트넷 확인\n배포 전 최종 확인\n검증·활용'),
    DebateVisual(id: 'qr', title: 'QR 보상 활용', keywords: 'QR,매장,보상,수령,지갑',
      slogan: '현장의 참여를 보상으로 연결',
      content: '발행자 캠페인 설정\n방문자 QR 스캔\n받을 지갑 확인\n보상 수령\n지급 기록 확인'),
    DebateVisual(id: 'services', title: '서비스 활용 비교', kind: 'table',
      keywords: '채굴,에어소프트,커뮤니티,마케팅',
      content: '기능 | 활용 예시\n에어소프트 | 모임·활동 정보 공유\n채굴·보상 | 참여 보상 설계\nAI 마케팅 | 서비스·토큰 소개 초안\n안전 서비스 | 산행·귀가 확인'),
    DebateVisual(id: 'roadmap', title: '발전 방향 제안', keywords: '로드맵,단계,우선,향후,계획',
      status: '미래 방향 제안 · 확정 일정 아님',
      slogan: '기능 안정화에서 실사용 확장으로',
      content: '핵심 기능 안정화\n매장·산행 현장 검증\n이용자 피드백 반영\n다국어·커뮤니티 확장'),
  ];
}
