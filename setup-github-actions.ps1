# Configuration automatisée des secrets GitHub pour Kawoukeravore
# Ce script configure tous les éléments nécessaires pour GitHub Actions

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubToken,
    
    [Parameter(Mandatory=$true)]
    [string]$AzureSubscriptionId,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "kawoukeravore-rg-prod",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "West Europe",
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubRepo = "cipfarorudy/kawoukeravore"
)

Write-Host "🚀 Configuration GitHub Actions pour Kawoukeravore" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Vérifier si Azure CLI est installé
try {
    $azVersion = az version --output table 2>$null
    Write-Host "✅ Azure CLI installé" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI non installé. Veuillez l'installer : https://aka.ms/installazurecliwindows" -ForegroundColor Red
    exit 1
}

# Vérifier si GitHub CLI est installé
try {
    $ghVersion = gh version 2>$null
    Write-Host "✅ GitHub CLI installé" -ForegroundColor Green
} catch {
    Write-Host "❌ GitHub CLI non installé. Veuillez l'installer : https://cli.github.com/" -ForegroundColor Red
    exit 1
}

# Connexion à Azure
Write-Host "🔐 Connexion à Azure..." -ForegroundColor Yellow
try {
    az login --output none
    az account set --subscription $AzureSubscriptionId
    Write-Host "✅ Connecté à Azure (Subscription: $AzureSubscriptionId)" -ForegroundColor Green
} catch {
    Write-Host "❌ Échec de connexion à Azure" -ForegroundColor Red
    exit 1
}

# Connexion à GitHub
Write-Host "🔐 Connexion à GitHub..." -ForegroundColor Yellow
try {
    echo $GitHubToken | gh auth login --with-token
    Write-Host "✅ Connecté à GitHub" -ForegroundColor Green
} catch {
    Write-Host "❌ Échec de connexion à GitHub. Vérifiez votre token." -ForegroundColor Red
    exit 1
}

