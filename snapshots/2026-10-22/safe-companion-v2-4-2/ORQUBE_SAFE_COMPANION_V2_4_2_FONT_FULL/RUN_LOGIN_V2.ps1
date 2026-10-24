$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
Write-Host 'ORQUBE SAFE HIKING - LOGIN UI V2'
if (-not (Test-Path 'pubspec.yaml')) { throw '앱 프로젝트 폴더가 아닙니다.' }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw '패키지 설치 실패: 위 오류 내용을 확인해주세요.' }
flutter run -d chrome --web-port=7352
if ($LASTEXITCODE -ne 0) { throw '앱 실행 실패: 위 오류 내용을 확인해주세요.' }
