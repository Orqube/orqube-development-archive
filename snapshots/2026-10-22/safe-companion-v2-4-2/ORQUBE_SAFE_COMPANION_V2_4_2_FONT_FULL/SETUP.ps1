$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
flutter create --platforms=android,ios,web --org com.orqube --project-name orqube_safe_hiking .
if ($LASTEXITCODE -ne 0) { throw 'Flutter 프로젝트 생성 실패' }
python configure_permissions.py
if ($LASTEXITCODE -ne 0) { throw '권한 설정 실패' }
flutter pub get
