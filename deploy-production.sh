#!/bin/bash

# 🚀 Script de déploiement automatisé Kawoukeravore
# Usage: ./deploy-production.sh [frontend|api|full]

set -e  # Arrêter le script en cas d'erreur

# Configuration
PROJECT_NAME="kawoukeravore"
DOMAIN="kawoukeravore.top"
REPO_URL="https://github.com/cipfarorudy/kawoukeravore.git"
DEPLOY_USER="www-data"
WEB_ROOT="/var/www/${PROJECT_NAME}"
API_PORT="4000"
NODE_ENV="production"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions utilitaires
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Vérification des prérequis
check_prerequisites() {
    log_step "Vérification des prérequis système..."
    
    # Vérifier si on est root ou sudo
    if [[ $EUID -ne 0 ]]; then
        log_error "Ce script doit être exécuté en tant que root ou avec sudo"
        exit 1
    fi
    
    # Vérifier les commandes requises
    local commands=("git" "node" "npm" "nginx")
    for cmd in "${commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            log_error "$cmd n'est pas installé"
            exit 1
        fi
    done
    
    # Vérifier PM2
    if ! command -v pm2 &> /dev/null; then
        log_warn "PM2 n'est pas installé. Installation..."
        npm install -g pm2
    fi
    
    log_info "✅ Prérequis validés"
}

# Clone ou mise à jour du repository
setup_repository() {
    log_step "Configuration du repository..."
    
    if [ -d "$WEB_ROOT" ]; then
        log_info "Repository existant trouvé. Mise à jour..."
        cd $WEB_ROOT
        git fetch origin
        git reset --hard origin/main
        git clean -fd
    else
        log_info "Clonage du repository..."
        git clone $REPO_URL $WEB_ROOT
        cd $WEB_ROOT
    fi
    
    # Vérifier la branche
    git checkout main
    git pull origin main
    
    log_info "✅ Repository configuré"
}

# Installation des dépendances
install_dependencies() {
    log_step "Installation des dépendances..."
    
    cd $WEB_ROOT
    
    # Installation des dépendances racine
    log_info "Installation des dépendances racine..."
    npm install --production=false
    
    # Installation des dépendances frontend
    log_info "Installation des dépendances frontend..."
    cd apps/web
    npm install --production=false
    cd ../..
    
    # Installation des dépendances API
    log_info "Installation des dépendances API..."
    cd apps/api
    npm install --production
    cd ../..
    
    # Installation des dépendances WhatsApp Bot
    if [ -d "apps/whatsapp-bot" ]; then
        log_info "Installation des dépendances WhatsApp Bot..."
        cd apps/whatsapp-bot
        npm install --production
        cd ../..
    fi
    
    log_info "✅ Dépendances installées"
}

