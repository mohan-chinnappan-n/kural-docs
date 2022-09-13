// AccountRESTController.cls
@RestResource(urlMapping='/Accounts/*')
global with sharing class AccountRESTController {
    @HttpGet
    global static Account getAccountById() {
        RestRequest request = RestContext.request;
        // grab the accountId from the end of the URL
        String accountId = request.requestURI.substring(
          request.requestURI.lastIndexOf('/')+1);
          Account result =  [SELECT Id, Name 
FROM Account
            WHERE Id = :accountId];
          return result;


    }
}