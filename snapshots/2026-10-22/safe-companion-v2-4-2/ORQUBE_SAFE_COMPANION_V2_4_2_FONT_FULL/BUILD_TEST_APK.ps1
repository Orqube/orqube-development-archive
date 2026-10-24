$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed' }
flutter analyze --no-fatal-infos --no-fatal-warnings
if ($LASTEXITCODE -ne 0) { throw 'Fix analyzer errors before building' }
flutter test
if ($LASTEXITCODE -ne 0) { throw 'UI tests failed' }
flutter build apk --debug
if ($LASTEXITCODE -ne 0) { throw 'APK build failed' }
Copy-Item -LiteralPath 'build\app\outputs\flutter-apk\app-debug.apk' -Destination 'ORQUBE_SAFE_V2_4_2_TEST.apk' -Force
Write-Host 'Test APK ready: ORQUBE_SAFE_V2_4_2_TEST.apk'
Write-Host 'Install this test APK on an Android device; this is not a Play Store release.'
