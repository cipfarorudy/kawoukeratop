@echo off
REM Script de test de déploiement local Kawoukeravore
REM Usage: test-deployment.bat

setlocal enabledelayedexpansion

echo [32m=============================================[0m
echo [32m   🧪 Test de Deploiement Kawoukeravore    [0m
echo [32m=============================================[0m
echo.

:: Configuration
set PROJECT_NAME=kawoukeravore
set API_PORT=4000
set WEB_PORT=5173

echo [36m[TEST][0m Verification de l'environnement de test...

:: Vérifier Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [31m[ERREUR][0m Node.js n'est pas installe
    pause
    exit /b 1
)

:: Vérifier npm
where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo [31m[ERREUR][0m npm n'est pas disponible
    pause
    exit /b 1
)

:: Vérifier PM2
where pm2 >nul 2>&1
if %errorlevel% neq 0 (
    echo [33m[ATTENTION][0m PM2 n'est pas installe. Installation...
    call npm install -g pm2
)

echo [32m[INFO][0m ✅ Environnement de test pret
echo.

:: Installation des dépendances si nécessaire
echo [36m[TEST][0m Verification des dependances...
if not exist "node_modules" (
    echo [32m[INFO][0m Installation des dependances racine...
    call npm install
)

if not exist "apps\web\node_modules" (
    echo [32m[INFO][0m Installation des dependances frontend...
    cd apps\web
    call npm install
    cd ..\..
)

if not exist "apps\api\node_modules" (
    echo [32m[INFO][0m Installation des dependances API...
    cd apps\api
    call npm install
    cd ..\..
)

echo [32m[INFO][0m ✅ Dependances verifiees
echo.

:: Test du build frontend
echo [36m[TEST][0m Test du build frontend...
call npm run build
if %errorlevel% neq 0 (
    echo [31m[ERREUR][0m Echec du build frontend
    pause
    exit /b 1
)

if not exist "apps\web\dist\index.html" (
    echo [31m[ERREUR][0m Fichier build manquant: index.html
    pause
    exit /b 1
)

echo [32m[INFO][0m ✅ Build frontend reussi
echo.

:: Configuration de l'environnement de test
echo [36m[TEST][0m Configuration de l'environnement de test...
cd apps\api

if not exist ".env" (
    echo [32m[INFO][0m Creation du fichier .env de test...
    echo NODE_ENV=development > .env
    echo PORT=%API_PORT% >> .env
    echo FRONTEND_URL=http://localhost:%WEB_PORT% >> .env
    echo API_URL=http://localhost:%API_PORT%/api >> .env
    echo CORS_ORIGIN=http://localhost:%WEB_PORT% >> .env
    echo JWT_SECRET=test_jwt_secret_for_development_only >> .env
    echo LOG_LEVEL=debug >> .env
    echo HEALTH_CHECK_PATH=/api/health >> .env
    echo # Configuration de test - NE PAS UTILISER EN PRODUCTION >> .env
)

echo [32m[INFO][0m ✅ Environnement de test configure
cd ..\..
echo.

:: Test de l'API
echo [36m[TEST][0m Test de l'API...
cd apps\api

:: Arrêter les anciens processus de test
pm2 delete kawoukeravore-test-api 2>nul
pm2 delete kawoukeravore-test-web 2>nul

:: Démarrer l'API en mode test
echo [32m[INFO][0m Demarrage de l'API de test...
pm2 start src\server.js --name kawoukeravore-test-api

:: Attendre que l'API démarre
timeout /t 3 /nobreak >nul

:: Tester si l'API répond
where curl >nul 2>&1
if %errorlevel% equ 0 (
    echo [32m[INFO][0m Test de l'endpoint de sante...
    curl -f -s http://localhost:%API_PORT%/api/health >nul 2>&1
    if !errorlevel! equ 0 (
        echo [32m[INFO][0m ✅ API de test operationnelle
    ) else (
        echo [33m[ATTENTION][0m ⚠️  API peut ne pas repondre correctement
    )
) else (
    echo [33m[ATTENTION][0m curl non disponible. Test API ignore.
)

cd ..\..
echo.

:: Test du frontend en mode dev (optionnel)
echo [36m[TEST][0m Preparation du serveur frontend de test...
cd apps\web

:: Créer un .env pour le frontend de test si nécessaire
if not exist ".env" (
    echo VITE_API_URL=http://localhost:%API_PORT%/api > .env
    echo VITE_NODE_ENV=development >> .env
)

:: Démarrer le serveur de développement en arrière-plan
echo [32m[INFO][0m Demarrage du serveur frontend de test...
start /B npm run dev

cd ..\..
echo.

:: Afficher les informations de test
echo [32m[INFO][0m 🎉 Environnement de test pret!
echo.
echo 📱 URLs de test:
echo    🌐 Frontend (dev): http://localhost:%WEB_PORT%
echo    🌐 Frontend (build): Fichiers dans apps\web\dist\
echo    🔧 API: http://localhost:%API_PORT%/api/health
echo.
echo 📊 Commandes utiles:
echo    pm2 status                    # Voir les processus de test
echo    pm2 logs kawoukeravore-test-api  # Logs de l'API
echo    pm2 stop kawoukeravore-test-api  # Arreter l'API de test
echo    npm run dev --workspace=apps/web # Demarrer le frontend manuellement
echo.
echo 🧪 Tests recommandes:
echo    1. Ouvrir http://localhost:%WEB_PORT% dans le navigateur
echo    2. Verifier que les pages se chargent
echo    3. Tester le formulaire de contact
echo    4. Verifier la galerie d'images
echo    5. Tester la responsivite mobile
echo.

:: Ouvrir le navigateur automatiquement
echo [32m[INFO][0m Ouverture du navigateur pour les tests...
timeout /t 2 /nobreak >nul
start http://localhost:%WEB_PORT%
start http://localhost:%API_PORT%/api/health

echo 🔄 Le serveur frontend demarre... Patientez quelques secondes
echo ⏹️  Appuyez sur une touche pour arreter les serveurs de test
pause >nul

:: Nettoyage
echo.
echo [36m[NETTOYAGE][0m Arret des serveurs de test...
pm2 delete kawoukeravore-test-api 2>nul
pm2 delete kawoukeravore-test-web 2>nul

:: Tuer les processus Node.js restants sur les ports de test
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%API_PORT%') do (
    taskkill /PID %%a /F 2>nul
)
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%WEB_PORT%') do (
    taskkill /PID %%a /F 2>nul
)

echo [32m[INFO][0m ✅ Nettoyage termine
echo.
echo 🌴 Tests de deploiement Kawoukeravore termines
echo 📋 Resultats sauvegardes dans les logs PM2
echo.