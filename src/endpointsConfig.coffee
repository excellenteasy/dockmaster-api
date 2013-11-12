module.exports =
  defaults:
    hostname: 'api.dockmaster.com'
    port: 3105
    httpMethod: 'POST'
    headers:
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
