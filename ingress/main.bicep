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

module aks 'aks.bicep' = {
  name: '${deployment().name}-aks'
  scope: rg
  params: {
    aksSubnetId: vnet.outputs.aksSubnetId
    agwSubnetId: vnet.outputs.agwSubnetId
  }
}

output commandText string = 'az aks get-credentials -g ${rg.name} -n ${aks.outputs.name}'
