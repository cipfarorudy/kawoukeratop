# 📧 Configuration du système de contact Kawoukeravore

## ⚙️ Configuration requise

### 1. Variables d'environnement

Créez un fichier `.env` à la racine du projet avec :

```env
# Configuration Email pour Kawoukeravore
MAIL_USER=votre.email@gmail.com
MAIL_PASS=votre_mot_de_passe_application
PORT=4000
```

### 2. Configuration Gmail (recommandée)

1. **Activer la validation en 2 étapes** sur votre compte Google
2. **Générer un mot de passe d'application** :
   - Aller dans : [myaccount.google.com](https://myaccount.google.com)
   - Sécurité → Validation en 2 étapes → Mots de passe des applications
   - Sélectionner "Messagerie" et copier le mot de passe généré
   - Utiliser ce mot de passe dans `MAIL_PASS`

### 3. Autres fournisseurs d'email

Pour Orange, Free, etc., modifiez dans `server.js` :

```javascript
// Exemple pour Orange
service: "smtp.orange.fr"
// ou configuration SMTP personnalisée :
host: "smtp.orange.fr",
port: 587,
secure: false,
```

## 🚀 Démarrage

### Option 1 : Démarrage séparé (recommandé pour le développement)

```bash
# Terminal 1 : Serveur backend
npm run server

# Terminal 2 : Frontend React
npm run dev
```

### Option 2 : Démarrage simultané

```bash
npm run start:full
```

## 📝 URLs

- **Frontend React** : http://localhost:5173 (ou port suivant)
- **Backend API** : http://localhost:4000
- **Test serveur** : http://localhost:4000/api/health

## 🧪 Test du système

1. Démarrez le serveur backend avec `npm run server`
2. Vérifiez avec : http://localhost:4000/api/health
3. Démarrez le frontend avec `npm run dev`
4. Testez le formulaire de contact

## 📂 Structure des fichiers

```
kawoukeravore/
├── server.js              # Serveur Express + Nodemailer
├── .env                   # Variables d'environnement (secret)
├── src/pages/Contact.jsx  # Formulaire React intégré
└── package.json           # Scripts npm
```

## ⚠️ Sécurité

- Le fichier `.env` est dans `.gitignore` et ne sera pas commité
- Utilisez toujours des mots de passe d'application, jamais votre mot de passe principal
- En production, configurez des variables d'environnement sur votre hébergeur

## 🎯 Fonctionnalités

- ✅ Validation des données côté serveur
- ✅ Gestion des erreurs
- ✅ CORS configuré pour le développement
- ✅ Indicateur de chargement
- ✅ Messages de succès/erreur
- ✅ Format HTML + texte dans les emails