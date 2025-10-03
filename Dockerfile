# 🌴 Dockerfile pour Kawoukeravore - Déploiement Azure Container Instance
# Multi-stage build pour optimiser la taille finale

# Stage 1: Build du frontend
FROM node:18-alpine AS frontend-builder
WORKDIR /app

# Copier les package.json pour le cache des layers Docker
COPY package*.json ./
COPY apps/web/package*.json ./apps/web/

# Installer les dépendances frontend
RUN npm ci --only=production

# Copier le code source frontend
COPY apps/web ./apps/web

# Build du frontend React avec Vite
WORKDIR /app/apps/web
RUN npm run build

# Stage 2: Setup de l'API
FROM node:18-alpine AS api-builder
WORKDIR /app

# Copier package.json pour l'API
COPY apps/api/package*.json ./

# Installer les dépendances de production uniquement
RUN npm ci --only=production && npm cache clean --force

# Copier le code source de l'API
COPY apps/api ./

# Stage 3: Image finale optimisée
FROM node:18-alpine AS production

# Métadonnées
LABEL maintainer="Kawoukeravore Team <contact@kawoukeravore.top>"
LABEL description="Kawoukeravore - Plateforme culturelle guadeloupéenne"
LABEL version="1.0.0"

# Variables d'environnement par défaut
ENV NODE_ENV=production
ENV PORT=8000
ENV NPM_CONFIG_LOGLEVEL=warn

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S nodejs
RUN adduser -S kawoukeravore -u 1001

# Installer dumb-init pour une gestion propre des signaux
RUN apk add --no-cache dumb-init

# Créer les répertoires de travail
WORKDIR /app
RUN mkdir -p /app/public /app/logs
RUN chown -R kawoukeravore:nodejs /app

# Copier l'API depuis le stage builder
COPY --from=api-builder --chown=kawoukeravore:nodejs /app /app/api

# Copier le frontend buildé
COPY --from=frontend-builder --chown=kawoukeravore:nodejs /app/apps/web/dist /app/public

# Créer un script de démarrage
COPY --chown=kawoukeravore:nodejs <<EOF /app/start.sh
#!/bin/sh
set -e

echo "🌴 Démarrage de Kawoukeravore..."
echo "📍 Environnement: \$NODE_ENV"
echo "🔌 Port: \$PORT"
echo "📁 Répertoire: \$(pwd)"

# Vérifier les fichiers critiques
if [ ! -f "/app/api/src/server.js" ]; then
    echo "❌ Fichier server.js manquant"
    exit 1
fi

if [ ! -d "/app/public" ]; then
    echo "❌ Répertoire public manquant"
    exit 1
fi

echo "✅ Vérifications terminées"

# Démarrer l'application
cd /app/api
exec node src/server.js
EOF

RUN chmod +x /app/start.sh

# Passer à l'utilisateur non-root
USER kawoukeravore

# Exposer le port
EXPOSE 8000

# Vérification de santé
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8000/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => { process.exit(1) })"

# Point d'entrée avec dumb-init pour la gestion des signaux
ENTRYPOINT ["dumb-init", "--"]
CMD ["/app/start.sh"]

# Informations de build (à remplacer par CI/CD)
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Kawoukeravore" \
      org.label-schema.description="Plateforme culturelle guadeloupéenne" \
      org.label-schema.url="https://kawoukeravore.top" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/cipfarorudy/kawoukeravore" \
      org.label-schema.vendor="Kawoukeravore Team" \
      org.label-schema.version=$BUILD_VERSION \
      org.label-schema.schema-version="1.0"