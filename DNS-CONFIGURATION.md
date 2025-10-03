# 🌐 Configuration DNS pour kawoukeravore.top

## 📋 Enregistrements DNS Requis

Pour connecter votre domaine `kawoukeravore.top` aux services Azure, vous devez configurer ces enregistrements DNS chez votre registraire :

### 🎯 Frontend (Static Web App)

| Type | Nom | Valeur | TTL |
|------|-----|--------|-----|
| **CNAME** | `www` | `black-island-0b83e3e03.1.azurestaticapps.net` | 3600 |
| **A** | `@` (apex) | Voir instruction ci-dessous | 3600 |

### 🔧 API Backend (App Service)

| Type | Nom | Valeur | TTL |
|------|-----|--------|-----|
| **CNAME** | `api` | `kawoukeravore-api-prod.azurewebsites.net` | 3600 |

## 🚀 Instructions de Configuration

### Étape 1: Configuration chez votre registraire de domaine

1. **Connectez-vous** à votre panel de gestion DNS (OVH, Gandi, GoDaddy, etc.)

2. **Ajoutez les enregistrements CNAME** :
   ```dns
   www.kawoukeravore.top CNAME black-island-0b83e3e03.1.azurestaticapps.net
   api.kawoukeravore.top CNAME kawoukeravore-api-prod.azurewebsites.net
   ```

3. **Pour le domaine apex** (kawoukeravore.top sans www) :
   - Certains registraires supportent les enregistrements A pointant vers une Static Web App
   - Sinon, créez une redirection de `kawoukeravore.top` vers `www.kawoukeravore.top`

### Étape 2: Validation et activation Azure

Après avoir configuré les DNS, exécutez ces commandes :

```bash
# Ajouter le domaine www à la Static Web App
az staticwebapp hostname set --name kawoukeravore-frontend-prod --resource-group kawoukeravore-rg-prod --hostname www.kawoukeravore.top

# Ajouter le domaine API à l'App Service
az webapp config hostname add --webapp-name kawoukeravore-api-prod --resource-group kawoukeravore-rg-prod --hostname api.kawoukeravore.top
```

## 🔒 Certificats SSL

Les certificats SSL seront **automatiquement générés** par Azure :

- ✅ **Static Web App** : SSL gratuit automatique (Let's Encrypt)
- ✅ **App Service** : Certificat managé Azure gratuit

## 📊 Vérification DNS

### Test des enregistrements DNS

```bash
# Vérifier CNAME www
nslookup www.kawoukeravore.top

# Vérifier CNAME api  
nslookup api.kawoukeravore.top

# Test de connectivité
curl -I https://www.kawoukeravore.top
curl -I https://api.kawoukeravore.top/api/health
```

### Délai de propagation

- ⏱️ **Propagation DNS** : 5 minutes à 48 heures
- 🚀 **SSL généré** : Automatique après validation DNS
- ✅ **Sites accessibles** : Immédiatement après SSL

## 🌍 URLs Finales

Après configuration complète :

- 🏠 **Site principal** : https://kawoukeravore.top ➡️ https://www.kawoukeravore.top
- 🌐 **Frontend** : https://www.kawoukeravore.top
- 🔧 **API** : https://api.kawoukeravore.top
- 📊 **Health Check** : https://api.kawoukeravore.top/api/health

## 🆘 Dépannage DNS

### Erreurs fréquentes

**❌ "CNAME Record is invalid"**
```bash
# Vérifier que le DNS est bien propagé
dig www.kawoukeravore.top CNAME
```

**❌ "Apex Domains must use dns-txt-token"**
```bash
# Pour domaine apex, utiliser une redirection ou ALIAS
```

### Commandes utiles

```bash
# Status des domaines personnalisés
az staticwebapp hostname list --name kawoukeravore-frontend-prod --resource-group kawoukeravore-rg-prod

# Status SSL App Service  
az webapp config ssl list --resource-group kawoukeravore-rg-prod
```

## 📧 Support

- 💬 **Discord Kawoukeravore** : #tech-support
- 📧 **Email** : tech@kawoukeravore.top
- 📞 **Azure Support** : Si problème côté Microsoft

---

🌴 **Kawoukeravore** - Domaine personnalisé sur Azure !