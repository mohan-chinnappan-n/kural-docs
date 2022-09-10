@isTest 
private class Wrike_Test {
	
    static testMethod void validate() {
    	insertTestSettings();
        Wrike_AbstractSectionController.validate_AbstractSectionController();
        Wrike_AuthorizeController.validate_AuthorizeController();
        Wrike_FolderController.validate_FolderController();
    }
    
    private static User insertTestUser()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      	User u = new User(Alias = 'test', Email='testuser@44dev.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      	LocaleSidKey='en_US', ProfileId = p.Id, 
     	TimeZoneSidKey='America/Los_Angeles', UserName='testuser@44dev.com');
        
        return u;
    }

    public static void insertTestSettings()
    {        
        WrikeAccountSettings__c newSetting = new WrikeAccountSettings__c(setupOwnerId = System.Userinfo.getOrganizationId());
        insert newSetting;
    }
}