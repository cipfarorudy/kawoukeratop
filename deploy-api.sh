#!/bin/bash

# Script de déploiement de l'API Kawoukeravore avec PM2
# Usage: ./deploy-api.sh

echo "🚀 Déploiement de l'API Kawoukeravore en production..."

# Variables
API_DIR="/var/www/kawoukeravore/apps/api"
APP_NAME="kawou-api"
PORT=4000
NODE_ENV="production"

# Couleurs pour les logs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des prérequis
if ! command -v pm2 &> /dev/null; then
    log_error "PM2 n'est pas installé. Installation..."
    npm install -g pm2
fi

# Navigation vers le répertoire API
if [ ! -d "$API_DIR" ]; then
    log_error "Répertoire API non trouvé: $API_DIR"
    exit 1
fi

log_info "Navigation vers $API_DIR"
cd $API_DIR

# Vérification du fichier .env
if [ ! -f ".env" ]; then
    log_warn "Fichier .env manquant. Copie depuis .env.example"
    if [ -f ".env.example" ]; then
        cp .env.example .env
        log_warn "⚠️  Configurez les variables dans $API_DIR/.env"
    else
        log_error "Aucun fichier .env.example trouvé"
        exit 1
    fi
fi

# Installation des dépendances
log_info "Installation des dépendances..."
npm install --production

# Arrêt de l'ancien processus s'il existe
log_info "Arrêt de l'ancien processus $APP_NAME..."
pm2 delete $APP_NAME 2>/dev/null || log_warn "Aucun processus $APP_NAME à arrêter"

# Démarrage du nouveau processus avec les variables d'environnement
log_info "Démarrage de l'API avec PM2..."
PORT=$PORT NODE_ENV=$NODE_ENV pm2 start src/server.js \
    --name $APP_NAME \
    --time \
    --update-env \
    --env production

# Vérification du démarrage
sleep 3
if pm2 list | grep -q "$APP_NAME.*online"; then
    log_info "✅ API $APP_NAME démarrée avec succès"
else
    log_error "❌ Échec du démarrage de l'API"
    pm2 logs $APP_NAME --lines 10
    exit 1
fi

# Sauvegarde de la configuration PM2
log_info "Sauvegarde de la configuration PM2..."
pm2 save

# Affichage du statut
log_info "📊 Statut de l'API:"
pm2 status $APP_NAME

# Test de l'API
log_info "🧪 Test de l'API..."
if curl -f http://localhost:$PORT/api/health >/dev/null 2>&1; then
    log_info "✅ API accessible sur http://localhost:$PORT"
else
    log_warn "⚠️  API non accessible - vérifiez les logs"
fi

log_info "🎉 Déploiement terminé !"
log_info "📱 Commandes utiles:"
echo "  pm2 status $APP_NAME     # Statut"
echo "  pm2 logs $APP_NAME       # Logs"
echo "  pm2 restart $APP_NAME    # Redémarrage"
echo "  pm2 stop $APP_NAME       # Arrêt"