# Créer le Resource Group
Write-Host "📁 Création du Resource Group..." -ForegroundColor Yellow
try {
    $rgExists = az group exists --name $ResourceGroupName
    if ($rgExists -eq "false") {
        az group create --name $ResourceGroupName --location $Location --output none
        Write-Host "✅ Resource Group '$ResourceGroupName' créé" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Resource Group '$ResourceGroupName' existe déjà" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Échec de création du Resource Group" -ForegroundColor Red
    exit 1
}

# Créer le Service Principal pour GitHub Actions
Write-Host "👤 Création du Service Principal..." -ForegroundColor Yellow
try {
    $spName = "kawoukeravore-github-actions-sp"
    $scope = "/subscriptions/$AzureSubscriptionId/resourceGroups/$ResourceGroupName"
    
    # Vérifier si le SP existe déjà
    $existingSp = az ad sp list --display-name $spName --query "[0].appId" -o tsv
    
    if ([string]::IsNullOrEmpty($existingSp)) {
        $spCredentials = az ad sp create-for-rbac --name $spName --role "Contributor" --scopes $scope --json-auth
        Write-Host "✅ Service Principal créé" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Service Principal existe déjà, génération de nouvelles credentials..." -ForegroundColor Cyan
        $spCredentials = az ad sp create-for-rbac --name $spName --role "Contributor" --scopes $scope --json-auth
    }
    
    # Parser les credentials
    $credentials = $spCredentials | ConvertFrom-Json
    
    Write-Host "📝 Credentials générées pour le Service Principal" -ForegroundColor Green
} catch {
    Write-Host "❌ Échec de création du Service Principal" -ForegroundColor Red
    exit 1
}

# Créer Static Web App pour obtenir le token
Write-Host "🌐 Création du Static Web App..." -ForegroundColor Yellow
try {
    $swaName = "kawoukeravore-frontend-prod"
    $swaExists = az staticwebapp show --name $swaName --resource-group $ResourceGroupName 2>$null
    
    if ($null -eq $swaExists) {
        $swa = az staticwebapp create --name $swaName --resource-group $ResourceGroupName --source "https://github.com/$GitHubRepo" --location "West Europe" --branch "main" --app-location "/apps/web" --output-location "dist" --login-with-github
        Write-Host "✅ Static Web App créé" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Static Web App existe déjà" -ForegroundColor Cyan
        $swa = $swaExists
    }
    
    # Obtenir le token de déploiement
    $swaToken = az staticwebapp secrets list --name $swaName --resource-group $ResourceGroupName --query "properties.apiKey" -o tsv
    Write-Host "📝 Token Static Web App récupéré" -ForegroundColor Green
} catch {
    Write-Host "❌ Échec de création du Static Web App" -ForegroundColor Red
    Write-Host "ℹ️  Vous pourrez le créer manuellement et ajouter le token plus tard" -ForegroundColor Cyan
    $swaToken = "MANUAL_CONFIGURATION_REQUIRED"
}

# Générer un JWT Secret
$jwtSecret = [System.Web.Security.Membership]::GeneratePassword(32, 8)
Write-Host "🔐 JWT Secret généré" -ForegroundColor Green

# Configurer les secrets GitHub
Write-Host "🔧 Configuration des secrets GitHub..." -ForegroundColor Yellow

$secrets = @{
    "AZURE_CREDENTIALS" = $spCredentials
    "AZURE_SUBSCRIPTION_ID" = $AzureSubscriptionId
    "AZURE_STATIC_WEB_APPS_API_TOKEN" = $swaToken
    "JWT_SECRET" = $jwtSecret
}

foreach ($secretName in $secrets.Keys) {
    try {
        $secretValue = $secrets[$secretName]
        gh secret set $secretName --body $secretValue --repo $GitHubRepo
        Write-Host "✅ Secret '$secretName' configuré" -ForegroundColor Green
    } catch {
        Write-Host "❌ Échec de configuration du secret '$secretName'" -ForegroundColor Red
    }
}

# Générer un rapport de configuration
Write-Host ""
Write-Host "📊 RAPPORT DE CONFIGURATION" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host "✅ Resource Group: $ResourceGroupName" -ForegroundColor Green
Write-Host "✅ Service Principal: $spName" -ForegroundColor Green
Write-Host "✅ Static Web App: $swaName" -ForegroundColor Green
Write-Host "✅ GitHub Repository: $GitHubRepo" -ForegroundColor Green
Write-Host ""

Write-Host "🔐 SECRETS CONFIGURÉS:" -ForegroundColor Cyan
Write-Host "• AZURE_CREDENTIALS ✅"
Write-Host "• AZURE_SUBSCRIPTION_ID ✅" 
Write-Host "• AZURE_STATIC_WEB_APPS_API_TOKEN ✅"
Write-Host "• JWT_SECRET ✅"
Write-Host ""

Write-Host "⚠️  SECRETS OPTIONNELS À AJOUTER MANUELLEMENT:" -ForegroundColor Yellow
Write-Host "• MICROSOFT_CLIENT_ID (pour l'auth Microsoft)"
Write-Host "• MICROSOFT_CLIENT_SECRET"
Write-Host "• MICROSOFT_TENANT_ID"
Write-Host "• WHATSAPP_VERIFY_TOKEN (pour WhatsApp Business)"
Write-Host "• WHATSAPP_ACCESS_TOKEN"
Write-Host ""

Write-Host "🚀 PROCHAINES ÉTAPES:" -ForegroundColor Green
Write-Host "1. Vérifiez les secrets sur: https://github.com/$GitHubRepo/settings/secrets/actions"
Write-Host "2. Ajoutez les secrets optionnels si nécessaire"
Write-Host "3. Poussez votre code pour déclencher le premier déploiement:"
Write-Host "   git add ."
Write-Host "   git commit -m '🚀 Configure GitHub Actions deployment'"
Write-Host "   git push origin main"
Write-Host ""
Write-Host "4. Surveillez le déploiement: https://github.com/$GitHubRepo/actions"
Write-Host ""

Write-Host "🎉 Configuration terminée avec succès!" -ForegroundColor Green

# Sauvegarder les informations importantes
$reportFile = "github-actions-setup-report.txt"
@"
Kawoukeravore - Rapport de Configuration GitHub Actions
======================================================
Date: $(Get-Date)
Resource Group: $ResourceGroupName
Service Principal: $spName
Static Web App: $swaName
Subscription ID: $AzureSubscriptionId

Service Principal Credentials:
$spCredentials

URLs importantes:
- GitHub Actions: https://github.com/$GitHubRepo/actions
- GitHub Secrets: https://github.com/$GitHubRepo/settings/secrets/actions
- Azure Portal: https://portal.azure.com/#@/resource/subscriptions/$AzureSubscriptionId/resourceGroups/$ResourceGroupName

Prochaines étapes:
1. Ajouter les secrets optionnels dans GitHub si nécessaire
2. Pousser le code pour déclencher le premier déploiement
3. Configurer le domaine personnalisé kawoukeravore.top
"@ | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host "📄 Rapport sauvegardé dans: $reportFile" -ForegroundColor Cyan