import 'package:flutter/material.dart';

class ExternalMarketGuidePage extends StatelessWidget {
  const ExternalMarketGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('외부 거래 준비')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: CircleAvatar(child: Text('1')),
            title: Text('Kaia 컨트랙트 확인'),
            subtitle: Text('배포 주소와 토큰 정보를 확인합니다.'),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('2')),
            title: Text('발행자 본인 지갑 확인'),
            subtitle: Text('ORQUBE가 사용자 자산을 보관하지 않는 구조를 권장합니다.'),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('3')),
            title: Text('외부 DEX 유동성 준비'),
            subtitle: Text('실제 거래는 외부 DEX 절차로 분리합니다.'),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('4')),
            title: Text('외부 시장 URL 등록'),
            subtitle: Text('검증된 외부 거래 페이지 링크만 프로젝트 페이지에 표시합니다.'),
          ),
        ],
      ),
    );
  }
}
