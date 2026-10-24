import 'package:flutter/material.dart';

const _legalDocuments = <String, String>{
  '회사소개': '''ORQUBE 서비스 소개

ORQUBE는 에어소프트 커뮤니티, 안심귀가·안전산행, 참여 보상, 토큰 활용 및 AI 콘텐츠 도구를 연결하는 서비스입니다. 공식 사이트는 www.orqubic.com입니다.

개발용의 AI 토론·마케팅, 토큰 생성·QR 보상 등은 시험 중인 기능을 포함합니다. 화면의 기능 제공 여부와 실제 서버 연결 상태에 따라 이용 범위가 달라질 수 있습니다.

AI 토론의 A·B·C는 가상 패널입니다. 생성된 내용은 사실 확인과 이용자의 검토가 필요합니다. 안전 기능은 위치 공유를 돕는 보조 도구이며 긴급 상황에서는 112·119 등 관계 기관에 직접 연락해야 합니다.

운영 문의: 공식 사이트의 FAQ & HELP와 TELEGRAM 안내를 이용해 주세요.
법인명·대표자·사업자등록번호·주소는 확인된 정보가 없어 이 개발용 안내에 기재하지 않았습니다. 공개 운영 전 운영자가 확정하여 고지해야 합니다.''',
  '이용약관': '''ORQUBE 이용약관 — 개발용 안내 초안
적용 안내일: 2026년 10월 2일

1. 목적과 서비스
이 안내는 ORQUBE 계정, 커뮤니티, 안전 보조 기능, 참여 보상 및 AI 도구 이용 기준을 설명합니다. 개발용 기능은 변경되거나 일시 중단될 수 있습니다.

2. 계정과 인증
본인의 이메일·Google 계정 또는 휴대폰을 사용하세요. 기존 계정의 전화번호 연결은 기존 계정으로 로그인한 뒤 진행해야 동일한 데이터를 이용할 수 있습니다. 인증번호와 지갑 복구 문구를 타인에게 제공하지 마세요.

3. 이용 기준
불법·유해 업종, 사기, 도박, 성매매, 권리 침해, 개인정보 무단 공개, 자동화된 보상 부정 수령 및 타인 계정 사용을 금지합니다. 위반 시 관련 기능이나 계정 이용이 제한될 수 있으며 문의 채널로 이의를 제기할 수 있습니다.

4. 보상·토큰·광고
앱 내부 보상 표시와 블록체인상의 지급 완료는 서로 다른 상태일 수 있습니다. 화면의 지급 기록과 거래 상태를 확인하세요. 토큰의 가치·환금성·수익·상장을 보장하지 않습니다. 네트워크 수수료와 유료 서비스 비용은 실행 전 안내를 확인해야 합니다.

5. AI 및 게시물
AI 결과에는 오류가 있을 수 있습니다. 게시물·홍보물의 사실관계와 권리 보유 여부를 이용자가 확인해야 합니다. 작성자는 자신의 콘텐츠 권리를 유지하며, 서비스 표시와 운영에 필요한 범위에서 게시물이 처리됩니다.

6. 안전 기능과 서비스 변경
위치·네트워크·기기 상태에 따라 안전 안내가 지연될 수 있습니다. 긴급 신고를 대신하지 않습니다. 중요한 운영 변경은 서비스 공지로 안내하며 관련 법령에 따른 이용자 권리를 제한하지 않습니다.

7. 탈퇴·문의
계정 및 개인정보 처리 문의는 FAQ & HELP 또는 공식 TELEGRAM으로 접수하세요. 별도 결제·환불 조건은 해당 기능의 실제 제공 전에 고지해야 합니다. 이 초안의 열람만으로 새로운 약관 동의를 처리하지 않습니다.''',
  '개인정보처리방침': '''ORQUBE 개인정보처리방침 — 개발용 안내 초안
작성일: 2026년 10월 2일

1. 처리 목적과 항목
계정 인증과 서비스 운영을 위해 로그인 제공자에 따른 UID, 이메일, 표시 이름, 전화번호 및 프로필 정보를 처리할 수 있습니다. 참여·채굴·출석·광고 보상·커뮤니티 이용 시 이용 기록, 보상 기록, 게시물, 지갑 주소 및 거래 식별자가 처리될 수 있습니다. 방문 통계에는 설치 식별자, 접속 시각과 플랫폼 정보가 사용됩니다.

2. 위치와 선택 기능
안심귀가·안전산행 기능의 위치 정보는 기기 권한과 해당 기능의 이용 설정에 따라 처리됩니다. 기능 이용 전 위치 권한과 공유 대상을 확인하세요. 불필요한 주민등록번호, 지갑 개인키 또는 복구 문구를 게시물·AI 입력에 넣지 마세요.

3. 인증·외부 서비스
Firebase/Google 인증·데이터 저장과 Google 광고 서비스가 사용됩니다. 문자 인증 시 전화번호는 인증 및 스팸·악용 방지를 위해 Google/Firebase에 전달됩니다. AI 기능에 입력한 내용은 실제 연결된 AI 제공자로 전송될 수 있습니다. 광고·인증 과정에서 쿠키나 기기 식별자가 사용될 수 있으므로 브라우저·기기 설정을 확인하세요.

4. 보관·파기와 블록체인
개인정보는 처리 목적과 관련 법령에 필요한 기간에 한해 보관하는 것을 원칙으로 합니다. 구체적인 보관 기간과 삭제 절차는 공개 운영 전 확정해야 합니다. 공개 블록체인에 기록된 지갑 주소·거래는 기술적 특성상 서비스에서 삭제하거나 수정할 수 없을 수 있습니다.

5. 이용자의 권리
본인 정보의 열람·정정·삭제·계정 탈퇴 및 선택적 처리 중단 요청은 공식 FAQ & HELP 또는 TELEGRAM으로 접수할 수 있습니다. 본인 확인 후 관련 법령에 따라 처리해야 하며, 위치 권한은 기기 설정에서 철회할 수 있습니다.

6. 보호 조치와 공개 전 확인
인증과 접근 권한 규칙으로 정보를 보호합니다. 공개 운영 전 개인정보처리자 명칭·주소, 담당자 연락처, 실제 위탁업체와 국외 이전 국가·항목·시기·방법·보관기간, 법적 처리 근거, 보유기간, 아동 이용 기준을 운영자가 확인하여 고지해야 합니다. 확인되지 않은 세부 내용을 이 초안에서 확정된 사실로 안내하지 않습니다.''',
};

class LegalFooter extends StatelessWidget {
  const LegalFooter({super.key});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    const Text('© 2026 ORQUBE', style: TextStyle(color: Colors.white54, fontSize: 12)),
    Wrap(alignment: WrapAlignment.center, spacing: 4, runSpacing: 2, children: [
      for (final title in _legalDocuments.keys)
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => LegalInformationPage(title: title))),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, height: 1.4)),
        ),
    ]),
  ]);
}

class LegalInformationPage extends StatelessWidget {
  const LegalInformationPage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF101124),
    appBar: AppBar(title: Text(title), foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF101124)),
    body: SafeArea(child: SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 18 : 32),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 850),
        child: SelectableText(_legalDocuments[title] ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.65)))),
    )),
  );
}
