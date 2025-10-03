# 🚀 Guide de Déploiement Kawoukeravore

Ce guide vous accompagne dans le déploiement de la plateforme culturelle Kawoukeravore sur différents environnements.

## 📋 Prérequis

### Système Linux/Ubuntu (Production)
- Ubuntu 20.04+ ou Debian 10+
- Node.js 18+ et npm
- Git
- Nginx
- Certbot (Let's Encrypt)
- Accès sudo/root

### Système Windows (Développement/Test)
- Windows 10/11
- Node.js 18+ et npm
- Git
- IIS (optionnel)
- PowerShell ou Command Prompt

## 🔄 Options de Déploiement

### 1. Déploiement Linux/Ubuntu (Production)

#### Déploiement Complet
```bash
# Rendre le script exécutable
chmod +x deploy-production.sh

# Déploiement complet (recommandé)
sudo ./deploy-production.sh full

# Ou déploiement par composants
sudo ./deploy-production.sh frontend  # Frontend uniquement
sudo ./deploy-production.sh api       # API uniquement
```

#### Ce que fait le script Linux:
1. ✅ Vérification des prérequis système
2. 🔄 Clone/mise à jour du repository Git
3. 📦 Installation des dépendances npm
4. 🏗️ Build du frontend React avec Vite
5. 🔧 Configuration de l'API Express
6. 🚀 Démarrage avec PM2
7. 🌐 Configuration Nginx avec reverse proxy
8. 🔒 Installation SSL Let's Encrypt
9. 🧪 Tests de fonctionnement

### 2. Déploiement Windows (Local/Test)

```cmd
# Exécuter le script batch
deploy-windows.bat full

# Ou par composants
deploy-windows.bat frontend
deploy-windows.bat api
```

#### Ce que fait le script Windows:
1. ✅ Vérification de Node.js, npm, Git
2. 🔄 Clone/mise à jour du repository
3. 📦 Installation des dépendances
4. 🏗️ Build du frontend
5. 🔧 Configuration de l'API
6. 🚀 Démarrage avec PM2
7. 📁 Copie vers IIS (si disponible)

## 🔧 Configuration Post-Déploiement

### Variables d'Environnement

Créez le fichier `apps/api/.env` avec:

```env
# Configuration de production
NODE_ENV=production
PORT=4000

# Base de données (si utilisée)
DATABASE_URL=your_database_url

# Microsoft Graph (Email)
MICROSOFT_CLIENT_ID=your_client_id
MICROSOFT_CLIENT_SECRET=your_client_secret
MICROSOFT_TENANT_ID=your_tenant_id

# WhatsApp Bot
WHATSAPP_VERIFY_TOKEN=your_verify_token
WHATSAPP_ACCESS_TOKEN=your_access_token

# URLs
FRONTEND_URL=https://kawoukeravore.top
API_URL=https://kawoukeravore.top/api

# Email Configuration
SMTP_HOST=smtp.office365.com
SMTP_PORT=587
SMTP_USER=contact@kawoukeravore.top
SMTP_PASS=your_password

# Sécurité
JWT_SECRET=your_jwt_secret
CORS_ORIGIN=https://kawoukeravore.top
```

### Configuration DNS

Pointez votre domaine vers votre serveur:

```
# Enregistrements DNS
A     kawoukeravore.top     → IP_DU_SERVEUR
A     www.kawoukeravore.top → IP_DU_SERVEUR
```

## 📊 Gestion des Processus

### Commandes PM2 Utiles

```bash
# Statut des processus
pm2 status

# Logs en temps réel
pm2 logs

# Logs spécifiques
pm2 logs kawoukeravore-api
pm2 logs kawoukeravore-whatsapp

# Redémarrage
pm2 restart kawoukeravore-api
pm2 restart all

# Arrêt
pm2 stop kawoukeravore-api
pm2 stop all

# Surveillance des ressources
pm2 monit
```

### Gestion Nginx

```bash
# Tester la configuration
sudo nginx -t

# Recharger la configuration
sudo systemctl reload nginx

# Redémarrer Nginx
sudo systemctl restart nginx

# Statut
sudo systemctl status nginx
```

## 🔍 Dépannage

### Logs d'Application

```bash
# Logs PM2
pm2 logs --lines 100

# Logs Nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# Logs système
sudo journalctl -u nginx -f
```

### Problèmes Courants

#### 1. Port déjà utilisé
```bash
# Vérifier les ports utilisés
sudo netstat -tlnp | grep :4000
sudo lsof -i :4000

# Tuer le processus
sudo kill -9 PID
```

#### 2. Permissions de fichiers
```bash
# Corriger les permissions web
sudo chown -R www-data:www-data /var/www/kawoukeravore
sudo chmod -R 755 /var/www/kawoukeravore
```

#### 3. SSL/Certificat
```bash
# Renouveler le certificat
sudo certbot renew --dry-run
sudo certbot renew

# Vérifier l'expiration
sudo certbot certificates
```

## 🔄 Mise à Jour

### Déploiement d'une Nouvelle Version

```bash
# Méthode 1: Re-exécuter le script
sudo ./deploy-production.sh full

# Méthode 2: Mise à jour manuelle
cd /var/www/kawoukeravore
git pull origin main
npm run build
pm2 restart all
```

## 📱 URLs d'Accès

Après déploiement réussi:

- 🌐 **Frontend**: https://kawoukeravore.top
- 🔧 **API Health**: https://kawoukeravore.top/api/health
- 📊 **API Status**: https://kawoukeravore.top/api/status
- 📞 **WhatsApp Webhook**: https://kawoukeravore.top/api/webhook/whatsapp

## 🛡️ Sécurité

### Configuration Firewall

```bash
# Ubuntu/Debian
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable

# CentOS/RHEL
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### Sauvegardes

```bash
# Script de sauvegarde (à programmer avec cron)
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf /backup/kawoukeravore_$DATE.tar.gz /var/www/kawoukeravore
```

## 🆘 Support

En cas de problème:

1. Vérifiez les logs avec `pm2 logs`
2. Testez la configuration avec `nginx -t`
3. Vérifiez les processus avec `pm2 status`
4. Consultez les logs système avec `journalctl -f`

---

🌴 **Kawoukeravore** - Plateforme culturelle guadeloupéenne
📧 Contact: contact@kawoukeravore.top