# Build du frontend
build_frontend() {
    log_step "Build du frontend React..."
    
    cd $WEB_ROOT
    npm run build
    
    # Vérifier que le build existe
    if [ ! -d "apps/web/dist" ]; then
        log_error "Le build du frontend a échoué"
        exit 1
    fi
    
    # Copier les fichiers vers le répertoire web
    log_info "Copie des fichiers frontend..."
    mkdir -p /var/www/html/$PROJECT_NAME
    cp -r apps/web/dist/* /var/www/html/$PROJECT_NAME/
    
    # Définir les permissions
    chown -R $DEPLOY_USER:$DEPLOY_USER /var/www/html/$PROJECT_NAME
    chmod -R 755 /var/www/html/$PROJECT_NAME
    
    log_info "✅ Frontend déployé"
}

# Configuration de l'API
setup_api() {
    log_step "Configuration de l'API..."
    
    cd $WEB_ROOT/apps/api
    
    # Copier le fichier .env s'il n'existe pas
    if [ ! -f ".env" ]; then
        if [ -f ".env.production" ]; then
            log_info "Utilisation du fichier .env.production"
            cp .env.production .env
        elif [ -f ".env.example" ]; then
            log_warn "Fichier .env manquant. Copie depuis .env.example"
            cp .env.example .env
            log_warn "⚠️  IMPORTANT: Configurez les variables dans apps/api/.env"
        else
            log_error "Aucun fichier .env trouvé"
            exit 1
        fi
    fi
    
    # Arrêter l'ancien processus PM2 s'il existe
    pm2 delete kawoukeravore-api 2>/dev/null || true
    pm2 delete kawoukeravore-whatsapp 2>/dev/null || true
    
    # Démarrer l'API avec PM2
    log_info "Démarrage de l'API avec PM2..."
    NODE_ENV=$NODE_ENV pm2 start src/server.js --name kawoukeravore-api
    
    # Démarrer le bot WhatsApp s'il existe
    if [ -d "../whatsapp-bot" ]; then
        log_info "Démarrage du bot WhatsApp..."
        cd ../whatsapp-bot
        NODE_ENV=$NODE_ENV pm2 start src/index.js --name kawoukeravore-whatsapp
        cd ../api
    fi
    
    # Sauvegarder la configuration PM2
    pm2 save
    
    # Configurer le démarrage automatique
    env PATH=$PATH:/usr/bin pm2 startup systemd -u root --hp /root
    
    log_info "✅ API configurée et démarrée"
}

# Configuration de Nginx
setup_nginx() {
    log_step "Configuration de Nginx..."
    
    cd $WEB_ROOT
    
    # Sauvegarder la configuration existante
    if [ -f "/etc/nginx/sites-available/$DOMAIN" ]; then
        cp /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-available/$DOMAIN.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    # Copier la nouvelle configuration
    cp nginx.conf /etc/nginx/sites-available/$DOMAIN
    
    # Créer le lien symbolique
    if [ ! -L "/etc/nginx/sites-enabled/$DOMAIN" ]; then
        ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
    fi
    
    # Supprimer la configuration par défaut
    if [ -L "/etc/nginx/sites-enabled/default" ]; then
        rm /etc/nginx/sites-enabled/default
    fi
    
    # Tester la configuration Nginx
    if nginx -t; then
        systemctl reload nginx
        log_info "✅ Configuration Nginx appliquée"
    else
        log_error "Configuration Nginx invalide"
        exit 1
    fi
}

# Configuration SSL avec Let's Encrypt
setup_ssl() {
    log_step "Configuration SSL avec Let's Encrypt..."
    
    # Installer Certbot si nécessaire
    if ! command -v certbot &> /dev/null; then
        log_info "Installation de Certbot..."
        apt update
        apt install -y certbot python3-certbot-nginx
    fi
    
    # Générer le certificat SSL
    log_info "Génération du certificat SSL pour $DOMAIN..."
    certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email contact@$DOMAIN
    
    # Configurer le renouvellement automatique
    if ! crontab -l | grep -q certbot; then
        (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
        log_info "Renouvellement SSL automatique configuré"
    fi
    
    log_info "✅ SSL configuré"
}

# Tests de déploiement
run_tests() {
    log_step "Tests de déploiement..."
    
    # Test du frontend
    log_info "Test du frontend..."
    if curl -f -s https://$DOMAIN > /dev/null; then
        log_info "✅ Frontend accessible"
    else
        log_warn "⚠️  Frontend peut ne pas être accessible"
    fi
    
    # Test de l'API
    log_info "Test de l'API..."
    if curl -f -s https://$DOMAIN/api/health > /dev/null; then
        log_info "✅ API opérationnelle"
    else
        log_warn "⚠️  API peut ne pas être accessible"
    fi
    
    # Afficher le statut PM2
    log_info "Statut des processus PM2:"
    pm2 status
    
    # Afficher le statut Nginx
    log_info "Statut Nginx:"
    systemctl status nginx --no-pager -l
}

# Affichage des informations finales
show_completion_info() {
    echo ""
    log_info "🎉 Déploiement terminé avec succès!"
    echo ""
    echo "📱 Votre site est maintenant accessible sur:"
    echo "   🌐 Frontend: https://$DOMAIN"
    echo "   🔧 API: https://$DOMAIN/api/health"
    echo "   📞 WhatsApp: Configuré via l'API"
    echo ""
    echo "📊 Commandes utiles:"
    echo "   pm2 status          # Voir les processus"
    echo "   pm2 logs            # Voir les logs"
    echo "   pm2 restart all     # Redémarrer tous les processus"
    echo "   nginx -t            # Tester la config Nginx"
    echo "   systemctl status nginx  # Statut Nginx"
    echo ""
}

# Fonction principale
main() {
    local deployment_type=${1:-full}
    
    log_info "🌴 Démarrage du déploiement Kawoukeravore ($deployment_type)"
    
    case $deployment_type in
        "frontend")
            check_prerequisites
            setup_repository
            install_dependencies
            build_frontend
            setup_nginx
            setup_ssl
            ;;
        "api")
            check_prerequisites
            setup_repository
            install_dependencies
            setup_api
            ;;
        "full"|*)
            check_prerequisites
            setup_repository
            install_dependencies
            build_frontend
            setup_api
            setup_nginx
            setup_ssl
            run_tests
            show_completion_info
            ;;
    esac
}

# Exécution du script
main "$@"