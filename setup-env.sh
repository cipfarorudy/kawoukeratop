#!/bin/bash

# 🔧 Script de configuration des variables d'environnement
# Usage: ./setup-env.sh [production|development|staging]

set -e

# Configuration
ENVIRONMENT=${1:-production}
PROJECT_ROOT=$(pwd)
API_ENV_FILE="$PROJECT_ROOT/apps/api/.env"
WEB_ENV_FILE="$PROJECT_ROOT/apps/web/.env"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Fonction pour demander une valeur
prompt_value() {
    local var_name="$1"
    local description="$2"
    local default_value="$3"
    local is_secret="$4"
    local value=""
    
    if [ -n "$default_value" ]; then
        echo -n "$description [$default_value]: "
    else
        echo -n "$description: "
    fi
    
    if [ "$is_secret" = "true" ]; then
        read -s value
        echo ""
    else
        read value
    fi
    
    if [ -z "$value" ] && [ -n "$default_value" ]; then
        value="$default_value"
    fi
    
    echo "$value"
}

# Configuration selon l'environnement
setup_environment_config() {
    case $ENVIRONMENT in
        "production")
            DOMAIN="kawoukeravore.top"
            NODE_ENV="production"
            PORT="4000"
            FRONTEND_URL="https://$DOMAIN"
            API_URL="https://$DOMAIN/api"
            ;;
        "staging")
            DOMAIN="staging.kawoukeravore.top"
            NODE_ENV="staging"
            PORT="4001"
            FRONTEND_URL="https://$DOMAIN"
            API_URL="https://$DOMAIN/api"
            ;;
        "development")
            DOMAIN="localhost"
            NODE_ENV="development"
            PORT="4000"
            FRONTEND_URL="http://localhost:5173"
            API_URL="http://localhost:4000/api"
            ;;
        *)
            log_error "Environnement non reconnu: $ENVIRONMENT"
            exit 1
            ;;
    esac
}

# Configuration interactive des variables
interactive_setup() {
    log_step "Configuration interactive pour l'environnement: $ENVIRONMENT"
    echo ""
    
    # Variables de base
    log_info "📱 Configuration de base"
    CUSTOM_DOMAIN=$(prompt_value "DOMAIN" "Nom de domaine" "$DOMAIN")
    CUSTOM_PORT=$(prompt_value "PORT" "Port de l'API" "$PORT")
    
    # Microsoft Graph
    echo ""
    log_info "🔐 Configuration Microsoft Graph (pour l'email)"
    MS_CLIENT_ID=$(prompt_value "MICROSOFT_CLIENT_ID" "Client ID Microsoft Graph" "")
    MS_CLIENT_SECRET=$(prompt_value "MICROSOFT_CLIENT_SECRET" "Client Secret Microsoft Graph" "" "true")
    MS_TENANT_ID=$(prompt_value "MICROSOFT_TENANT_ID" "Tenant ID Microsoft" "")
    
    # Email SMTP
    echo ""
    log_info "📧 Configuration Email SMTP"
    SMTP_HOST=$(prompt_value "SMTP_HOST" "Serveur SMTP" "smtp.office365.com")
    SMTP_PORT=$(prompt_value "SMTP_PORT" "Port SMTP" "587")
    SMTP_USER=$(prompt_value "SMTP_USER" "Utilisateur SMTP" "contact@$CUSTOM_DOMAIN")
    SMTP_PASS=$(prompt_value "SMTP_PASS" "Mot de passe SMTP" "" "true")
    
    # WhatsApp
    echo ""
    log_info "📞 Configuration WhatsApp Business API"
    WA_VERIFY_TOKEN=$(prompt_value "WHATSAPP_VERIFY_TOKEN" "Token de vérification WhatsApp" "")
    WA_ACCESS_TOKEN=$(prompt_value "WHATSAPP_ACCESS_TOKEN" "Token d'accès WhatsApp" "" "true")
    WA_PHONE_ID=$(prompt_value "WHATSAPP_PHONE_ID" "ID du téléphone WhatsApp" "")
    
    # Base de données (optionnel)
    echo ""
    log_info "🗄️ Configuration Base de données (optionnel)"
    DATABASE_URL=$(prompt_value "DATABASE_URL" "URL de la base de données" "")
    
    # Sécurité
    echo ""
    log_info "🔒 Configuration Sécurité"
    JWT_SECRET=$(prompt_value "JWT_SECRET" "Clé secrète JWT" "$(openssl rand -hex 32)")
    
    # Mise à jour des URLs selon le domaine personnalisé
    if [ "$CUSTOM_DOMAIN" != "$DOMAIN" ]; then
        DOMAIN="$CUSTOM_DOMAIN"
        if [ "$ENVIRONMENT" = "development" ]; then
            FRONTEND_URL="http://$DOMAIN:5173"
            API_URL="http://$DOMAIN:$CUSTOM_PORT/api"
        else
            FRONTEND_URL="https://$DOMAIN"
            API_URL="https://$DOMAIN/api"
        fi
    fi
    
    if [ "$CUSTOM_PORT" != "$PORT" ]; then
        PORT="$CUSTOM_PORT"
    fi
}

