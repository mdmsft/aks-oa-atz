param principalId string

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
      managed: true
    }
    addonProfiles: {
      azurePolicy:{
        enabled: true
      }
    }
  }
}

var aksRbacClusterAdminRoleDefinitionId = 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'

resource rbac 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(principalId, aksRbacClusterAdminRoleDefinitionId)
  scope: aksCluster
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', aksRbacClusterAdminRoleDefinitionId)
  }
}

var policyInitialiveDefinitionId = '/providers/Microsoft.Authorization/policySetDefinitions/a8640138-9b0a-4a28-b8cb-1666c838647d'

resource policy 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'AKS cluster pod security baseline standards for Linux workloads'
  scope: aksCluster
  properties: {
    policyDefinitionId: policyInitialiveDefinitionId
    parameters: {
      effect: {
        value: 'deny'
      }
      namespaces: {
        value: [
          'default'
          'contoso'
        ]
      }
    }
  }
}

output name string = aksCluster.name
