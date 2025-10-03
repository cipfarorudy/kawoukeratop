# Configuration des Secrets pour kawoukeratop Repository

## Secrets GitHub nécessaires pour le déploiement Azure

Pour que le déploiement automatique fonctionne sur le repository `kawoukeratop`, vous devez configurer les secrets suivants dans GitHub :

### 1. Secrets Azure (Obligatoires)

```
AZURE_CREDENTIALS
AZURE_SUBSCRIPTION_ID
AZURE_STATIC_WEB_APPS_API_TOKEN
```

### 2. Secrets Microsoft Graph (Pour l'envoi d'emails)

```
MICROSOFT_CLIENT_ID
MICROSOFT_CLIENT_SECRET
MICROSOFT_TENANT_ID
```

### 3. Secrets WhatsApp (Optionnels)

```
WHATSAPP_VERIFY_TOKEN
WHATSAPP_ACCESS_TOKEN
```

### 4. Secrets de sécurité

```
JWT_SECRET
```

## Comment configurer les secrets

1. Allez sur https://github.com/cipfarorudy/kawoukeratop
2. Cliquez sur **Settings** > **Secrets and variables** > **Actions**
3. Cliquez sur **New repository secret**
4. Ajoutez chaque secret un par un

## AZURE_CREDENTIALS - Format JSON

```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret", 
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

## Commandes pour récupérer les valeurs Azure

```bash
# Se connecter à Azure
az login

# Créer un service principal pour GitHub Actions
az ad sp create-for-rbac --name "kawoukeratop-github-actions" \
  --role contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
  --sdk-auth

# Récupérer l'ID de souscription
az account show --query id --output tsv

# Récupérer le token Static Web Apps
az staticwebapp secrets list --name kawoukeravore-frontend-prod --resource-group kawoukeravore-rg-prod --query properties.apiKey --output tsv
```

## URLs de déploiement

- **Frontend**: https://kawoukeravore-frontend-prod.azurestaticapps.net
- **API**: https://kawoukeraotop-erh8hzcxhwawhtb7.westus3-01.azurewebsites.net  
- **Domaine personnalisé**: https://kawoukeravore.top

## Vérification du déploiement

Une fois les secrets configurés, poussez du code vers `main` pour déclencher le déploiement automatique :

```bash
git push kawoukeratop main
```

Le workflow GitHub Actions se déclenchera automatiquement et déploiera :
1. L'infrastructure Azure (Bicep)
2. L'API Node.js vers App Service
3. Le frontend React vers Static Web Apps
4. Les tests de santé post-déploiement