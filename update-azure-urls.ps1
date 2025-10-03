# Script de mise à jour des URLs Azure - kawoukeratop
# Remplace toutes les références à l'ancienne URL par la nouvelle

$oldUrl = "kawoukeravore-api-prod"
$newUrl = "kawoukeraotop-erh8hzcxhwawhtb7"
$oldDomain = "kawoukeravore-api-prod.azurewebsites.net"
$newDomain = "kawoukeraotop-erh8hzcxhwawhtb7.westus3-01.azurewebsites.net"

Write-Host "🔄 Mise à jour des URLs Azure..." -ForegroundColor Cyan
Write-Host "De: $oldDomain" -ForegroundColor Red
Write-Host "Vers: $newDomain" -ForegroundColor Green

# Liste des fichiers à mettre à jour
$filesToUpdate = @(
    "verify-kawoukeratop-deployment.ps1",
    "KAWOUKERATOP-SECRETS.md",
    "QUICK-SETUP-KAWOUKERATOP.md",
    "RAPPORT-STATUT-FINAL.md"
)

foreach ($file in $filesToUpdate) {
    if (Test-Path $file) {
        Write-Host "📝 Mise à jour: $file" -ForegroundColor Yellow
        
        # Lire le contenu
        $content = Get-Content $file -Raw
        
        # Remplacer les URLs
        $content = $content -replace [regex]::Escape($oldDomain), $newDomain
        $content = $content -replace [regex]::Escape($oldUrl), $newUrl
        
        # Écrire le contenu mis à jour
        $content | Set-Content $file -NoNewline
        
        Write-Host "✅ $file mis à jour" -ForegroundColor Green
    } else {
        Write-Host "⚠️ $file introuvable" -ForegroundColor Yellow
    }
}

Write-Host "🎉 Mise à jour terminée!" -ForegroundColor Green
Write-Host "🌐 Nouvelle URL: https://$newDomain" -ForegroundColor Cyan