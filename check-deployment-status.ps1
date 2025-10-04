# Script de vérification du déploiement Kawoukeratop
# Date: 2025-10-03

Write-Host "🔍 Vérification du déploiement Kawoukeratop" -ForegroundColor Cyan

# Test de l'App Service
Write-Host "`n1. Test de l'App Service Azure..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://kawoukeraotop-erh8hzcxhwawhtb7.westus3-01.azurewebsites.net" -Method GET -TimeoutSec 10
    Write-Host "✅ App Service répond (Status: $($response.StatusCode))" -ForegroundColor Green
    
    # Vérifier si c'est la page par défaut Azure ou notre API
    if ($response.Content -match "Your web app is running and waiting for your content") {
        Write-Host "⚠️  Page par défaut Azure détectée - API pas encore déployée" -ForegroundColor Orange
    } elseif ($response.Content -match "<!DOCTYPE html>") {
        Write-Host "ℹ️  Page HTML détectée - vérification du type..." -ForegroundColor Blue
    } else {
        Write-Host "✅ Contenu personnalisé détecté" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ App Service inaccessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test de l'endpoint API health
Write-Host "`n2. Test de l'endpoint API /api/health..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-WebRequest -Uri "https://kawoukeraotop-erh8hzcxhwawhtb7.westus3-01.azurewebsites.net/api/health" -Method GET -TimeoutSec 10
    Write-Host "✅ API Health endpoint répond (Status: $($healthResponse.StatusCode))" -ForegroundColor Green
    Write-Host "📄 Réponse: $($healthResponse.Content)" -ForegroundColor White
} catch {
    Write-Host "❌ API Health endpoint inaccessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Informations de débogage
Write-Host "`n3. Informations de débogage..." -ForegroundColor Yellow
Write-Host "🌐 App Service URL: https://kawoukeraotop-erh8hzcxhwawhtb7.westus3-01.azurewebsites.net"
Write-Host "📂 Repository GitHub: https://github.com/cipfarorudy/kawoukeratop"
Write-Host "🔄 Actions GitHub: https://github.com/cipfarorudy/kawoukeratop/actions"

Write-Host "`n🎯 Statut du déploiement terminé!" -ForegroundColor Cyan