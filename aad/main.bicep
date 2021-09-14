targetScope = 'subscription'

param principalId string = ''
param aadGroupId string = ''

param configureRbac bool = false
param configureAadGroups bool = false

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
    aadGroupId: aadGroupId
    configureRbac: configureRbac
    configureAadGroups: configureAadGroups
  }
}

output commandText string = 'az aks get-credentials -g ${rg.name} -n ${aks.outputs.name}'
