# 🚀 Déploiement Kawoukeravore

Guide de déploiement rapide pour la plateforme culturelle Kawoukeravore sur **kawoukeravore.top**.

## ⚡ Déploiement Express (Ubuntu/Debian)

### 1-Clic : Préparation du serveur
```bash
curl -fsSL https://raw.githubusercontent.com/cipfarorudy/kawoukeravore/main/quick-deploy.sh | sudo bash
```

### Configuration et déploiement
```bash
cd /var/www/kawoukeravore
sudo ./setup-env.sh production      # Configuration interactive
sudo ./deploy-production.sh full    # Déploiement complet
```

**C'est tout !** Votre site sera disponible sur https://kawoukeravore.top

## 📋 Méthodes de Déploiement

### Option 1: Script Automatisé (Recommandé)
- ✅ Configuration système automatique
- ✅ Installation des dépendances  
- ✅ Build et déploiement
- ✅ Configuration Nginx + SSL
- ✅ Monitoring PM2

### Option 2: PM2 Deploy
```bash
pm2 deploy production setup
pm2 deploy production
```

### Option 3: Déploiement Windows (Test/Dev)
```cmd
deploy-windows.bat full
```

## 🔧 Configuration

### Variables d'Environnement Requises
```env
# Microsoft Graph (Email)
MICROSOFT_CLIENT_ID=votre_client_id
MICROSOFT_CLIENT_SECRET=votre_client_secret  
MICROSOFT_TENANT_ID=votre_tenant_id

# WhatsApp Business API
WHATSAPP_VERIFY_TOKEN=votre_verify_token
WHATSAPP_ACCESS_TOKEN=votre_access_token

# Email SMTP  
SMTP_HOST=smtp.office365.com
SMTP_USER=contact@kawoukeravore.top
SMTP_PASS=votre_mot_de_passe
```

Le script `setup-env.sh` vous guide dans la configuration interactive.

## 🛠️ Gestion Post-Déploiement

### Commandes Utiles
```bash
pm2 status                    # Statut des processus
pm2 logs                      # Logs en temps réel  
pm2 restart kawoukeravore-api # Redémarrer l'API
pm2 monit                     # Monitoring des ressources
```

### Mise à jour
```bash
cd /var/www/kawoukeravore
git pull origin main
npm run build
pm2 restart all
```

## 📊 Services Déployés

| Service | URL | Description |
|---------|-----|-------------|
| 🌐 **Frontend** | https://kawoukeravore.top | Site React optimisé |
| 🔧 **API** | https://kawoukeravore.top/api/health | Backend Express |
| 📞 **WhatsApp** | https://kawoukeravore.top/api/webhook/whatsapp | Bot WhatsApp |
| 📧 **Email** | Via Microsoft Graph | Formulaires de contact |

## 🔍 Vérification

### Tests Automatiques
```bash
# Tester localement avant déploiement
./test-deployment.bat    # Windows
npm run build           # Build frontend
npm run test            # Tests unitaires (si disponible)
```

### Vérification Production
- ✅ Frontend accessible : https://kawoukeravore.top
- ✅ API fonctionnelle : https://kawoukeravore.top/api/health  
- ✅ SSL actif : Certificat Let's Encrypt
- ✅ Performance : Lighthouse > 90
- ✅ SEO : Meta tags optimisés

## 🆘 Dépannage

### Problèmes Courants

**Port déjà utilisé :**
```bash
sudo lsof -i :4000
sudo kill -9 PID
```

**Certificat SSL :**
```bash
sudo certbot renew --dry-run
sudo nginx -t && sudo systemctl reload nginx
```

**Logs d'erreur :**
```bash
pm2 logs --lines 100
sudo tail -f /var/log/nginx/error.log
```

## 📁 Structure de Déploiement

```
/var/www/kawoukeravore/
├── 📄 deploy-production.sh     # Script principal
├── 📄 setup-env.sh            # Configuration env
├── 📄 ecosystem.config.js     # Config PM2  
├── 📄 nginx.conf              # Config Nginx
├── 📁 apps/
│   ├── 📁 web/dist/           # Frontend buildé
│   ├── 📁 api/                # Backend Express
│   └── 📁 whatsapp-bot/       # Bot WhatsApp
└── 📁 logs/                   # Logs applications
```

## 🌴 Support

**Contact :** contact@kawoukeravore.top  
**Repository :** https://github.com/cipfarorudy/kawoukeravore  
**Documentation :** [DEPLOY.md](./DEPLOY.md)

---

🇬🇵 **Kawoukeravore** - Plateforme culturelle guadeloupéenne