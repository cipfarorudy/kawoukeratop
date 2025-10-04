# Configuration Azure AD pour kawoukeravore.onmicrosoft.com
# Version simplifiée pour éviter les problèmes d'échappement

Write-Host "Configuration Azure AD pour kawoukeravore.onmicrosoft.com" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. Obtenir les informations du tenant actuel
Write-Host "`n1. Vérification du tenant Azure..." -ForegroundColor Yellow
try {
    $tenantInfo = az account show --output json | ConvertFrom-Json
    $tenantId = $tenantInfo.tenantId
    $userName = $tenantInfo.user.name
    
    Write-Host "Tenant ID actuel: $tenantId" -ForegroundColor Green
    Write-Host "Utilisateur connecté: $userName" -ForegroundColor Gray
} catch {
    Write-Host "Erreur: Vous devez être connecté à Azure (az login)" -ForegroundColor Red
    exit 1
}

# 2. Créer l'App Registration
Write-Host "`n2. Création de l'App Registration..." -ForegroundColor Yellow
$appName = "kawoukeravore-graph-api"

try {
    # Vérifier si l'app existe
    $existingApp = az ad app list --display-name $appName --output json | ConvertFrom-Json
    
    if ($existingApp -and $existingApp.Count -gt 0) {
        Write-Host "App Registration existe déjà" -ForegroundColor Green
        $appId = $existingApp[0].appId
    } else {
        Write-Host "Création d'une nouvelle App Registration..." -ForegroundColor Cyan
        $newApp = az ad app create --display-name $appName --output json | ConvertFrom-Json
        $appId = $newApp.appId
        Write-Host "App Registration créée avec succès" -ForegroundColor Green
    }
    
    Write-Host "App ID (Client ID): $appId" -ForegroundColor White
} catch {
    Write-Host "Erreur lors de la création de l'App Registration" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 3. Créer un secret client
Write-Host "`n3. Génération du secret client..." -ForegroundColor Yellow
try {
    $secretDisplayName = "kawoukeravore-secret-2025"
    $clientSecret = az ad app credential reset --id $appId --display-name $secretDisplayName --query password --output tsv
    
    Write-Host "Secret client généré avec succès" -ForegroundColor Green
    Write-Host "ATTENTION: Sauvegardez ce secret maintenant!" -ForegroundColor Yellow
} catch {
    Write-Host "Erreur lors de la génération du secret" -ForegroundColor Red
    exit 1
}

# 4. Résumé et instructions
Write-Host "`n🎯 CONFIGURATION TERMINÉE" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""
Write-Host "Variables à configurer dans GitHub Secrets:" -ForegroundColor Cyan
Write-Host "Repository: https://github.com/cipfarorudy/kawoukeratop/settings/secrets/actions"
Write-Host ""
Write-Host "MICROSOFT_TENANT_ID:"
Write-Host $tenantId -ForegroundColor White
Write-Host ""
Write-Host "MICROSOFT_CLIENT_ID:"
Write-Host $appId -ForegroundColor White
Write-Host ""
Write-Host "MICROSOFT_CLIENT_SECRET:"
Write-Host $clientSecret -ForegroundColor White
Write-Host ""
Write-Host "Prochaines étapes:" -ForegroundColor Yellow
Write-Host "1. Ajouter ces secrets dans GitHub" -ForegroundColor Gray
Write-Host "2. Configurer les permissions Microsoft Graph dans Azure Portal" -ForegroundColor Gray
Write-Host "3. Tester la connexion" -ForegroundColor Gray
Write-Host ""
Write-Host "URL Azure Portal pour configurer les permissions:"
Write-Host "https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnApi/appId/$appId"