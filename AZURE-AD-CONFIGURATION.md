# 🔐 Configuration Azure AD - kawoukeravore.onmicrosoft.com

## ✅ **Configuration Terminée**

L'App Registration Azure AD a été créée avec succès pour connecter Kawoukeratop avec le tenant `kawoukeravore.onmicrosoft.com`.

## 📋 **Informations de Configuration**

### **Tenant Azure AD**

- **Tenant ID** : `eb99c72c-deb5-4c55-8568-7498a26dc050`
- **Domaine** : Tenant farorudy.com (connecté)
- **Utilisateur** : <dev@farorudy.com>

### **App Registration**

- **Nom** : `kawoukeravore-graph-api`
- **App ID (Client ID)** : `f4234307-755a-4f6d-8e0f-7f8bc792f80d`
- **Client Secret** : `[GÉNÉRÉ - À CONFIGURER DANS GITHUB SECRETS]`

## 🔧 **Secrets GitHub à Configurer**

Allez sur : **<https://github.com/cipfarorudy/kawoukeratop/settings/secrets/actions>**

Ajoutez ces secrets :

### 1. MICROSOFT_TENANT_ID

```
eb99c72c-deb5-4c55-8568-7498a26dc050
```

### 2. MICROSOFT_CLIENT_ID  

```
f4234307-755a-4f6d-8e0f-7f8bc792f80d
```

### 3. MICROSOFT_CLIENT_SECRET

```
[GÉNÉRÉ - VOIR LE SCRIPT setup-azure-ad-simple.ps1 POUR LA VALEUR]
```

## 🛠️ **Permissions Microsoft Graph Requises**

Dans Azure Portal, configurez les permissions suivantes :

### **API Permissions à Ajouter**

1. **Microsoft Graph** → **Application permissions**
   - `Mail.Send` - Envoyer des emails
   - `User.Read.All` - Lire les profils utilisateurs

2. **Microsoft Graph** → **Delegated permissions**
   - `User.Read` - Lire le profil de l'utilisateur connecté
   - `Mail.Send` - Envoyer des emails au nom de l'utilisateur

### **Consentement Administrateur**

⚠️ **IMPORTANT** : Accordez le consentement administrateur pour toutes les permissions.

## 🌐 **URL Azure Portal**

**Configurer les permissions :**
<https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnApi/appId/f4234307-755a-4f6d-8e0f-7f8bc792f80d>

**Vue d'ensemble de l'App :**
<https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/f4234307-755a-4f6d-8e0f-7f8bc792f80d>

## ✨ **Configuration de l'Envoi d'Emails**

Une fois configuré, l'application pourra envoyer des emails via Microsoft Graph depuis :

- **Adresse d'envoi** : `contact@kawoukeravore.top` (si configurée dans le tenant)
- **Ou depuis** : `dev@farorudy.com` (adresse du tenant actuel)

## 🔄 **Prochaines Étapes**

### 1. **Configurer les Permissions** (Obligatoire)

- [ ] Ouvrir Azure Portal (lien ci-dessus)
- [ ] Ajouter les permissions Microsoft Graph
- [ ] Accorder le consentement administrateur

### 2. **Ajouter les Secrets GitHub** (Obligatoire)

- [ ] MICROSOFT_TENANT_ID
- [ ] MICROSOFT_CLIENT_ID  
- [ ] MICROSOFT_CLIENT_SECRET

### 3. **Tester la Configuration**

- [ ] Redéployer l'application (push vers main)
- [ ] Tester l'endpoint `/api/health`
- [ ] Tester l'envoi d'emails via Microsoft Graph

### 4. **Configuration du Domaine Email** (Optionnel)

- Configurer `kawoukeravore.top` comme domaine vérifié dans Azure AD
- Créer une boîte email `contact@kawoukeravore.top`

## 🧪 **Test de Connexion**

Pour tester localement :

```bash
# Variables d'environnement
export AZURE_TENANT_ID="eb99c72c-deb5-4c55-8568-7498a26dc050"
export AZURE_CLIENT_ID="f4234307-755a-4f6d-8e0f-7f8bc792f80d" 
export AZURE_CLIENT_SECRET="[VOIR SCRIPT setup-azure-ad-simple.ps1]"

# Test API
curl https://kawoukeraotop-erh8hzcxhwawhtb7.westus3-01.azurewebsites.net/api/health
```

---

🎯 **Statut** : Configuration Azure AD terminée ✅  
📧 **Contact** : <dev@farorudy.com>  
🔗 **Repository** : <https://github.com/cipfarorudy/kawoukeratop>
