# 🌍 Configuration Domaine kawoukeravore.top

Guide complet pour connecter le domaine personnalisé `kawoukeravore.top` aux services Azure.

## ✅ État Actuel des Services

### 🌐 Frontend (Static Web App)
- **URL temporaire** : https://black-island-0b83e3e03.1.azurestaticapps.net
- **Statut** : ✅ Fonctionnel (page par défaut Azure)
- **Domaine cible** : kawoukeravore.top

### 🔧 Backend (App Service)  
- **URL temporaire** : https://kawoukeravore-api-prod.azurewebsites.net
- **Statut** : 🔄 En cours de déploiement (503 Service Unavailable)
- **Domaine cible** : api.kawoukeravore.top

## 📋 Configuration DNS Requise

Vous devez ajouter ces enregistrements DNS chez votre fournisseur de domaine :

### 1. Domaine Principal (Apex Domain)

```dns
Type: TXT
Nom: _dnsauth.kawoukeravore.top
Valeur: _pp1pqkkug8wkpqtb1a4pxxhanxfcqp1
TTL: 300 (5 minutes)
```

### 2. Sous-domaine WWW

```dns
Type: CNAME
Nom: www.kawoukeravore.top
Valeur: black-island-0b83e3e03.1.azurestaticapps.net
TTL: 300 (5 minutes)
```

### 3. Sous-domaine API

```dns
Type: CNAME
Nom: api.kawoukeravore.top  
Valeur: kawoukeravore-api-prod.azurewebsites.net
TTL: 300 (5 minutes)
```

## 🛠️ Étapes de Configuration

### Étape 1: Ajouter les enregistrements DNS
1. Connectez-vous à votre fournisseur de domaine (où kawoukeravore.top est enregistré)
2. Accédez à la gestion DNS
3. Ajoutez les 3 enregistrements ci-dessus
4. Attendez la propagation DNS (5-30 minutes)

### Étape 2: Valider la configuration
Une fois les DNS configurés, testez :

```powershell
# Test du domaine principal
nslookup kawoukeravore.top

# Test du sous-domaine www
nslookup www.kawoukeravore.top

# Test du sous-domaine API
nslookup api.kawoukeravore.top
```

### Étape 3: Finaliser dans Azure
Après la propagation DNS :

```bash
# Finaliser le domaine apex
az staticwebapp hostname set --name kawoukeravore-frontend-prod --resource-group kawoukeravore-rg-prod --hostname kawoukeravore.top

# Ajouter le sous-domaine www
az staticwebapp hostname set --name kawoukeravore-frontend-prod --resource-group kawoukeravore-rg-prod --hostname www.kawoukeravore.top

# Configurer le domaine API  
az webapp config hostname add --webapp-name kawoukeravore-api-prod --resource-group kawoukeravore-rg-prod --hostname api.kawoukeravore.top
```

## 🔒 Certificats SSL

Azure génère automatiquement des certificats SSL gratuits pour :
- ✅ kawoukeravore.top
- ✅ www.kawoukeravore.top  
- ✅ api.kawoukeravore.top

Les certificats sont automatiquement renouvelés.

## 🌍 Fournisseurs DNS Populaires

### OVH
1. Espace client → Domaines → kawoukeravore.top
2. Zone DNS → Modifier
3. Ajouter les enregistrements TXT et CNAME

### Cloudflare  
1. Dashboard → kawoukeravore.top
2. DNS → Records
3. Add record → Sélectionner TXT/CNAME

### GoDaddy
1. Mon compte → Mes domaines  
2. kawoukeravore.top → Gérer DNS
3. Enregistrements → Ajouter

### Gandi
1. Domaines → kawoukeravore.top
2. Enregistrements DNS → Ajouter

## ⏱️ Temps de Propagation

| Fournisseur | Temps typique |
|-------------|---------------|
| Cloudflare  | 1-5 minutes   |
| OVH         | 5-15 minutes  |
| GoDaddy     | 15-60 minutes |
| Gandi       | 5-30 minutes  |

## ✅ Vérification Post-Configuration

Une fois la configuration terminée, ces URLs seront actives :

- 🌐 **https://kawoukeravore.top** → Frontend React
- 🌐 **https://www.kawoukeravore.top** → Redirection vers kawoukeravore.top  
- 🔧 **https://api.kawoukeravore.top** → API Backend
- 🩺 **https://api.kawoukeravore.top/api/health** → Health Check

## 🛠️ Commandes de Test

```powershell
# Test de connectivité
Invoke-WebRequest -Uri "https://kawoukeravore.top"
Invoke-WebRequest -Uri "https://api.kawoukeravore.top/api/health"

# Test DNS
nslookup kawoukeravore.top
nslookup www.kawoukeravore.top  
nslookup api.kawoukeravore.top
```

## 🆘 Dépannage

### Problème : "DNS resolution failed"
- Vérifiez que les enregistrements DNS sont corrects
- Attendez la propagation (jusqu'à 48h max)
- Utilisez un outil comme https://dnschecker.org

### Problème : "Certificate error"  
- Azure génère les certificats après validation DNS
- Peut prendre 15-30 minutes après la configuration

### Problème : "502 Bad Gateway"
- L'API backend est encore en cours de déploiement
- Vérifiez le statut dans le Azure Portal

---

📧 **Support** : Une fois configuré, kawoukeravore.top pointera vers votre plateforme culturelle guadeloupéenne !