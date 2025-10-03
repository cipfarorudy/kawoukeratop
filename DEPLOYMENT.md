# 🚀 Guide de déploiement Kawoukeravore

Guide complet pour déployer votre plateforme culturelle guadeloupéenne sur un serveur Ubuntu/Debian.

## 📋 Prérequis

### Serveur requis
- **OS** : Ubuntu 20.04+ ou Debian 11+
- **RAM** : Minimum 1 GB (recommandé 2 GB)
- **Stockage** : 10 GB libres
- **Domaine** : `kawoukeravore.site` pointant vers votre serveur

### Logiciels à installer
```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation de Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Installation de Nginx
sudo apt install -y nginx

# Installation de PM2 (gestionnaire de processus)
sudo npm install -g pm2

# Installation de Git
sudo apt install -y git

# Installation de Certbot (SSL)
sudo apt install -y certbot python3-certbot-nginx
```

## 🏗️ Déploiement automatique

### Méthode rapide avec le script

1. **Clonez votre projet** sur le serveur :
```bash
cd /var/www
sudo git clone https://github.com/votre-username/kawoukeravore.git
sudo chown -R $USER:$USER kawoukeravore
cd kawoukeravore
```

2. **Rendez le script exécutable** :
```bash
chmod +x deploy.sh
```

3. **Exécutez le déploiement** :
```bash
./deploy.sh
```

## 🔧 Déploiement manuel

### Étape 1 : Build du frontend

```bash
cd /var/www/kawoukeravore/apps/web
npm install
npm run build
```

### Étape 2 : Configuration de l'API

```bash
cd /var/www/kawoukeravore/apps/api
npm install

# Configuration des variables d'environnement
cp .env.example .env
nano .env
```

**Configuration `.env` de production :**
```env
NODE_ENV=production
PORT=4000

# Configuration Email Gmail
MAIL_USER=votre.email@gmail.com
MAIL_PASS=votre_mot_de_passe_application
MAIL_TO=contact@kawoukeravore.site

# Sécurité
CORS_ORIGIN=https://kawoukeravore.site,https://www.kawoukeravore.site
```

### Étape 3 : Configuration Nginx

```bash
# Copie de la configuration
sudo cp /var/www/kawoukeravore/nginx.conf /etc/nginx/sites-available/kawoukeravore.site

# Activation du site
sudo ln -s /etc/nginx/sites-available/kawoukeravore.site /etc/nginx/sites-enabled/

# Test de la configuration
sudo nginx -t

# Rechargement de Nginx
sudo systemctl reload nginx
```

### Étape 4 : Démarrage de l'API avec PM2

```bash
cd /var/www/kawoukeravore

# Démarrage avec le fichier de configuration
pm2 start ecosystem.config.json

# Sauvegarde de la configuration PM2
pm2 save

# Configuration du démarrage automatique
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER --hp /home/$USER
```

### Étape 5 : Configuration SSL avec Let's Encrypt

```bash
# Génération du certificat SSL
sudo certbot --nginx -d kawoukeravore.site -d www.kawoukeravore.site

# Configuration du renouvellement automatique
sudo crontab -e
# Ajouter cette ligne :
# 0 12 * * * /usr/bin/certbot renew --quiet
```

## 🔍 Vérification du déploiement

### Tests de fonctionnement

1. **Frontend** :
```bash
curl -I https://kawoukeravore.site
# Doit retourner : HTTP/2 200
```

2. **API Health Check** :
```bash
curl https://kawoukeravore.site/api/health
# Doit retourner : {"status":"OK","message":"🚀 API Kawoukeravore opérationnelle"}
```

3. **Test du formulaire de contact** :
```bash
curl -X POST https://kawoukeravore.site/api/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@example.com","message":"Message de test déploiement"}'
```

### Commandes de monitoring

```bash
# Statut des services
sudo systemctl status nginx
pm2 status

# Logs en temps réel
pm2 logs kawoukeravore-api
sudo tail -f /var/log/nginx/kawoukeravore_access.log

# Métriques PM2
pm2 monit
```

## 🛠️ Maintenance

### Mise à jour du code

```bash
cd /var/www/kawoukeravore

# Récupération des dernières modifications
git pull origin main

# Rebuild du frontend
cd apps/web
npm install
npm run build

# Redémarrage de l'API
pm2 restart kawoukeravore-api

# Rechargement de Nginx (si config modifiée)
sudo systemctl reload nginx
```

### Sauvegarde

```bash
# Sauvegarde de la configuration
sudo tar -czf /backup/kawoukeravore-config-$(date +%Y%m%d).tar.gz \
  /etc/nginx/sites-available/kawoukeravore.site \
  /var/www/kawoukeravore/.env \
  /var/www/kawoukeravore/ecosystem.config.json

# Sauvegarde des logs
sudo tar -czf /backup/kawoukeravore-logs-$(date +%Y%m%d).tar.gz \
  /var/log/nginx/kawoukeravore_*.log \
  /var/log/pm2/kawoukeravore-api*.log
```

### Monitoring et alertes

```bash
# Installation de monitoring (optionnel)
sudo apt install -y htop iotop

# Surveillance des ressources
htop
pm2 monit

# Vérification de l'espace disque
df -h

# Vérification de la mémoire
free -h
```

## 🔒 Sécurité

### Firewall (UFW)

```bash
# Configuration basique du firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

### Mise à jour automatique des certificats

```bash
# Test du renouvellement
sudo certbot renew --dry-run

# Configuration cron pour le renouvellement automatique
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

## 🎯 Optimisations de performance

### Nginx

```bash
# Augmentation des limites (dans /etc/nginx/nginx.conf)
worker_processes auto;
worker_connections 1024;
client_max_body_size 10M;
```

### PM2 Cluster Mode (pour plus de trafic)

```json
{
  "apps": [{
    "name": "kawoukeravore-api",
    "script": "apps/api/src/server.js",
    "instances": "max",
    "exec_mode": "cluster"
  }]
}
```

## 📊 Métriques et analytics

### Logs structurés

```bash
# Analyse des logs Nginx
sudo goaccess /var/log/nginx/kawoukeravore_access.log -c

# Monitoring des erreurs API
pm2 logs kawoukeravore-api --err
```

## 🆘 Dépannage

### Problèmes courants

1. **Erreur 502 Bad Gateway** :
   - Vérifiez que l'API PM2 fonctionne : `pm2 status`
   - Redémarrez l'API : `pm2 restart kawoukeravore-api`

2. **Erreur SSL** :
   - Renouvelez le certificat : `sudo certbot renew`
   - Vérifiez la configuration Nginx : `sudo nginx -t`

3. **Emails non envoyés** :
   - Vérifiez la configuration `.env`
   - Consultez les logs : `pm2 logs kawoukeravore-api`

### Support

Pour obtenir de l'aide :
- 📧 Email : support@kawoukeravore.site
- 📚 Documentation : https://github.com/votre-username/kawoukeravore
- 🐛 Issues : https://github.com/votre-username/kawoukeravore/issues

---

**🌴 Votre plateforme Kawoukeravore est maintenant déployée et prête à promouvoir la culture guadeloupéenne ! 🇬🇵✨**