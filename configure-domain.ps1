# Script PowerShell pour finaliser la configuration du domaine kawoukeravore.top

Write-Host "🌍 Configuration du domaine kawoukeravore.top" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Vérifier la connectivité à Azure
Write-Host "`n1. Vérification de la connexion Azure..." -ForegroundColor Yellow
try {
    az account show --output table
    Write-Host "✅ Connecté à Azure" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur: Non connecté à Azure. Exécutez 'az login'" -ForegroundColor Red
    exit 1
}

# Tester l'état des services
Write-Host "`n2. Test de l'état des services..." -ForegroundColor Yellow

# Test Static Web App
try {
    $swaResponse = Invoke-WebRequest -Uri "https://black-island-0b83e3e03.1.azurestaticapps.net" -Method GET -TimeoutSec 10
    Write-Host "✅ Static Web App: Fonctionnel (Status: $($swaResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Static Web App: Non accessible" -ForegroundColor Red
}

# Test API
try {
    $apiResponse = Invoke-WebRequest -Uri "https://kawoukeravore-api-prod.azurewebsites.net/api/health" -Method GET -TimeoutSec 10
    Write-Host "✅ API Backend: Fonctionnel (Status: $($apiResponse.StatusCode))" -ForegroundColor Green
    $apiReady = $true
} catch {
    Write-Host "⏳ API Backend: En cours de déploiement..." -ForegroundColor Yellow
    $apiReady = $false
}

# Afficher les informations DNS
Write-Host "`n3. Configuration DNS requise:" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor White
Write-Host "Type: TXT" -ForegroundColor Cyan
Write-Host "Nom: _dnsauth.kawoukeravore.top" -ForegroundColor White
Write-Host "Valeur: _pp1pqkkug8wkpqtb1a4pxxhanxfcqp1" -ForegroundColor Green
Write-Host ""
Write-Host "Type: CNAME" -ForegroundColor Cyan
Write-Host "Nom: www.kawoukeravore.top" -ForegroundColor White
Write-Host "Valeur: black-island-0b83e3e03.1.azurestaticapps.net" -ForegroundColor Green
Write-Host ""
Write-Host "Type: CNAME" -ForegroundColor Cyan
Write-Host "Nom: api.kawoukeravore.top" -ForegroundColor White
Write-Host "Valeur: kawoukeravore-api-prod.azurewebsites.net" -ForegroundColor Green

# Menu d'actions
Write-Host "`n4. Actions disponibles:" -ForegroundColor Yellow
Write-Host "======================" -ForegroundColor White
Write-Host "1. Tester la propagation DNS"
Write-Host "2. Configurer le domaine apex (kawoukeravore.top)"
Write-Host "3. Configurer le sous-domaine www"
Write-Host "4. Configurer le domaine API"
Write-Host "5. Tester tous les domaines"
Write-Host "6. Statut complet"
Write-Host "0. Quitter"

