param subnetId string
param logAnalyticsWorkspaceId string
param storageAccountId string

var segments = split(subnetId, '/')

var serviceCidr = '10.100.2.0'

var serviceOctals = split(serviceCidr, '.')

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: segments[8]
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: last(segments)
  parent: vnet
}

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
        vnetSubnetID: subnetId
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      serviceCidr: '${serviceCidr}/24'
      dnsServiceIP: '${serviceOctals[0]}.${serviceOctals[1]}.${serviceOctals[2]}.10'
    }
  }
}

var networkContributorRoleId = '4d97b98b-1d4f-4787-a291-c67834d212e7'

resource rbac 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(aksCluster.id, networkContributorRoleId)
  scope: subnet
  properties: {
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
  }
}

var logs = [
  'kube-apiserver'
  'kube-audit'
  'kube-audit-admin'
  'kube-controller-manager'
  'kube-scheduler'
  'cluster-autoscaler'
  'guard'
]

var metrics = [
  'AllMetrics'
]

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'default'
  scope: aksCluster
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
    logs: [for log in logs: {
      category: log
      enabled: true
      retentionPolicy: {
        days: 7
        enabled: true
      }
    }]
    metrics: [for metric in metrics: {
      category: metric
      enabled: true
      retentionPolicy: {
        days: 7
        enabled: true
      }
    }]
  }
}

output name string = aksCluster.name
