targetScope = 'subscription'

param principalId string = ''

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'aks'
  location: deployment().location
  tags: {
    test: 'true'
  }
}

module aks 'aks.bicep' = {
  name: '${deployment().name}-aks'
  scope: rg
  params: {
    principalId: principalId
  }
}

output commandText string = 'az aks get-credentials -g ${rg.name} -n ${aks.outputs.name}'