# Génération du fichier .env pour l'API
generate_api_env() {
    log_step "Génération du fichier .env pour l'API..."
    
    mkdir -p "$(dirname "$API_ENV_FILE")"
    
    cat > "$API_ENV_FILE" << EOF
# Configuration d'environnement: $ENVIRONMENT
# Généré le: $(date)

# Environnement
NODE_ENV=$NODE_ENV
PORT=$PORT

# URLs
FRONTEND_URL=$FRONTEND_URL
API_URL=$API_URL
DOMAIN=$DOMAIN

# Microsoft Graph (Email)
MICROSOFT_CLIENT_ID=$MS_CLIENT_ID
MICROSOFT_CLIENT_SECRET=$MS_CLIENT_SECRET
MICROSOFT_TENANT_ID=$MS_TENANT_ID

# Configuration Email SMTP
SMTP_HOST=$SMTP_HOST
SMTP_PORT=$SMTP_PORT
SMTP_USER=$SMTP_USER
SMTP_PASS=$SMTP_PASS

# WhatsApp Business API
WHATSAPP_VERIFY_TOKEN=$WA_VERIFY_TOKEN
WHATSAPP_ACCESS_TOKEN=$WA_ACCESS_TOKEN
WHATSAPP_PHONE_ID=$WA_PHONE_ID

# Base de données
DATABASE_URL=$DATABASE_URL

# Sécurité
JWT_SECRET=$JWT_SECRET
CORS_ORIGIN=$FRONTEND_URL

# Configuration supplémentaire
SESSION_SECRET=$(openssl rand -hex 32)
RATE_LIMIT_WINDOW=900000
RATE_LIMIT_MAX=100

# Logs
LOG_LEVEL=$( [ "$ENVIRONMENT" = "production" ] && echo "info" || echo "debug" )

# Cache (Redis - optionnel)
REDIS_URL=redis://localhost:6379

# Monitoring
HEALTH_CHECK_PATH=/api/health
METRICS_PATH=/api/metrics
EOF

    log_info "✅ Fichier .env API créé: $API_ENV_FILE"
}

# Génération du fichier .env pour le frontend (si nécessaire)
generate_web_env() {
    log_step "Génération du fichier .env pour le frontend..."
    
    mkdir -p "$(dirname "$WEB_ENV_FILE")"
    
    cat > "$WEB_ENV_FILE" << EOF
# Configuration frontend - $ENVIRONMENT
# Généré le: $(date)

# Environnement
VITE_NODE_ENV=$NODE_ENV

# URLs de l'API
VITE_API_URL=$API_URL
VITE_FRONTEND_URL=$FRONTEND_URL

# Configuration WhatsApp (publique)
VITE_WHATSAPP_NUMBER=+590690123456

# Analytics (optionnel)
VITE_GA_TRACKING_ID=
VITE_HOTJAR_ID=

# Fonctionnalités
VITE_ENABLE_PWA=true
VITE_ENABLE_ANALYTICS=false
EOF

    log_info "✅ Fichier .env frontend créé: $WEB_ENV_FILE"
}