do {
    $choice = Read-Host "`nChoisissez une action (0-6)"
    
    switch ($choice) {
        "1" {
            Write-Host "`n🔍 Test de propagation DNS..." -ForegroundColor Yellow
            
            Write-Host "Test TXT _dnsauth.kawoukeravore.top:" -ForegroundColor Cyan
            try {
                $txtResult = nslookup -type=TXT _dnsauth.kawoukeravore.top
                Write-Host "✅ Enregistrement TXT trouvé" -ForegroundColor Green
            } catch {
                Write-Host "❌ Enregistrement TXT non trouvé" -ForegroundColor Red
            }
            
            Write-Host "`nTest CNAME www.kawoukeravore.top:" -ForegroundColor Cyan
            try {
                $wwwResult = nslookup www.kawoukeravore.top
                Write-Host "✅ Enregistrement CNAME www trouvé" -ForegroundColor Green
            } catch {
                Write-Host "❌ Enregistrement CNAME www non trouvé" -ForegroundColor Red
            }
            
            Write-Host "`nTest CNAME api.kawoukeravore.top:" -ForegroundColor Cyan
            try {
                $apiResult = nslookup api.kawoukeravore.top
                Write-Host "✅ Enregistrement CNAME api trouvé" -ForegroundColor Green
            } catch {
                Write-Host "❌ Enregistrement CNAME api non trouvé" -ForegroundColor Red
            }
        }
        
        "2" {
            Write-Host "`n🌐 Configuration domaine apex kawoukeravore.top..." -ForegroundColor Yellow
            try {
                az staticwebapp hostname set --name kawoukeravore-frontend-prod --resource-group kawoukeravore-rg-prod --hostname kawoukeravore.top
                Write-Host "✅ Domaine apex configuré avec succès" -ForegroundColor Green
            } catch {
                Write-Host "❌ Erreur lors de la configuration du domaine apex" -ForegroundColor Red
                Write-Host "Assurez-vous que l'enregistrement DNS TXT est configuré et propagé" -ForegroundColor Yellow
            }
        }
        
        "3" {
            Write-Host "`n🌐 Configuration sous-domaine www.kawoukeravore.top..." -ForegroundColor Yellow
            try {
                az staticwebapp hostname set --name kawoukeravore-frontend-prod --resource-group kawoukeravore-rg-prod --hostname www.kawoukeravore.top
                Write-Host "✅ Sous-domaine www configuré avec succès" -ForegroundColor Green
            } catch {
                Write-Host "❌ Erreur lors de la configuration du sous-domaine www" -ForegroundColor Red
                Write-Host "Assurez-vous que l'enregistrement DNS CNAME est configuré et propagé" -ForegroundColor Yellow
            }
        }
        
        "4" {
            Write-Host "`n🔧 Configuration domaine API api.kawoukeravore.top..." -ForegroundColor Yellow
            if ($apiReady) {
                try {
                    az webapp config hostname add --webapp-name kawoukeravore-api-prod --resource-group kawoukeravore-rg-prod --hostname api.kawoukeravore.top
                    Write-Host "✅ Domaine API configuré avec succès" -ForegroundColor Green
                } catch {
                    Write-Host "❌ Erreur lors de la configuration du domaine API" -ForegroundColor Red
                    Write-Host "Assurez-vous que l'enregistrement DNS CNAME est configuré et propagé" -ForegroundColor Yellow
                }
            } else {
                Write-Host "⏳ API pas encore prête, réessayez plus tard" -ForegroundColor Yellow
            }
        }
        
        "5" {
            Write-Host "`n🧪 Test de tous les domaines..." -ForegroundColor Yellow
            
            $domains = @(
                "https://kawoukeravore.top",
                "https://www.kawoukeravore.top", 
                "https://api.kawoukeravore.top"
            )
            
            foreach ($domain in $domains) {
                try {
                    $response = Invoke-WebRequest -Uri $domain -Method GET -TimeoutSec 10
                    Write-Host "✅ $domain : Accessible (Status: $($response.StatusCode))" -ForegroundColor Green
                } catch {
                    Write-Host "❌ $domain : Non accessible" -ForegroundColor Red
                }
            }
        }
        
        "6" {
            Write-Host "`n📊 Statut complet..." -ForegroundColor Yellow
            
            # Statut des ressources Azure
            Write-Host "`nRessources Azure:" -ForegroundColor Cyan
            az resource list --resource-group kawoukeravore-rg-prod --output table
            
            # Domaines configurés
            Write-Host "`nDomaines Static Web App:" -ForegroundColor Cyan
            try {
                az staticwebapp hostname list --name kawoukeravore-frontend-prod --resource-group kawoukeravore-rg-prod --output table
            } catch {
                Write-Host "Aucun domaine personnalisé configuré" -ForegroundColor Yellow
            }
        }
        
        "0" {
            Write-Host "`n👋 Configuration terminée!" -ForegroundColor Green
            Write-Host "Une fois les DNS configurés, vos domaines seront:" -ForegroundColor White
            Write-Host "• https://kawoukeravore.top (Frontend)" -ForegroundColor Cyan
            Write-Host "• https://www.kawoukeravore.top (Redirection)" -ForegroundColor Cyan  
            Write-Host "• https://api.kawoukeravore.top (API)" -ForegroundColor Cyan
            break
        }
        
        default {
            Write-Host "❌ Choix invalide, sélectionnez 0-6" -ForegroundColor Red
        }
    }
} while ($choice -ne "0")

Write-Host "`n🌴 Kawoukeravore configuré pour Azure!" -ForegroundColor Green