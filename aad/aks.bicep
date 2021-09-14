param principalId string
param aadGroupId string
param configureRbac bool
param configureAadGroups bool

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: 'aks'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.21.2'
    dnsPrefix: 'aks'
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 1
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
      }
    ]
    aadProfile: {
      enableAzureRBAC: true
      adminGroupObjectIDs: configureAadGroups ? [
        aadGroupId
      ] : []
      managed: true
    }
  }
}

var aksRbacWriterRoleDefinitionId = 'a7ffa36f-339b-4b5c-8bdf-e2c188b2c0eb'

resource rbac 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = if (configureRbac) {
  name: guid(principalId, aksRbacWriterRoleDefinitionId)
  scope: aksCluster
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', aksRbacWriterRoleDefinitionId)
  }
}

output name string = aksCluster.name
