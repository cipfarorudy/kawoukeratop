# 🚀 Script de déploiement Azure pour Kawoukeravore
# Usage: .\azure-deploy.ps1 [-Environment prod|staging] [-ResourceGroup nom]

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("prod", "staging")]
    [string]$Environment = "prod",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "kawoukeravore-rg-$Environment",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "West Europe",
    
    [Parameter(Mandatory=$false)]
    [switch]$InfrastructureOnly,
    
    [Parameter(Mandatory=$false)]
    [switch]$AppOnly,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild
)

# Configuration
$ProjectName = "kawoukeravore"
$SubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$BicepTemplate = "./azure-infrastructure.bicep"
$ParametersFile = "./azure-infrastructure.parameters.json"

# Couleurs PowerShell
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    
    if ($args) {
        Write-Output $args
    } else {
        $input | Write-Output
    }
    
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Info($message) { Write-ColorOutput Green "ℹ️  $message" }
function Write-Warning($message) { Write-ColorOutput Yellow "⚠️  $message" }
function Write-Error($message) { Write-ColorOutput Red "❌ $message" }
function Write-Success($message) { Write-ColorOutput Green "✅ $message" }
function Write-Step($message) { Write-ColorOutput Cyan "🔄 $message" }

Write-Info "🌴 Démarrage du déploiement Kawoukeravore sur Azure"
Write-Info "📍 Environnement: $Environment"
Write-Info "📦 Resource Group: $ResourceGroup"
Write-Info "🌍 Région: $Location"
Write-Host ""

# Vérification des prérequis
Write-Step "Vérification des prérequis Azure..."

try {
    # Vérifier Azure CLI
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Info "✅ Azure CLI version: $($azVersion.'azure-cli')"
} catch {
    Write-Error "Azure CLI n'est pas installé. Installez-le depuis: https://aka.ms/installazurecliwindows"
    exit 1
}

try {
    # Vérifier la connexion Azure
    $account = az account show --output json | ConvertFrom-Json
    Write-Info "✅ Connecté à Azure: $($account.user.name)"
    Write-Info "📋 Subscription: $($account.name) ($($account.id))"
} catch {
    Write-Error "Non connecté à Azure. Exécutez: az login"
    exit 1
}

# Vérifier Node.js
try {
    $nodeVersion = node --version
    Write-Info "✅ Node.js version: $nodeVersion"
} catch {
    Write-Error "Node.js n'est pas installé"
    exit 1
}

# Vérifier npm
try {
    $npmVersion = npm --version
    Write-Info "✅ npm version: $npmVersion"
} catch {
    Write-Error "npm n'est pas disponible"
    exit 1
}

Write-Success "Prérequis validés"
Write-Host ""

# Build de l'application (si pas skip)
if (-not $SkipBuild -and -not $InfrastructureOnly) {
    Write-Step "Build de l'application Kawoukeravore..."
    
    Write-Info "📦 Installation des dépendances..."
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Échec de l'installation des dépendances"
        exit 1
    }
    
    Write-Info "🏗️ Build du frontend React..."
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Échec du build frontend"
        exit 1
    }
    
    Write-Success "Build terminé avec succès"
    Write-Host ""
}

# Création du Resource Group
Write-Step "Création/Vérification du Resource Group..."
$rgExists = az group exists --name $ResourceGroup
if ($rgExists -eq "false") {
    Write-Info "Création du Resource Group: $ResourceGroup"
    az group create --name $ResourceGroup --location $Location --tags Environment=$Environment Project=$ProjectName
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Échec de la création du Resource Group"
        exit 1
    }
} else {
    Write-Info "Resource Group existant: $ResourceGroup"
}

