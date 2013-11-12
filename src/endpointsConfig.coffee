module.exports =
  defaults:
    hostname: 'api.dockmaster.com'
    port: 3105
    httpMethod: 'POST'
    headers:
      'content-type': 'application/json'
      'connection': 'keep-alive'
      'accept': '*/*'
  routes:
    '/workorders':
      GET:
        soapMethod: 'RetrieveWorkOrders'
        params: JSON.stringify {"LastUpdateDate": "", "LastUpdateTime": ""}
    '/workorders/:id':
      GET:
        soapMethod: 'RetrieveWorkOrders'
        params: JSON.stringify {"LastUpdateDate": "", "LastUpdateTime": ""}
    '/prospects':
      GET:
        soapMethod: 'RetrieveNewLeads'
        params: JSON.stringify {"NumberToRetrieve": "1"}
    '/customers':
      GET:
        soapMethod: 'RetrieveAllCustomers'
        params: JSON.stringify {"LastModifiedDate": ""}
