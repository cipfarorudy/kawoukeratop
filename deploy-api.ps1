# Script PowerShell pour déployer l'API Kawoukeravore avec PM2
# Usage: .\deploy-api.ps1

param(
    [string]$Environment = "production"
)

Write-Host "🚀 Déploiement de l'API Kawoukeravore en $Environment..." -ForegroundColor Green

# Variables
$ApiDir = "C:\Users\CIP FARO\kawoukeravore\apps\api"
$AppName = "kawou-api"
$Port = 4000
$NodeEnv = $Environment

# Fonction de log
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Color = switch ($Level) {
        "INFO" { "Green" }
        "WARN" { "Yellow" }
        "ERROR" { "Red" }
        default { "White" }
    }
    Write-Host "[$Level] $Message" -ForegroundColor $Color
}

# Vérification de PM2
try {
    pm2 --version | Out-Null
    Write-Log "PM2 est installé" "INFO"
} catch {
    Write-Log "PM2 n'est pas installé. Installation..." "WARN"
    npm install -g pm2
}

# Navigation vers le répertoire API
if (-not (Test-Path $ApiDir)) {
    Write-Log "Répertoire API non trouvé: $ApiDir" "ERROR"
    exit 1
}

Write-Log "Navigation vers $ApiDir" "INFO"
Set-Location $ApiDir

# Vérification du fichier .env
$envFile = if ($Environment -eq "production") { ".env.production" } else { ".env" }
if (-not (Test-Path $envFile)) {
    Write-Log "Fichier $envFile manquant" "WARN"
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" $envFile
        Write-Log "⚠️  Configurez les variables dans $envFile" "WARN"
    } else {
        Write-Log "Aucun fichier .env.example trouvé" "ERROR"
        exit 1
    }
}

# Installation des dépendances
Write-Log "Installation des dépendances..." "INFO"
npm install

# Arrêt de l'ancien processus
Write-Log "Arrêt de l'ancien processus $AppName..." "INFO"
try {
    pm2 delete $AppName 2>$null
} catch {
    Write-Log "Aucun processus $AppName à arrêter" "WARN"
}

# Démarrage du nouveau processus
Write-Log "Démarrage de l'API avec PM2..." "INFO"

# Définition des variables d'environnement
$env:PORT = $Port
$env:NODE_ENV = $NodeEnv

# Commande PM2
$pm2Cmd = "pm2 start src/server.js --name $AppName --time --update-env"
if ($Environment -eq "production") {
    $pm2Cmd += " --env production"
}

Write-Log "Exécution: $pm2Cmd" "INFO"
Invoke-Expression $pm2Cmd

# Vérification du démarrage
Start-Sleep -Seconds 3
$status = pm2 list | Select-String "$AppName.*online"
if ($status) {
    Write-Log "✅ API $AppName démarrée avec succès" "INFO"
} else {
    Write-Log "❌ Échec du démarrage de l'API" "ERROR"
    pm2 logs $AppName --lines 10
    exit 1
}

# Sauvegarde de la configuration PM2
Write-Log "Sauvegarde de la configuration PM2..." "INFO"
pm2 save

# Affichage du statut
Write-Log "📊 Statut de l'API:" "INFO"
pm2 status $AppName

# Test de l'API
Write-Log "🧪 Test de l'API..." "INFO"
try {
    $response = Invoke-RestMethod -Uri "http://localhost:$Port/api/health" -Method Get -TimeoutSec 5
    Write-Log "✅ API accessible sur http://localhost:$Port" "INFO"
    Write-Log "Response: $($response.message)" "INFO"
} catch {
    Write-Log "⚠️  API non accessible - vérifiez les logs" "WARN"
}

Write-Log "🎉 Déploiement terminé !" "INFO"
Write-Host ""
Write-Host "📱 Commandes utiles:" -ForegroundColor Cyan
Write-Host "  pm2 status $AppName     # Statut" -ForegroundColor White
Write-Host "  pm2 logs $AppName       # Logs" -ForegroundColor White
Write-Host "  pm2 restart $AppName    # Redémarrage" -ForegroundColor White
Write-Host "  pm2 stop $AppName       # Arrêt" -ForegroundColor White
Write-Host "  pm2 monit               # Monitoring" -ForegroundColor White