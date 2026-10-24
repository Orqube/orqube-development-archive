$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed" }
flutter build web --release
if ($LASTEXITCODE -ne 0) { throw "Web build failed" }
firebase deploy --project orqube-576e7 --only "functions:sharedAuthToken,hosting"
if ($LASTEXITCODE -ne 0) { throw "Deployment failed; inspect the Firebase output" }
Write-Host "ORQUBE web and shared login token bridge deployed."
