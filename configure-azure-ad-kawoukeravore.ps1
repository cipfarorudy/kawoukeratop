# Script de Configuration Azure AD pour kawoukeravore.onmicrosoft.com
# Ce script configure l'intégration Microsoft Graph avec votre tenant Azure AD

param(
    [Parameter(Mandatory=$false)]
    [string]$TenantDomain = "kawoukeravore.onmicrosoft.com",
    
    [Parameter(Mandatory=$false)]
    [string]$AppName = "kawoukeravore-graph-api",
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubRepo = "cipfarorudy/kawoukeratop"
)

Write-Host "🔐 Configuration Azure AD pour $TenantDomain" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# 1. Vérifier la connexion Azure et obtenir les informations du tenant
Write-Host "`n1. Vérification du tenant Azure AD..." -ForegroundColor Yellow
try {
    # Obtenir les informations du tenant actuel
    $tenantInfo = az account show --query "{tenantId: tenantId, name: name, user: user.name}" -o json | ConvertFrom-Json
    Write-Host "✅ Connecté au tenant: $($tenantInfo.tenantId)" -ForegroundColor Green
    Write-Host "   Utilisateur: $($tenantInfo.user)" -ForegroundColor Gray
    
    # Vérifier si nous sommes sur le bon tenant
    $tenantDetails = az ad tenant list --query "[?contains(domains[0], 'kawoukeravore') || contains(domains[0], '$TenantDomain')]" -o json | ConvertFrom-Json
    if ($tenantDetails) {
        Write-Host "✅ Tenant kawoukeravore trouvé" -ForegroundColor Green
        $kawoukeraTenantId = $tenantDetails[0].tenantId
    } else {
        Write-Host "⚠️  Tenant kawoukeravore non trouvé dans la liste accessible" -ForegroundColor Yellow
        $kawoukeraTenantId = $tenantInfo.tenantId
        Write-Host "   Utilisation du tenant actuel: $kawoukeraTenantId" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Erreur de connexion Azure: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Créer ou vérifier l'App Registration
Write-Host "`n2. Configuration de l'App Registration..." -ForegroundColor Yellow
try {
    # Vérifier si l'app existe déjà
    $existingApp = az ad app list --display-name $AppName --query "[0]" -o json | ConvertFrom-Json
    
    if ($existingApp) {
        Write-Host "✅ App Registration '$AppName' existe déjà" -ForegroundColor Green
        $appId = $existingApp.appId
        $objectId = $existingApp.id
        Write-Host "   App ID: $appId" -ForegroundColor Gray
    } else {
        # Créer une nouvelle App Registration
        Write-Host "📝 Création de l'App Registration '$AppName'..." -ForegroundColor Cyan
        
        $newApp = az ad app create --display-name $AppName --query "{appId: appId, id: id}" -o json | ConvertFrom-Json
        $appId = $newApp.appId
        $objectId = $newApp.id
        
        Write-Host "✅ App Registration créée avec succès" -ForegroundColor Green
        Write-Host "   App ID: $appId" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Erreur lors de la création de l'App Registration: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Configurer les permissions Microsoft Graph
Write-Host "`n3. Configuration des permissions Microsoft Graph..." -ForegroundColor Yellow
try {
    # Permissions requises pour Microsoft Graph
    $requiredPermissions = @(
        "Mail.Send",
        "User.Read",
        "User.Read.All"
    )
    
    Write-Host "📋 Ajout des permissions Microsoft Graph..." -ForegroundColor Cyan
    foreach ($permission in $requiredPermissions) {
        try {
            az ad app permission add --id $appId --api 00000003-0000-0000-c000-000000000000 --api-permissions "b633e1c5-b582-4048-a93e-9f11b44c7e96=Scope" 2>$null
            Write-Host "   ✅ $permission" -ForegroundColor Gray
        } catch {
            Write-Host "   ⚠️  $permission (peut-être déjà ajouté)" -ForegroundColor Yellow
        }
    }
    
    # Accorder le consentement admin (si possible)
    Write-Host "🔐 Tentative d'octroi du consentement administrateur..." -ForegroundColor Cyan
    try {
        az ad app permission admin-consent --id $appId 2>$null
        Write-Host "✅ Consentement administrateur accordé" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Consentement administrateur requis manuellement" -ForegroundColor Yellow
        Write-Host "   Allez sur: https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnApi/appId/$appId" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Erreur configuration permissions: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Créer un secret client
Write-Host "`n4. Génération du secret client..." -ForegroundColor Yellow
try {
    $secretName = "kawoukeravore-github-secret-$(Get-Date -Format 'yyyyMM')"
    $clientSecret = az ad app credential reset --id $appId --display-name $secretName --query password -o tsv
    
    if ($clientSecret) {
        Write-Host "✅ Secret client généré avec succès" -ForegroundColor Green
        Write-Host "   ⚠️  IMPORTANT: Sauvegardez ce secret immédiatement!" -ForegroundColor Yellow
    } else {
        throw "Impossible de générer le secret client"
    }
} catch {
    Write-Host "❌ Erreur génération secret: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 5. Résumé de la configuration
Write-Host "`n📊 RÉSUMÉ DE LA CONFIGURATION" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "🏢 Tenant ID: $kawoukeraTenantId" -ForegroundColor Green
Write-Host "📱 App ID (Client ID): $appId" -ForegroundColor Green
Write-Host "🔐 Client Secret: $($clientSecret.Substring(0,8))..." -ForegroundColor Green
Write-Host "🌐 Tenant Domain: $TenantDomain" -ForegroundColor Green

# 6. Secrets GitHub à configurer
Write-Host "`n🔧 SECRETS GITHUB À CONFIGURER" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "Repository: https://github.com/$GitHubRepo/settings/secrets/actions"
Write-Host ""
Write-Host "MICROSOFT_CLIENT_ID:"
Write-Host $appId -ForegroundColor White
Write-Host ""
Write-Host "MICROSOFT_CLIENT_SECRET:"
Write-Host $clientSecret -ForegroundColor White
Write-Host ""
Write-Host "MICROSOFT_TENANT_ID:"
Write-Host $kawoukeraTenantId -ForegroundColor White

# 7. Commandes pour configurer les secrets (si gh CLI est disponible)
Write-Host "`n💻 COMMANDES DE CONFIGURATION" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "# Si vous avez gh CLI installé:"
Write-Host "gh secret set MICROSOFT_CLIENT_ID --body `"$appId`" --repo $GitHubRepo" -ForegroundColor Gray
Write-Host "gh secret set MICROSOFT_CLIENT_SECRET --body `"$clientSecret`" --repo $GitHubRepo" -ForegroundColor Gray  
Write-Host "gh secret set MICROSOFT_TENANT_ID --body `"$kawoukeraTenantId`" --repo $GitHubRepo" -ForegroundColor Gray

# 8. Test de connexion (optionnel)
Write-Host "`n🧪 TEST DE CONNEXION" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "Pour tester la configuration, utilisez ces variables d'environnement:" -ForegroundColor Yellow
Write-Host "AZURE_TENANT_ID=$kawoukeraTenantId"
Write-Host "AZURE_CLIENT_ID=$appId"
Write-Host "AZURE_CLIENT_SECRET=$clientSecret"

Write-Host "`n🎉 Configuration Azure AD terminée!" -ForegroundColor Green
Write-Host "Prochaines étapes:" -ForegroundColor Yellow
Write-Host "1. Ajouter les secrets dans GitHub (voir ci-dessus)" -ForegroundColor White
Write-Host "2. Redéployer l'application pour appliquer les changements" -ForegroundColor White
Write-Host "3. Tester l'envoi d'emails via Microsoft Graph" -ForegroundColor White