# Déploiement de l'infrastructure (si pas AppOnly)
if (-not $AppOnly) {
    Write-Step "Déploiement de l'infrastructure Azure avec Bicep..."
    
    # Mise à jour des paramètres
    $parameters = Get-Content $ParametersFile | ConvertFrom-Json
    $parameters.parameters.environment.value = $Environment
    $parameters.parameters.location.value = $Location
    $parameters | ConvertTo-Json -Depth 10 | Set-Content $ParametersFile
    
    Write-Info "🚀 Déploiement du template Bicep..."
    $deployment = az deployment group create `
        --resource-group $ResourceGroup `
        --template-file $BicepTemplate `
        --parameters $ParametersFile `
        --output json | ConvertFrom-Json
        
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Échec du déploiement de l'infrastructure"
        exit 1
    }
    
    # Récupérer les outputs
    $webAppName = $deployment.properties.outputs.webAppName.value
    $staticWebAppName = $deployment.properties.outputs.staticWebAppName.value
    $webAppUrl = $deployment.properties.outputs.webAppUrl.value
    $staticWebAppUrl = $deployment.properties.outputs.staticWebAppUrl.value
    
    Write-Success "Infrastructure déployée avec succès"
    Write-Info "🔧 Web App: $webAppName"
    Write-Info "🌐 Static Web App: $staticWebAppName"
    Write-Host ""
}

# Déploiement de l'application (si pas InfrastructureOnly)
if (-not $InfrastructureOnly) {
    # Récupérer les noms des ressources si pas déjà fait
    if (-not $webAppName) {
        $webAppName = "$ProjectName-api-$Environment"
        $staticWebAppName = "$ProjectName-frontend-$Environment"
    }
    
    Write-Step "Déploiement de l'API sur App Service..."
    
    # Préparer le package API
    Write-Info "📦 Préparation du package API..."
    $tempDir = "temp-deploy-api"
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
    
    Copy-Item "apps/api" $tempDir -Recurse
    Push-Location $tempDir
    
    # Installation des dépendances de production
    Write-Info "📦 Installation des dépendances de production..."
    npm ci --production
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Échec de l'installation des dépendances de production"
        Pop-Location
        exit 1
    }
    
    Pop-Location
    
    # Déploiement sur App Service
    Write-Info "🚀 Déploiement vers App Service: $webAppName"
    az webapp deployment source config-zip `
        --resource-group $ResourceGroup `
        --name $webAppName `
        --src "$tempDir.zip"
        
    # Créer le zip
    Compress-Archive -Path "$tempDir/*" -DestinationPath "$tempDir.zip" -Force
    
    # Deploy
    az webapp deployment source config-zip `
        --resource-group $ResourceGroup `
        --name $webAppName `
        --src "$tempDir.zip"
        
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Échec du déploiement de l'API"
        exit 1
    }
    
    # Nettoyage
    Remove-Item $tempDir -Recurse -Force
    Remove-Item "$tempDir.zip" -Force
    
    Write-Success "API déployée avec succès"
    Write-Host ""
}

# Tests de santé
Write-Step "Tests de santé des services..."

if ($webAppUrl) {
    Write-Info "🔍 Test de l'API..."
    try {
        $response = Invoke-RestMethod -Uri "$webAppUrl/api/health" -TimeoutSec 30
        Write-Success "✅ API opérationnelle"
    } catch {
        Write-Warning "⚠️  API peut ne pas être encore prête"
    }
}

if ($staticWebAppUrl) {
    Write-Info "🔍 Test du frontend..."
    try {
        $response = Invoke-WebRequest -Uri $staticWebAppUrl -TimeoutSec 30
        if ($response.StatusCode -eq 200) {
            Write-Success "✅ Frontend accessible"
        }
    } catch {
        Write-Warning "⚠️  Frontend peut ne pas être encore prêt"
    }
}

# Résumé final
Write-Host ""
Write-Success "🎉 Déploiement Kawoukeravore terminé avec succès!"
Write-Host ""
Write-Info "📱 URLs de votre application:"
if ($webAppUrl) { Write-Info "   🔧 API: $webAppUrl" }
if ($staticWebAppUrl) { Write-Info "   🌐 Frontend: $staticWebAppUrl" }
Write-Host ""
Write-Info "🛠️ Gestion des ressources:"
Write-Info "   📋 Resource Group: $ResourceGroup"
Write-Info "   🌍 Région: $Location"
Write-Info "   🏷️ Environnement: $Environment"
Write-Host ""
Write-Info "📊 Commandes utiles:"
Write-Info "   az webapp log tail --name $webAppName --resource-group $ResourceGroup"
Write-Info "   az webapp browse --name $webAppName --resource-group $ResourceGroup"
Write-Host ""
Write-Info "🌴 Votre plateforme culturelle guadeloupéenne est en ligne!"