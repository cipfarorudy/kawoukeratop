# Script pour configurer les secrets GitHub avec les informations Azure AD
# Repository: kawoukeratop

$tenantId = "eb99c72c-deb5-4c55-8568-7498a26dc050"
$clientId = "f4234307-755a-4f6d-8e0f-7f8bc792f80d" 
$clientSecret = "[REMPLACE_WITH_ACTUAL_SECRET_FROM_AZURE_AD_SCRIPT]"
$repo = "cipfarorudy/kawoukeratop"

Write-Host "Configuration des secrets GitHub pour $repo" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Vérifier si gh CLI est disponible
$ghAvailable = $false
try {
    $ghVersion = gh --version 2>$null
    if ($ghVersion) {
        $ghAvailable = $true
        Write-Host "GitHub CLI détecté" -ForegroundColor Green
    }
} catch {
    Write-Host "GitHub CLI non disponible" -ForegroundColor Yellow
}

if ($ghAvailable) {
    Write-Host "`nConfiguration automatique des secrets..." -ForegroundColor Yellow
    
    try {
        gh secret set MICROSOFT_TENANT_ID --body $tenantId --repo $repo
        Write-Host "✅ MICROSOFT_TENANT_ID configuré" -ForegroundColor Green
        
        gh secret set MICROSOFT_CLIENT_ID --body $clientId --repo $repo  
        Write-Host "✅ MICROSOFT_CLIENT_ID configuré" -ForegroundColor Green
        
        gh secret set MICROSOFT_CLIENT_SECRET --body $clientSecret --repo $repo
        Write-Host "✅ MICROSOFT_CLIENT_SECRET configuré" -ForegroundColor Green
        
        Write-Host "`n🎉 Tous les secrets Microsoft ont été configurés!" -ForegroundColor Green
        
    } catch {
        Write-Host "❌ Erreur lors de la configuration des secrets" -ForegroundColor Red
        Write-Host "Vérifiez que vous êtes connecté à GitHub: gh auth status" -ForegroundColor Yellow
        $ghAvailable = $false
    }
}

if (-not $ghAvailable) {
    Write-Host "`nConfiguration manuelle requise:" -ForegroundColor Yellow
    Write-Host "Allez sur: https://github.com/$repo/settings/secrets/actions" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ajoutez ces secrets:" -ForegroundColor White
    Write-Host "--------------------"
    Write-Host "MICROSOFT_TENANT_ID:" -ForegroundColor Yellow
    Write-Host $tenantId -ForegroundColor White
    Write-Host ""
    Write-Host "MICROSOFT_CLIENT_ID:" -ForegroundColor Yellow  
    Write-Host $clientId -ForegroundColor White
    Write-Host ""
    Write-Host "MICROSOFT_CLIENT_SECRET:" -ForegroundColor Yellow
    Write-Host $clientSecret -ForegroundColor White
}

Write-Host "`nProchaine étape: Tester le déploiement" -ForegroundColor Cyan
Write-Host "Redéploiement automatique après configuration des secrets" -ForegroundColor Gray