# 🚀 Guide de Configuration Rapide - kawoukeratop

## ✅ Statut actuel

- ✅ Code poussé vers https://github.com/cipfarorudy/kawoukeratop
- ✅ Workflow GitHub Actions configuré 
- ⚠️ Secrets GitHub à configurer pour le déploiement automatique

## 🔐 Secrets à configurer sur GitHub

Allez sur **https://github.com/cipfarorudy/kawoukeratop/settings/secrets/actions** et ajoutez :

### 1. AZURE_CREDENTIALS (Obligatoire)
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "your-subscription-id", 
  "tenantId": "your-tenant-id"
}
```

### 2. AZURE_SUBSCRIPTION_ID
Votre ID de souscription Azure

### 3. AZURE_STATIC_WEB_APPS_API_TOKEN
Token pour déployer vers Azure Static Web Apps

## 🎯 Une fois les secrets configurés

Le workflow se déclenchera automatiquement et déploiera :

1. **Infrastructure Azure** (Bicep)
2. **API Backend** → https://kawoukeraotop-erh8hzcxhwawhtb7.westus3-01.azurewebsites.net
3. **Frontend React** → https://kawoukeravore-frontend-prod.azurestaticapps.net
4. **Tests automatiques**

## 📋 Suivi du déploiement

- **GitHub Actions** : https://github.com/cipfarorudy/kawoukeratop/actions
- **Script de test** : `verify-kawoukeratop-deployment.ps1`

## 🌐 URLs finales attendues

- Frontend : https://kawoukeravore-frontend-prod.azurestaticapps.net
- API : https://kawoukeraotop-erh8hzcxhwawhtb7.westus3-01.azurewebsites.net/api/health
- Domaine : https://kawoukeravore.top (après configuration DNS)

---
**Status** : Prêt pour déploiement automatique 🚀