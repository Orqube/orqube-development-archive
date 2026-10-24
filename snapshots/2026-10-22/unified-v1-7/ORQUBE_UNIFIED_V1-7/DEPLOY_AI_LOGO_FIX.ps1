$ErrorActionPreference = 'Stop'

Write-Host ''
Write-Host '==============================================' -ForegroundColor Cyan
Write-Host ' ORQUBE AI LOGO - Firebase Functions deploy' -ForegroundColor Cyan
Write-Host '==============================================' -ForegroundColor Cyan
Write-Host ''

if (-not (Test-Path '.firebaserc')) {
  Write-Host '[ERROR] Run this script from the ORQUBE_SAFE_HIKING project root.' -ForegroundColor Red
  exit 1
}
if (-not (Test-Path 'firebase.json')) {
  Write-Host '[ERROR] firebase.json was not found.' -ForegroundColor Red
  exit 1
}
if (-not (Test-Path 'functions_ai/index.js')) {
  Write-Host '[ERROR] functions_ai/index.js was not found.' -ForegroundColor Red
  exit 1
}

$firebase = Get-Command firebase -ErrorAction SilentlyContinue
if (-not $firebase) {
  Write-Host '[ERROR] Firebase CLI is not installed or not in PATH.' -ForegroundColor Red
  Write-Host 'Install it first: npm install -g firebase-tools'
  exit 1
}

Write-Host '[1/6] Firebase login/project check...' -ForegroundColor Yellow
firebase use
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ''
Write-Host '[2/6] AI Functions source syntax check...' -ForegroundColor Yellow
Push-Location 'functions_ai'
try {
  if (-not (Test-Path 'node_modules')) {
    Write-Host 'Installing functions_ai dependencies...'
    npm install
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }
  npm run check
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
finally {
  Pop-Location
}

Write-Host ''
Write-Host '[3/6] OPENAI_API_KEY secret check...' -ForegroundColor Yellow
$secretList = firebase functions:secrets:access OPENAI_API_KEY 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Host 'OPENAI_API_KEY is not set yet.' -ForegroundColor Yellow
  Write-Host 'Firebase will now ask for the key securely. The key is NOT written to this file.' -ForegroundColor Yellow
  firebase functions:secrets:set OPENAI_API_KEY
  if ($LASTEXITCODE -ne 0) {
    Write-Host '[ERROR] OPENAI_API_KEY setup was cancelled or failed.' -ForegroundColor Red
    exit $LASTEXITCODE
  }
} else {
  Write-Host 'OPENAI_API_KEY secret exists.' -ForegroundColor Green
}

Write-Host ''
Write-Host '[4/6] Deploying ONLY AI Functions codebase...' -ForegroundColor Yellow
firebase deploy --only functions:ai
if ($LASTEXITCODE -ne 0) {
  Write-Host '[ERROR] AI Functions deployment failed. Please send the last error screen.' -ForegroundColor Red
  exit $LASTEXITCODE
}

Write-Host ''
Write-Host '[5/6] Checking deployed functions...' -ForegroundColor Yellow
firebase functions:list
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ''
Write-Host '[6/6] Done.' -ForegroundColor Green
Write-Host 'Expected function: generateLaunchLogoOptions (asia-northeast3)'
Write-Host 'Then run: flutter run -d chrome'
Write-Host 'Login -> AI Token Creator -> Generate AI Logo'
Write-Host ''
