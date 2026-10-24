from pathlib import Path
p=Path('android/app/src/main/AndroidManifest.xml')
s=p.read_text()
for permission in ['INTERNET','ACCESS_FINE_LOCATION','ACCESS_COARSE_LOCATION']:
    entry=f'<uses-permission android:name="android.permission.{permission}" />'
    if entry not in s: s=s.replace('<application',entry+'\n    <application',1)
s=s.replace('android:label="orqube_safe_hiking"','android:label="ORQUBE 안전산행"')
p.write_text(s)
p=Path('ios/Runner/Info.plist')
if p.exists():
    s=p.read_text()
    if 'NSLocationWhenInUseUsageDescription' not in s:
        s=s.replace('</dict>', '<key>NSLocationWhenInUseUsageDescription</key><string>산행 위치와 이동 경로를 표시합니다.</string>\n</dict>')
    p.write_text(s)
