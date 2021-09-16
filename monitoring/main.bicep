targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'aks'
  location: deployment().location
  tags: {
    test: 'true'
  }
}

module vnet 'vnet.bicep' = {
  name: '${deployment().name}-vnet'
  scope: rg
}

module log 'log.bicep' = {
  name: '${deployment().name}-log'
  scope: rg
}

module storage 'storage.bicep' = {
  name: '${deployment().name}-storage'
  scope: rg
}

module aks 'aks.bicep' = {
  name: '${deployment().name}-aks'
  scope: rg
  params: {
    subnetId: vnet.outputs.subnetId
    logAnalyticsWorkspaceId: log.outputs.id
    storageAccountId: storage.outputs.id
  }
}

output commandText string = 'az aks get-credentials -g ${rg.name} -n ${aks.outputs.name}'