# Validation des fichiers générés
validate_config() {
    log_step "Validation des configurations..."
    
    # Vérifier l'API
    if [ -f "$API_ENV_FILE" ]; then
        log_info "✅ Fichier API .env trouvé"
        
        # Vérifier les variables critiques
        if grep -q "MICROSOFT_CLIENT_ID=" "$API_ENV_FILE" && \
           grep -q "JWT_SECRET=" "$API_ENV_FILE"; then
            log_info "✅ Variables critiques présentes"
        else
            log_warn "⚠️  Certaines variables critiques peuvent être manquantes"
        fi
    else
        log_error "❌ Fichier API .env manquant"
        return 1
    fi
    
    # Vérifier le frontend
    if [ -f "$WEB_ENV_FILE" ]; then
        log_info "✅ Fichier frontend .env trouvé"
    fi
    
    log_info "✅ Validation terminée"
}

# Affichage des informations finales
show_completion_info() {
    echo ""
    log_info "🎉 Configuration terminée avec succès!"
    echo ""
    echo "📁 Fichiers créés:"
    echo "   - API: $API_ENV_FILE"
    echo "   - Frontend: $WEB_ENV_FILE"
    echo ""
    echo "🔧 Configuration:"
    echo "   - Environnement: $ENVIRONMENT"
    echo "   - Domaine: $DOMAIN"
    echo "   - Port API: $PORT"
    echo "   - URL Frontend: $FRONTEND_URL"
    echo "   - URL API: $API_URL"
    echo ""
    echo "⚠️  Important:"
    echo "   - Vérifiez les variables dans les fichiers .env"
    echo "   - Ne commitez JAMAIS les fichiers .env dans Git"
    echo "   - Sauvegardez vos variables d'environnement de façon sécurisée"
    echo ""
    echo "🚀 Prochaines étapes:"
    echo "   1. Vérifiez les configurations dans les fichiers .env"
    echo "   2. Lancez l'application: npm run dev"
    echo "   3. Testez les fonctionnalités (email, WhatsApp)"
    echo ""
}

# Configuration automatique (non-interactive)
auto_setup() {
    log_step "Configuration automatique pour l'environnement: $ENVIRONMENT"
    
    # Utiliser les valeurs par défaut
    MS_CLIENT_ID=""
    MS_CLIENT_SECRET=""
    MS_TENANT_ID=""
    SMTP_HOST="smtp.office365.com"
    SMTP_PORT="587"
    SMTP_USER="contact@$DOMAIN"
    SMTP_PASS=""
    WA_VERIFY_TOKEN=""
    WA_ACCESS_TOKEN=""
    WA_PHONE_ID=""
    DATABASE_URL=""
    JWT_SECRET=$(openssl rand -hex 32)
}

# Fonction principale
main() {
    log_info "🌴 Configuration d'environnement Kawoukeravore"
    echo ""
    
    setup_environment_config
    
    # Vérifier si on doit faire une configuration interactive
    if [ "$2" = "--auto" ]; then
        auto_setup
    else
        interactive_setup
    fi
    
    generate_api_env
    generate_web_env
    validate_config
    show_completion_info
}

# Afficher l'aide
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [environment] [--auto]"
    echo ""
    echo "Environnements disponibles:"
    echo "  production   - Configuration pour la production (kawoukeravore.top)"
    echo "  staging      - Configuration pour le staging (staging.kawoukeravore.top)"
    echo "  development  - Configuration pour le développement local"
    echo ""
    echo "Options:"
    echo "  --auto       - Configuration automatique sans interaction"
    echo "  --help, -h   - Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 production                # Configuration interactive pour la production"
    echo "  $0 development --auto        # Configuration automatique pour le développement"
    exit 0
fi

# Exécution du script
main "$@"