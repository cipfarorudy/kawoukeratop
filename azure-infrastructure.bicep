@description('Infrastructure Azure pour Kawoukeravore - Plateforme culturelle guadeloupéenne')
param projectName string = 'kawoukeravore'
param environment string = 'prod'
param location string = resourceGroup().location
param customDomain string = 'kawoukeravore.top'

// Variables calculées
var appServicePlanName = '${projectName}-asp-${environment}'
var webAppName = '${projectName}-api-${environment}'
var staticWebAppName = '${projectName}-frontend-${environment}'
var storageAccountName = '${projectName}storage${environment}'
var keyVaultName = '${projectName}-kv-${environment}'
var applicationInsightsName = '${projectName}-ai-${environment}'
var logAnalyticsName = '${projectName}-log-${environment}'

// App Service Plan (Production ready)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'  // Basic tier pour commencer, upgradeable vers Standard/Premium
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true  // Nécessaire pour Linux
  }
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Kawoukeravore API Backend'
  }
}

// Web App (API Backend)
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      appCommandLine: 'npm start'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      appSettings: [
        {
          name: 'NODE_ENV'
          value: 'production'
        }
        {
          name: 'PORT'
          value: '8000'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '18-lts'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'ENABLE_ORYX_BUILD'
          value: 'true'
        }
        {
          name: 'FRONTEND_URL'
          value: 'https://${staticWebAppName}.azurestaticapps.net'
        }
        {
          name: 'API_URL'
          value: 'https://${webAppName}.azurewebsites.net/api'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
    }
    httpsOnly: true
    clientAffinityEnabled: false
    publicNetworkAccess: 'Enabled'
  }
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Kawoukeravore API Backend'
  }
}

// Static Web App (Frontend React)
resource staticWebApp 'Microsoft.Web/staticSites@2023-01-01' = {
  name: staticWebAppName
  location: 'West Europe'  // Static Web Apps disponible dans certaines régions
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    buildProperties: {
      appLocation: '/apps/web'
      outputLocation: 'dist'
      appBuildCommand: 'npm run build'
    }
    repositoryUrl: 'https://github.com/cipfarorudy/kawoukeravore'
    branch: 'main'
  }
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Kawoukeravore Frontend React'
  }
}

// Storage Account pour les fichiers statiques et médias
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Kawoukeravore Media Storage'
  }
}

// Container pour les images de la galerie
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccountName}/default/galerie'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'Blob'
  }
  dependsOn: [
    storageAccount
  ]
}

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-03-15-preview' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
  tags: {
    Environment: environment
    Project: projectName
  }
}

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: {
    Environment: environment
    Project: projectName
  }
}

// Key Vault pour les secrets
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false
    tenantId: subscription().tenantId
    accessPolicies: []
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
  tags: {
    Environment: environment
    Project: projectName
  }
}

// Outputs pour les autres déploiements
output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output staticWebAppName string = staticWebApp.name
output staticWebAppUrl string = 'https://${staticWebApp.properties.defaultHostname}'
output storageAccountName string = storageAccount.name
output keyVaultName string = keyVault.name
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString
output resourceGroupName string = resourceGroup().name
