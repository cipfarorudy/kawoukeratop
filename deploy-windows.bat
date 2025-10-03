@echo off
REM Script de déploiement Windows pour Kawoukeravore
REM Usage: deploy-windows.bat [frontend|api|full]

setlocal enabledelayedexpansion

:: Configuration
set PROJECT_NAME=kawoukeravore
set DOMAIN=kawoukeravore.top
set REPO_URL=https://github.com/cipfarorudy/kawoukeravore.git
set WEB_ROOT=C:\inetpub\wwwroot\%PROJECT_NAME%
set API_PORT=4000
set NODE_ENV=production

:: Couleurs (non supportées nativement dans cmd)
echo [32m=============================================[0m
echo [32m   🚀 Deploiement Kawoukeravore Windows    [0m
echo [32m=============================================[0m
echo.

:: Vérification Node.js
echo [36m[STEP][0m Verification des prerequis...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [31m[ERROR][0m Node.js n'est pas installe
    echo Installez Node.js depuis: https://nodejs.org/
    pause
    exit /b 1
)

where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo [31m[ERROR][0m npm n'est pas disponible
    pause
    exit /b 1
)

where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [31m[ERROR][0m Git n'est pas installe
    echo Installez Git depuis: https://git-scm.com/
    pause
    exit /b 1
)

echo [32m[INFO][0m ✅ Prerequis valides
echo.

:: Clone ou mise à jour du repository
echo [36m[STEP][0m Configuration du repository...
if exist "%WEB_ROOT%" (
    echo [32m[INFO][0m Repository existant trouve. Mise a jour...
    cd /d "%WEB_ROOT%"
    git fetch origin
    git reset --hard origin/main
    git clean -fd
) else (
    echo [32m[INFO][0m Clonage du repository...
    git clone %REPO_URL% "%WEB_ROOT%"
    cd /d "%WEB_ROOT%"
)

git checkout main
git pull origin main

echo [32m[INFO][0m ✅ Repository configure
echo.

:: Installation des dépendances
echo [36m[STEP][0m Installation des dependances...
echo [32m[INFO][0m Installation des dependances racine...
call npm install

echo [32m[INFO][0m Installation des dependances frontend...
cd apps\web
call npm install
cd ..\..

echo [32m[INFO][0m Installation des dependances API...
cd apps\api
call npm install --production
cd ..\..

if exist "apps\whatsapp-bot" (
    echo [32m[INFO][0m Installation des dependances WhatsApp Bot...
    cd apps\whatsapp-bot
    call npm install --production
    cd ..\..
)

echo [32m[INFO][0m ✅ Dependances installees
echo.

:: Gestion des arguments
set DEPLOYMENT_TYPE=%1
if "%DEPLOYMENT_TYPE%"=="" set DEPLOYMENT_TYPE=full

if "%DEPLOYMENT_TYPE%"=="frontend" goto :deploy_frontend
if "%DEPLOYMENT_TYPE%"=="api" goto :deploy_api
if "%DEPLOYMENT_TYPE%"=="full" goto :deploy_full

:deploy_frontend
echo [36m[STEP][0m Deploiement frontend uniquement...
goto :build_frontend

:deploy_api
echo [36m[STEP][0m Deploiement API uniquement...
goto :setup_api

:deploy_full
echo [36m[STEP][0m Deploiement complet...

:build_frontend
:: Build du frontend
echo [36m[STEP][0m Build du frontend React...
call npm run build

if not exist "apps\web\dist" (
    echo [31m[ERROR][0m Le build du frontend a echoue
    pause
    exit /b 1
)

:: Copier les fichiers vers IIS (si configuré)
echo [32m[INFO][0m Copie des fichiers frontend...
if exist "C:\inetpub\wwwroot" (
    if not exist "C:\inetpub\wwwroot\%PROJECT_NAME%" mkdir "C:\inetpub\wwwroot\%PROJECT_NAME%"
    xcopy /e /y "apps\web\dist\*" "C:\inetpub\wwwroot\%PROJECT_NAME%\"
    echo [32m[INFO][0m ✅ Fichiers copies vers IIS
) else (
    echo [33m[WARN][0m IIS non detecte. Fichiers disponibles dans: apps\web\dist\
)

if "%DEPLOYMENT_TYPE%"=="frontend" goto :completion

:setup_api
:: Configuration de l'API
echo [36m[STEP][0m Configuration de l'API...
cd apps\api

:: Copier le fichier .env s'il n'existe pas
if not exist ".env" (
    if exist ".env.production" (
        echo [32m[INFO][0m Utilisation du fichier .env.production
        copy ".env.production" ".env"
    ) else if exist ".env.example" (
        echo [33m[WARN][0m Fichier .env manquant. Copie depuis .env.example
        copy ".env.example" ".env"
        echo [33m[WARN][0m ⚠️  IMPORTANT: Configurez les variables dans apps\api\.env
    ) else (
        echo [31m[ERROR][0m Aucun fichier .env trouve
        pause
        exit /b 1
    )
)

:: Vérifier PM2 et l'installer si nécessaire
where pm2 >nul 2>&1
if %errorlevel% neq 0 (
    echo [32m[INFO][0m Installation de PM2...
    call npm install -g pm2
)

:: Arrêter les anciens processus PM2
echo [32m[INFO][0m Arret des anciens processus...
pm2 delete kawoukeravore-api 2>nul
pm2 delete kawoukeravore-whatsapp 2>nul

:: Démarrer l'API
echo [32m[INFO][0m Demarrage de l'API avec PM2...
set NODE_ENV=%NODE_ENV%
pm2 start src\server.js --name kawoukeravore-api

:: Démarrer le bot WhatsApp s'il existe
if exist "..\whatsapp-bot" (
    echo [32m[INFO][0m Demarrage du bot WhatsApp...
    cd ..\whatsapp-bot
    pm2 start src\index.js --name kawoukeravore-whatsapp
    cd ..\api
)

:: Sauvegarder la configuration PM2
pm2 save

echo [32m[INFO][0m ✅ API configuree et demarree

cd ..\..

if "%DEPLOYMENT_TYPE%"=="api" goto :completion

:tests
:: Tests de déploiement
echo [36m[STEP][0m Tests de deploiement...

:: Afficher le statut PM2
echo [32m[INFO][0m Statut des processus PM2:
pm2 status

:: Test simple de l'API (si curl est disponible)
where curl >nul 2>&1
if %errorlevel% equ 0 (
    echo [32m[INFO][0m Test de l'API...
    curl -f -s http://localhost:%API_PORT%/api/health >nul 2>&1
    if !errorlevel! equ 0 (
        echo [32m[INFO][0m ✅ API operationnelle
    ) else (
        echo [33m[WARN][0m ⚠️  API peut ne pas etre accessible
    )
) else (
    echo [33m[WARN][0m curl non disponible. Tests automatiques ignores.
)

:completion
:: Informations finales
echo.
echo [32m[INFO][0m 🎉 Deploiement termine avec succes!
echo.
echo 📱 Informations de deploiement:
if exist "C:\inetpub\wwwroot\%PROJECT_NAME%" (
    echo    🌐 Frontend: Configure pour IIS
)
echo    🔧 API: http://localhost:%API_PORT%/api/health
echo    📞 WhatsApp: Configure via l'API
echo.
echo 📊 Commandes utiles:
echo    pm2 status          # Voir les processus
echo    pm2 logs            # Voir les logs
echo    pm2 restart all     # Redemarrer tous les processus
echo    pm2 stop all        # Arreter tous les processus
echo.
echo 🌐 Pour configurer un serveur web (IIS/Apache/Nginx):
echo    - Pointez le document root vers: %WEB_ROOT%\apps\web\dist
echo    - Configurez un reverse proxy vers: http://localhost:%API_PORT%
echo.

:: Ouvrir le navigateur sur localhost si possible
echo Ouverture du navigateur...
start http://localhost:%API_PORT%

pause