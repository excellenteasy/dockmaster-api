module.exports =
  defaults:
    hostname: 'api.dockmaster.com'
    port: 3100
    httpMethod: 'POST'
    headers:
      # 'content-type': 'application/x-www-form-urlencoded'
      'content-type': 'application/json'
      'connection': 'keep-alive'
      'accept': '*/*'
    params: "{}"
  routes:
    '/workorders':
      GET:
        soapMethod: 'RetrieveWorkOrders'
        params: JSON.stringify {"LastUpdateDate": "", "LastUpdateTime": ""}
    '/customers':
      GET:
        soapMethod: 'RetrieveAllCustomers'
        params: JSON.stringify {"LastModifiedDate": ""}
    '/customerNames':
      GET:
        soapMethod: 'GetCustomerList'
    '/vendors':
      GET:
        soapMethod: 'GetVendorList'
    '/prospects':
      GET:
        soapMethod: 'RetrieveLeads'
        params: JSON.stringify {"LastUpdateDate": "", "ClerkId": ""}
