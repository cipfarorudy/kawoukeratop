# Script de verification du deploiement kawoukeratop

Write-Host "Verification du deploiement kawoukeratop" -ForegroundColor Cyan

# URLs a tester
$frontendUrl = "https://kawoukeravore-frontend-prod.azurestaticapps.net"
$apiUrl = "https://kawoukeravore-api-prod.azurewebsites.net"
$healthUrl = "$apiUrl/api/health"

Write-Host "`n📱 Test du Frontend..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri $frontendUrl -Method GET -TimeoutSec 10
    if ($frontendResponse.StatusCode -eq 200) {
        Write-Host "✅ Frontend accessible sur $frontendUrl" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Frontend non accessible: $_" -ForegroundColor Red
}

Write-Host "`n🔧 Test de l'API..." -ForegroundColor Yellow
try {
    $apiResponse = Invoke-RestMethod -Uri $healthUrl -Method GET -TimeoutSec 10
    Write-Host "✅ API accessible sur $healthUrl" -ForegroundColor Green
    Write-Host "📊 Réponse de l'API:" -ForegroundColor Cyan
    $apiResponse | ConvertTo-Json -Depth 2
} catch {
    Write-Host "❌ API non accessible: $_" -ForegroundColor Red
}

Write-Host "`n🌐 Test du domaine personnalisé..." -ForegroundColor Yellow
try {
    $domainResponse = Invoke-WebRequest -Uri "https://kawoukeravore.top" -Method GET -TimeoutSec 10
    if ($domainResponse.StatusCode -eq 200) {
        Write-Host "✅ Domaine kawoukeravore.top accessible" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️ Domaine kawoukeravore.top non encore configuré: $_" -ForegroundColor Yellow
}

Write-Host "`n📋 Liens utiles:" -ForegroundColor Magenta
Write-Host "🌐 Frontend: $frontendUrl" -ForegroundColor Blue
Write-Host "🔧 API: $apiUrl" -ForegroundColor Blue
Write-Host "📊 Health Check: $healthUrl" -ForegroundColor Blue
Write-Host "🏗️ GitHub Actions: https://github.com/cipfarorudy/kawoukeratop/actions" -ForegroundColor Blue

Write-Host "`n✅ Vérification terminée" -ForegroundColor Green