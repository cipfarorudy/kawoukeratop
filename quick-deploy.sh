#!/bin/bash

# 🌴 Script de préparation rapide pour le déploiement Kawoukeravore
# Usage: curl -fsSL https://raw.githubusercontent.com/cipfarorudy/kawoukeravore/main/quick-deploy.sh | bash

set -e

# Configuration
REPO_URL="https://github.com/cipfarorudy/kawoukeravore.git"
PROJECT_DIR="/var/www/kawoukeravore"
DOMAIN="kawoukeravore.top"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🌴 Préparation du déploiement Kawoukeravore${NC}"
echo -e "${BLUE}Domaine cible: $DOMAIN${NC}"
echo ""

# Vérifier les droits d'administration
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}Ce script doit être exécuté en tant que root${NC}"
   echo "Usage: sudo curl -fsSL https://raw.githubusercontent.com/cipfarorudy/kawoukeravore/main/quick-deploy.sh | bash"
   exit 1
fi

# Mise à jour du système
echo -e "${BLUE}[1/6] Mise à jour du système...${NC}"
apt update && apt upgrade -y

# Installation des dépendances
echo -e "${BLUE}[2/6] Installation des dépendances...${NC}"
apt install -y curl git nginx certbot python3-certbot-nginx ufw

# Installation de Node.js 18+
echo -e "${BLUE}[3/6] Installation de Node.js...${NC}"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Installation de PM2
echo -e "${BLUE}[4/6] Installation de PM2...${NC}"
npm install -g pm2

# Clone du repository
echo -e "${BLUE}[5/6] Clone du projet...${NC}"
if [ -d "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR"
fi
git clone "$REPO_URL" "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Rendre les scripts exécutables
chmod +x deploy-production.sh
chmod +x setup-env.sh

# Configuration du firewall
echo -e "${BLUE}[6/6] Configuration sécuritaire...${NC}"
ufw allow ssh
ufw allow 80
ufw allow 443
ufw --force enable

echo ""
echo -e "${GREEN}✅ Préparation terminée !${NC}"
echo ""
echo -e "${YELLOW}Prochaines étapes :${NC}"
echo "1. Configurer les variables d'environnement :"
echo "   cd $PROJECT_DIR && sudo ./setup-env.sh production"
echo ""
echo "2. Lancer le déploiement complet :"
echo "   sudo ./deploy-production.sh full"
echo ""
echo "3. Ou utiliser PM2 directement :"
echo "   pm2 deploy production setup"
echo "   pm2 deploy production"
echo ""
echo -e "${GREEN}🚀 Votre serveur est prêt pour le déploiement !${NC}"