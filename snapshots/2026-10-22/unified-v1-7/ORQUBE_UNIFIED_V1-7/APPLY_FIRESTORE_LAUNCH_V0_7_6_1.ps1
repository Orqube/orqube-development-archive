$ErrorActionPreference = "Stop"

$rulesPath = Join-Path (Get-Location) "firestore.rules"
$blockPath = Join-Path (Get-Location) "FIRESTORE_V0_7_6_1_RULES_BLOCK.txt"

if (-not (Test-Path $rulesPath)) {
    Write-Host "[ERROR] firestore.rules not found in current folder." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $blockPath)) {
    Write-Host "[ERROR] FIRESTORE_V0_7_6_1_RULES_BLOCK.txt not found." -ForegroundColor Red
    exit 1
}

$text = [System.IO.File]::ReadAllText($rulesPath)
$block = [System.IO.File]::ReadAllText($blockPath)

if ($text -notmatch "service\s+cloud\.firestore") {
    Write-Host "[ERROR] This does not look like a Firestore rules file." -ForegroundColor Red
    exit 1
}

if ($text -match "ORQUBE AI LAUNCH V0\.7\.6") {
    Write-Host "[OK] ORQUBE AI Launch rules are already present. No duplicate insert." -ForegroundColor Green
    exit 0
}

$clean = $text.TrimEnd()
$lastBrace = $clean.LastIndexOf("}")

if ($lastBrace -lt 0) {
    Write-Host "[ERROR] Final closing brace was not found." -ForegroundColor Red
    exit 1
}

$secondLastBrace = $clean.LastIndexOf("}", $lastBrace - 1)

if ($secondLastBrace -lt 0) {
    Write-Host "[ERROR] Database closing brace was not found." -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "$rulesPath.backup_$timestamp"
Copy-Item $rulesPath $backup -Force

$before = $clean.Substring(0, $secondLastBrace)
$after = $clean.Substring($secondLastBrace)

$newText = $before.TrimEnd() + "`r`n`r`n" + $block.Trim() + "`r`n`r`n" + $after + "`r`n"

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($rulesPath, $newText, $utf8NoBom)

Write-Host ""
Write-Host "[OK] ORQUBE AI Launch V0.7.6.1 rules inserted." -ForegroundColor Green
Write-Host "[BACKUP] $backup" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next command:" -ForegroundColor Yellow
Write-Host "firebase deploy --only firestore:rules" -ForegroundColor White
