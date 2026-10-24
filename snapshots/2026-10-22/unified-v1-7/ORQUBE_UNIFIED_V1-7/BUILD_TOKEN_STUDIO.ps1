$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }
flutter test test/generated_kaia_wallet_test.dart
if ($LASTEXITCODE -ne 0) { throw 'Wallet backup tests failed' }
flutter build web --release
if ($LASTEXITCODE -ne 0) { throw 'Flutter web build failed' }
Write-Host 'Build completed. Test the application before deploying.'
Write-Host 'Hosting: firebase deploy --only hosting --project orqube-576e7'
Write-Host 'Studio server: firebase deploy --only "functions:ai:getPublicLaunchTokens,functions:ai:getMobileStudioPolicy" --project orqube-576e7'
