$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
flutter pub get
if ($LASTEXITCODE -ne 0) { throw '의존성 설치 실패' }
flutter analyze
if ($LASTEXITCODE -ne 0) { throw '분석 결과를 확인하세요' }
flutter run -d chrome --web-port=7354
