# 🚀 Déploiement Automatique GitHub Actions - DÉMARRAGE RAPIDE

## ⚡ Option 1: Script Automatique (Recommandé)

### Prérequis
- Azure CLI installé : `winget install Microsoft.AzureCLI`
- GitHub CLI installé : `winget install GitHub.GitHubCLI`
- Token GitHub avec permissions repo/admin : https://github.com/settings/tokens

### Exécution
```powershell
# Lancer le script de configuration automatique
.\setup-github-actions.ps1 -GitHubToken "YOUR_GITHUB_TOKEN" -AzureSubscriptionId "YOUR_SUBSCRIPTION_ID"
```

---

## ⚙️ Option 2: Configuration Manuelle

### Étape 1: Créer le Service Principal Azure
```bash
az login
az ad sp create-for-rbac --name "kawoukeravore-github-actions" --role contributor --scopes /subscriptions/{SUBSCRIPTION-ID} --json-auth
```

### Étape 2: Créer le Resource Group
```bash
az group create --name kawoukeravore-rg-prod --location "West Europe"
```

### Étape 3: Configurer les Secrets GitHub
Aller sur : `https://github.com/cipfarorudy/kawoukeravore/settings/secrets/actions`

#### Secrets Obligatoires :
- `AZURE_CREDENTIALS` → JSON du service principal
- `AZURE_SUBSCRIPTION_ID` → Votre ID d'abonnement  
- `AZURE_STATIC_WEB_APPS_API_TOKEN` → Token Static Web App

#### Secrets Optionnels :
- `MICROSOFT_CLIENT_ID`, `MICROSOFT_CLIENT_SECRET`, `MICROSOFT_TENANT_ID`
- `WHATSAPP_VERIFY_TOKEN`, `WHATSAPP_ACCESS_TOKEN`  
- `JWT_SECRET` → Généré avec `openssl rand -base64 32`

---

## 🚀 Déclenchement du Déploiement

### Push automatique
```bash
git add .
git commit -m "🚀 Deploy to Azure with GitHub Actions"
git push origin main
```

### Déploiement manuel
1. Aller sur : `https://github.com/cipfarorudy/kawoukeravore/actions`
2. Sélectionner "Deploy Kawoukeravore to Azure"
3. Cliquer "Run workflow"

---

## 📊 Surveillance

- **GitHub Actions** : https://github.com/cipfarorudy/kawoukeravore/actions
- **Azure Portal** : https://portal.azure.com
- **Frontend** : https://kawoukeravore-frontend-prod.azurestaticapps.net
- **API** : https://kawoukeravore-api-prod.azurewebsites.net/api/health

---

## 🔧 En cas de problème

1. **Vérifier les logs GitHub Actions**
2. **Vérifier les secrets GitHub**  
3. **Tester l'authentification Azure** : `az login`
4. **Consulter** : `GITHUB-ACTIONS-SETUP.md` pour le guide détaillé

---

**⏱️ Temps de déploiement** : ~10-15 minutes  
**💰 Coût Azure** : ~21€/mois  
**🔄 Fréquence** : Automatique à chaque push sur `main`