# 🌴 Kawoukeravore - Monorepo

Plateforme web dédiée à la promotion de la culture guadeloupéenne - architecture monorepo moderne.

## 🏗️ Structure du projet

```
kawoukeravore/
├── apps/
│   ├── web/                    # Frontend React + Vite + Tailwind
│   │   ├── src/
│   │   ├── public/
│   │   ├── package.json
│   │   └── vite.config.js
│   └── api/                    # Backend Express + Nodemailer
│       ├── src/
│       │   └── server.js
│       ├── .env
│       └── package.json
├── package.json                # Configuration workspace racine
└── README.md
```

## 🚀 Démarrage rapide

### 1. Installation des dépendances

```bash
# Installation globale (racine + tous les workspaces)
npm run install:all
```

### 2. Configuration de l'API

Créez le fichier `apps/api/.env` :

```env
# Configuration Email
MAIL_USER=votre.email@gmail.com
MAIL_PASS=votre_mot_de_passe_application
MAIL_TO=contact@kawoukeravore.com

# Port du serveur API
PORT=4000
```

### 3. Lancement du développement

```bash
# Option 1: Lancement simultané (recommandé)
npm run start:full

# Option 2: Lancement séparé
# Terminal 1 - API Backend
npm run api:dev

# Terminal 2 - Frontend React  
npm run dev
```

## 📱 URLs du développement

- **Frontend (React)** : http://localhost:5173 (ou port suivant)
- **API Backend** : http://localhost:4000
- **API Health Check** : http://localhost:4000/api/health

## 🛠️ Scripts disponibles

### Scripts racine (monorepo)

| Commande | Description |
|----------|-------------|
| `npm run dev` | Lance le frontend en mode développement |
| `npm run build` | Build de production du frontend |
| `npm run preview` | Preview du build frontend |
| `npm run api:dev` | Lance l'API avec hot-reload |
| `npm run api:start` | Lance l'API en mode production |
| `npm run start:full` | Lance API + Frontend simultanément |
| `npm run install:all` | Installe toutes les dépendances |

### Scripts frontend (apps/web/)

| Commande | Description |
|----------|-------------|
| `npm run dev` | Serveur de développement Vite |
| `npm run build` | Build de production |
| `npm run preview` | Preview du build |
| `npm run lint` | Lint du code |

### Scripts API (apps/api/)

| Commande | Description |
|----------|-------------|
| `npm run dev` | Serveur avec nodemon (hot-reload) |
| `npm run start` | Serveur de production |

## 🔧 Technologies utilisées

### Frontend (apps/web/)
- **React 19** - Framework frontend moderne
- **Vite** - Build tool ultra-rapide
- **Tailwind CSS** - Framework CSS utility-first
- **React Router** - Routing côté client
- **ESLint** - Linting du code

### Backend (apps/api/)
- **Express.js** - Framework web Node.js
- **Nodemailer** - Envoi d'emails
- **Zod** - Validation et parsing de schémas
- **Helmet** - Sécurisation des headers HTTP
- **Express Rate Limit** - Protection contre le spam
- **CORS** - Gestion des requêtes cross-origin
- **Nodemon** - Hot-reload en développement

## 🔒 Sécurité

### Protection backend
- **Helmet.js** : Sécurisation des headers HTTP
- **Rate Limiting** : Max 5 emails / IP / 15 minutes
- **Validation Zod** : Validation stricte des données d'entrée
- **CORS configuré** : Restriction des origines autorisées
- **Variables d'environnement** : Gestion sécurisée des secrets

### Validation des données
- **Nom** : 2-50 caractères, lettres et espaces uniquement
- **Email** : Format email valide, max 100 caractères  
- **Message** : 10-1000 caractères, filtrage HTML

## � Configuration email

### Gmail (recommandé)

1. **Activer la validation 2 étapes** sur votre compte Google
2. **Générer un mot de passe d'application** :
   - Aller dans [myaccount.google.com](https://myaccount.google.com)
   - Sécurité → Validation 2 étapes → Mots de passe d'applications
   - Sélectionner "Messagerie" et copier le mot de passe généré

3. **Configurer le .env** :
```env
MAIL_USER=votre.email@gmail.com
MAIL_PASS=mot_de_passe_application_généré
MAIL_TO=destinataire@kawoukeravore.com
```

### Autres fournisseurs

Pour Orange, Free, etc., modifier dans `apps/api/src/server.js` :

```javascript
// Configuration SMTP personnalisée
host: "smtp.orange.fr",
port: 587,
secure: false,
```

## 🚀 Déploiement

### Frontend
- **Vercel** / **Netlify** : Déploiement automatique depuis Git
- **Build** : `npm run build` génère le dossier `dist/`

### Backend  
- **Railway** / **Render** / **Heroku** : Plateformes PaaS
- **VPS** : Avec PM2 pour la gestion des processus
- **Docker** : Containerisation possible

### Variables d'environnement production
```env
NODE_ENV=production
MAIL_USER=email@production.com
MAIL_PASS=password_securise
MAIL_TO=contact@kawoukeravore.com  
PORT=4000
```

## 🐛 Debug & Logs

### Logs API
- ✅ **Succès** : Emails envoyés avec détails
- ❌ **Erreurs** : Validation, SMTP, serveur
- 📊 **Rate limiting** : Tentatives bloquées
- 🔒 **Sécurité** : Requêtes suspectes

### Health Check
```bash
curl http://localhost:4000/api/health
```

## 📝 Contribution

1. Fork du projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commiter les changements (`git commit -m 'Ajout nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

Made with ❤️ for Guadeloupe 🌴
