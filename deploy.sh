#!/bin/bash

# Script de déploiement Kawoukeravore
# Usage: ./deploy.sh

echo "🚀 Déploiement Kawoukeravore..."

# Variables
PROJECT_NAME="kawoukeravore"
DOMAIN="kawoukeravore.site"
NGINX_CONFIG="/etc/nginx/sites-available/$DOMAIN"
NGINX_ENABLED="/etc/nginx/sites-enabled/$DOMAIN"
WEB_ROOT="/var/www/$PROJECT_NAME"
API_SERVICE="kawoukeravore-api"

# Couleurs pour les logs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
check_dependencies() {
    log_info "Vérification des dépendances..."
    
    if ! command -v nginx &> /dev/null; then
        log_error "Nginx n'est pas installé"
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        log_error "Node.js/npm n'est pas installé"
        exit 1
    fi
    
    if ! command -v pm2 &> /dev/null; then
        log_warn "PM2 n'est pas installé. Installation..."
        npm install -g pm2
    fi
}

# Build du frontend
build_frontend() {
    log_info "Build du frontend..."
    cd apps/web
    npm install
    npm run build
    cd ../..
    
    if [ ! -d "apps/web/dist" ]; then
        log_error "Le build frontend a échoué"
        exit 1
    fi
    
    log_info "✅ Build frontend réussi"
}

# Installation de l'API
setup_api() {
    log_info "Configuration de l'API..."
    cd apps/api
    npm install
    
    # Vérification du fichier .env
    if [ ! -f ".env" ]; then
        log_warn "Fichier .env manquant. Copie depuis .env.example"
        cp .env.example .env
        log_warn "⚠️  Configurez les variables dans apps/api/.env"
    fi
    
    cd ../..
    log_info "✅ API configurée"
}

# Déploiement des fichiers
deploy_files() {
    log_info "Déploiement des fichiers..."
    
    # Création du répertoire web
    sudo mkdir -p $WEB_ROOT
    
    # Copie du frontend
    sudo cp -r apps/web/dist/* $WEB_ROOT/
    sudo chown -R www-data:www-data $WEB_ROOT
    sudo chmod -R 755 $WEB_ROOT
    
    log_info "✅ Fichiers déployés dans $WEB_ROOT"
}

# Configuration Nginx
setup_nginx() {
    log_info "Configuration Nginx..."
    
    # Copie de la configuration
    sudo cp nginx.conf $NGINX_CONFIG
    
    # Création du lien symbolique
    if [ ! -L "$NGINX_ENABLED" ]; then
        sudo ln -s $NGINX_CONFIG $NGINX_ENABLED
    fi
    
    # Test de la configuration
    if sudo nginx -t; then
        sudo systemctl reload nginx
        log_info "✅ Configuration Nginx appliquée"
    else
        log_error "Configuration Nginx invalide"
        exit 1
    fi
}

# Gestion du service API avec PM2
setup_pm2() {
    log_info "Configuration PM2 pour l'API..."
    
    # Arrêt de l'ancien processus s'il existe
    pm2 delete $API_SERVICE 2>/dev/null || true
    
    # Démarrage du nouveau processus
    cd apps/api
    pm2 start src/server.js --name $API_SERVICE
    pm2 save
    
    # Configuration du démarrage automatique
    pm2 startup
    
    cd ../..
    log_info "✅ API démarrée avec PM2"
}

# SSL avec Let's Encrypt
setup_ssl() {
    log_info "Configuration SSL avec Let's Encrypt..."
    
    if ! command -v certbot &> /dev/null; then
        log_warn "Installation de Certbot..."
        sudo apt update
        sudo apt install -y certbot python3-certbot-nginx
    fi
    
    # Génération du certificat SSL
    sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email contact@$DOMAIN
    
    log_info "✅ Certificat SSL configuré"
}

# Fonction principale
main() {
    log_info "🌴 Début du déploiement de Kawoukeravore"
    
    check_dependencies
    build_frontend
    setup_api
    deploy_files
    setup_nginx
    setup_pm2
    
    log_info "🎉 Déploiement terminé !"
    log_info "📱 Site accessible sur : https://$DOMAIN"
    log_info "🔧 API disponible sur : https://$DOMAIN/api/health"
    
    # Affichage du statut
    echo ""
    log_info "📊 Statut des services :"
    sudo systemctl status nginx --no-pager -l
    pm2 status
}

# Exécution
main "$@"