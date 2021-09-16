resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: uniqueString(subscription().subscriptionId)
  location: resourceGroup().location
  kind: 'FileStorage'
  sku: {
    name: 'Premium_LRS'
  }
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }

  resource fileShare 'fileServices' = {
    name: 'default'

    resource share 'shares' = {
      name: 'data'
      properties: {
        shareQuota: 1024
      }
    }
  }
}

output accountName string = base64(storageaccount.name)
output accountKey string = base64(storageaccount.listKeys().keys[0].value)
output shareName string = storageaccount::fileShare::share.name
