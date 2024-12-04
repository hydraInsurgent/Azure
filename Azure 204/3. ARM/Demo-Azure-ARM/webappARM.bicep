@description('The location to deploy the service resources')
param location string = resourceGroup().location

@description('The prefix to give all resource names')
param resourcePrefix string

var resourceName = toLower('${resourcePrefix}-${uniqueString(resourceGroup().id)}')

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: resourceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: resourceName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: workspace.id
  }
}

var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: take(replace(resourceName, '-', ''), 24)
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

resource storageAccountTableServices 'Microsoft.Storage/storageAccounts/tableServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource storageAccountTableWidgets 'Microsoft.Storage/storageAccounts/tableServices/tables@2022-09-01' = {
  name: 'widgets'
  parent: storageAccountTableServices
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: resourceName
  location: location
  kind: 'app'
  sku: {
    name: 'S1'
  }
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: resourceName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    storageAccountRequired: false
    clientCertMode: 'Optional'
    clientCertExclusionPaths: '/health'
    siteConfig: {
      healthCheckPath: '/health'
      alwaysOn: true
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v6.0'
    }
  }

  resource stack 'config@2022-03-01' = {
    name: 'metadata'
    properties: {
      CURRENT_STACK: 'dotnet'
    }
  }
}

resource appServiceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${resourceName}-diagnostics'
  scope: appService
  properties: {
    workspaceId: workspace.id
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource appSettings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  parent: appService
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
    'Storage:ConnectionString': '@Microsoft.KeyVault(SecretUri=${secretStorageAccountConnectionString.properties.secretUri})'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: take(resourceName, 24)
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
    enableRbacAuthorization: true
  }
}

resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${resourceName}-diagnostics'
  scope: keyVault
  properties: {
    workspaceId: workspace.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
      {
        category: 'AzurePolicyEvaluationDetails'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource secretStorageAccountConnectionString 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'StorageAccountConnectionString'
  parent: keyVault
  properties: {
    value: storageAccountConnectionString
  }
}

output appServiceName string = appService.name
