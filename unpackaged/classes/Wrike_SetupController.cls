public with sharing class Wrike_SetupController extends Wrike_AbstractSectionController {
        
        ApexPages.StandardController controller;
        
        private WrikeAccountSettings__c settings;
        
        public Wrike_SetupController() {            
            super(ApexPages.currentPage().getUrl());
            settings = WrikeAccountSettings__c.getOrgDefaults(); // instantiates if null
        }
        
        public String state { get; set; }
        
        public String userId { get; set; }
        
        public String userName { get; set; }
        
        public String userEmail { get; set; }
        
        public String accountsJSON { get; set; }
        
        public String accountName { get; set; }
        
        public Boolean enableSharing { get; set; }

        public String objectsJSON { get; set; }
        
        public String bindingsJSON { get; set; }
        
        public boolean hasMultipleAccounts { get; private set;}
         
        public PageReference ensureWrike() {
            
            // Check Metadata access
            
            if(!checkMetadataAPIConnection()) {
				return new PageReference('/apex/Wrike_RemoteSettings');
            }

			// Check API keys
			if (String.isBlank(settings.WrikeClientId__c ) || String.isBlank(settings.WrikeClientSecret__c)) {
				upsert settings;
				PageReference page = new PageReference('/apex/Wrike_OAuthPage');
				page.setRedirect(true);
				return page;
            }
			
			// Check Wrike access
            String userBody = getUserJSON();
            state = parseJSON(userBody, 'error');
    
            if (state == 'not_authorized') {    
                if (refreshExpiredToken()) {
                     
                   PageReference page = new PageReference(ApexPages.currentPage().getUrl());
                   page.setRedirect(true);
                   return page;
                }
            }
    
            if (state != null || userBody == null) {
                return null;
            }
            
            JSONParser parser = JSON.createParser(userBody);
            
            String firstName = '';
            String lastName = '';
            
            while (parser.nextToken() != null) {
                if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    if(parser.getText() == 'id'){
                        parser.nextToken();
                        userId = parser.getText();
                    } else if(parser.getText() == 'firstName'){
                        parser.nextToken();
                        firstName = parser.getText();
                    } else if(parser.getText() == 'lastName'){
                        parser.nextToken();
                        lastName = parser.getText();
                    } else if(parser.getText() == 'email'){
                        parser.nextToken();
                       userEmail = parser.getText();
                    }
                }
            }
            
            userName = firstName + ' ' + lastName;
            
            // Check SalesForce permittions
                 
            if(!isAdministrator()) {
                state = 'no_priveledges';
                return null;
            }
            
            // Read available accounts
            
            Map<String,String> accounts = getAccounts();
            if (accounts == null || accounts.size() == 0){
                state = 'error';
                return null;
            }
            else if (accounts.size() > 1) 
            			hasMultipleAccounts = true;
            
            JSONGenerator generator = JSON.createGenerator(false);
            generator.writeObject(accounts);
            accountsJSON = generator.getAsString();

            // Check customizations enabled
            if (settings.WrikeAccountId__c == null) {
            	
            	if (accounts.size() == 1) {
            		
            		List<String> accountIds =  new List<String>(accounts.keySet());
       				String accountId = accountIds.get(0);

		            saveAccountToSettings(accountId);
		            PageReference page = new PageReference(
                 	ApexPages.currentPage().getUrl().split('\\?')[0]);
            		
            		page.setRedirect(true);
		            return page;
	            }
	            	
                state = 'no_account';
                return null;
            }
            
            // Check Wrike account
            if (!accounts.containsKey(settings.WrikeAccountId__c)) {
                state = 'not_listed';
                return null;
            }
            
            accountName = accounts.get(settings.WrikeAccountId__c);
            
            generator = JSON.createGenerator(false);
            generator.writeObject(getObjects());
            objectsJSON = generator.getAsString();
            
            generator = JSON.createGenerator(false);
            generator.writeObject(getBindings());
            bindingsJSON = generator.getAsString();
            
            //foldersJSON = getFoldersJSON(settings.WrikeAccountId__c);
            
            state = 'ok';
            return null;
        }
        
        private String createSalesforceFolder(String accountId) {
        	
        	String accountBody = wrikeApiGet('/accounts/' + accountId);
        	String rootFolderId = parseJSON(accountBody, 'rootFolderId');
        	
        	String sharedId = getMyTeamId(accountId);
        	System.debug('===sharedId: ' + sharedId);
        	String folderBody = wrikeApiPost('/folders/' + rootFolderId + '/folders',
	                'title=Salesforce'
	                + (String.isBlank(sharedId) ? '' : '&shareds=["' + sharedId + '"]'));
	        return parseJSON(folderBody, 'id');
        }
        
        private String getMyTeamId(String accountId)
        {
        	String myTeamId;
        	
        	String accountUsers = wrikeApiGet('/accounts/' + accountId + '/contacts');

        	JSONParser parser = JSON.createParser(accountUsers);

        	boolean isFoundMyTeam = false;
        	while (parser.nextToken() != null) {
	            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
	                if(parser.getText() == 'id') {
	                    parser.nextToken();
	                    myTeamId = parser.getText();
	                }
	                if(parser.getText() == 'myTeam') {
	                    parser.nextToken();
	                    if(parser.getCurrentToken() == JSONToken.VALUE_TRUE) {
	                    	isFoundMyTeam = true;
	                    	break;
	                    }
	                }
	            }
	        }
	        if(!isFoundMyTeam) myTeamId = '';
        	return myTeamId;
        }
        
        public PageReference saveApiKeys() {
   			String clientId = ApexPages.currentPage().getParameters().get('clientId');
   			String clientSecret = ApexPages.currentPage().getParameters().get('clientSecret');

            return saveOAuthKeys(clientId, clientSecret);
        }
        
        public PageReference getOAuthKeys()
        {
        	Map<String, String> oauthKeys = WrikeWebHook.registerOauthClient(getSalesforceHost());
        	System.debug('oauthKeys: ' + oauthKeys);

    		String clientId = oauthKeys.get('clientId');
			String clientSecret = oauthKeys.get('clientSecret');
			return saveOAuthKeys(clientId, clientSecret);
        }
        
        private PageReference saveOAuthKeys(String clientId, String clientSecret)
        {
        	if (isAdministrator() && !String.IsBlank(clientId) && !String.IsBlank(clientSecret)) {
            	
            	Http http = new Http();
        		HttpRequest req = new HttpRequest();
        		req.setEndpoint(WRIKE_DOMAIN + '/oauth2/authorize?response_type=code&client_id=' + clientId);
        		req.setMethod('GET');
        
		        HttpResponse res = http.send(req);
		        String error = parseJSON(res.getBody(), 'error');
		       
            	if (error == null) {
            		if (settings == null) settings = new WrikeAccountSettings__c(setupOwnerId = System.Userinfo.getOrganizationId());
	            	settings.WrikeClientId__c = clientId;
	            	settings.WrikeClientSecret__c = clientSecret;
	            	upsert settings;
	            	PageReference page = new PageReference('/apex/Wrike_SetupPage');
	            	page.setRedirect(true);
	            	return page;
            	}
            }
			state = 'no_apikeys';
			//return null;
			return sendOAuthSupportRequest();
        }
        
        private PageReference sendOAuthSupportRequest()
        {
        	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        	email.setToAddresses(new String[] {'support@team.wrike.com'});
            email.setSubject('Salesforce integration app personal keys');
            string emailBody = '--- Auto-generated by Wrike Salesforce Integration Package ---\r\n'
                                + 'Company Name: ' + UserInfo.getOrganizationName() + '\r\n'
                                + 'Salesforce Org Id: ' + UserInfo.getOrganizationId() + '\r\n'
                                + 'Contact Name: ' + UserInfo.getName() + '\r\n'
                                + 'Contact Email: ' + UserInfo.getUserEmail() + '\r\n'
                                + 'Redirect URI: ' + getSalesforceHost();                               
                                
            email.setPlainTextBody(emailBody);
            Messaging.SendEmailResult [] res = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        	
        	return null;
        }
        
        private void saveAccountToSettings(String accountId) {
    		
    		if (settings == null) {
                settings = new WrikeAccountSettings__c(setupOwnerId = System.Userinfo.getOrganizationId());
            }
            settings.OwnerId__c = UserInfo.getUserId();      
            settings.WrikeAccountId__c = accountId;
            settings.SalesforceFolderId__c = createSalesforceFolder(accountId);
            
            upsert settings;
            
            resetBindings();
        }
        
        public PageReference saveAccount() {
        	
        	String accountId = ApexPages.currentPage().getParameters().get('accountId');
            
             if (isAdministrator() && accountId != null) {
                saveAccountToSettings(accountId);
            }
            
            PageReference page = new PageReference(
                 ApexPages.currentPage().getUrl().split('\\?')[0]);
            page.setRedirect(true);
            return page;
        }
        
        public PageReference resetSettings() {
            
            if (isAdministrator() && settings != null) { //check bindings also
                settings.OwnerId__c = null;      
            	settings.WrikeAccountId__c = null;
            	settings.SalesforceFolderId__c = null;
            
            	upsert settings;
            	//resetBindings();
            }
            
            PageReference page = new PageReference(
                 ApexPages.currentPage().getUrl().split('\\?')[0]);
            page.setRedirect(true);
            return page;
        }
        
        private void resetBindings()
        {
        	List<Wrike_Bindings__c> bindings = Wrike_Bindings__c.getAll().values();
        	
        	for(Wrike_Bindings__c binding : bindings)
        	{
        		 binding.ParentId__c = null;
        	}
        	update bindings;
        }
               
        public PageReference saveBinding() {
                
            if (isAdministrator() && settings != null) {
                String name = ApexPages.currentPage().getParameters().get('name');
                String typee  = ApexPages.currentPage().getParameters().get('type');
                String rule = ApexPages.currentPage().getParameters().get('rule');
                String parentFolderId = ApexPages.currentPage().getParameters().get('folderId');
                
                Wrike_Bindings__c binding = 
                    Wrike_Bindings__c.getValues(name);
                if (binding == null) {
                    binding = new Wrike_Bindings__c(Name = name);
                    binding.Type__c = typee;
                    
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(name);
                  //  String label = objType.getDescribe().getLabel();
                    
                    createCustomField(name, binding.Type__c); 
                    createPage(name, binding.Type__c);
                }
                binding.Rule__c = rule;
                binding.ParentId__c = parentFolderId;
                
                upsert binding;
            }

            PageReference page = new PageReference(
                 ApexPages.currentPage().getUrl().split('\\?')[0]);
            page.setRedirect(true);
            return page;
        }
        
        public PageReference addBinding() {
                
            if (isAdministrator() && settings != null) {
                String name = ApexPages.currentPage().getParameters().get('name');

                Wrike_Bindings__c binding = Wrike_Bindings__c.getValues(name);
                if (binding != null) return null; 

                binding = new Wrike_Bindings__c(Name = name);
                binding.Type__c = 'FOLDER';
                binding.Rule__c = 'AUTO';

                Schema.SObjectType objType = Schema.getGlobalDescribe().get(name);
              //  String label = objType.getDescribe().getLabel();
                String labelPlural = objType.getDescribe().getLabelPlural();
                                
                createCustomField(name, binding.Type__c); 
                createPage(name, binding.Type__c);
                
                if(isFolderDeleted(settings.SalesforceFolderId__c)) {
                	 settings.SalesforceFolderId__c = createSalesforceFolder(settings.WrikeAccountId__c);               	 
                }
                
                String folderBody = wrikeApiPost('/folders/'
                	+ settings.SalesforceFolderId__c + '/folders',
	                'title=' + EncodingUtil.urlEncode(labelPlural, 'UTF-8'));
	             System.debug('folderBody: ' + folderBody);   
                binding.ParentId__c = parseJSON(folderBody, 'id');
            
                upsert binding;
                upsert settings;
            }

            PageReference page = new PageReference(
                 ApexPages.currentPage().getUrl().split('\\?')[0]);
            page.setRedirect(true);
            return page;
        }       
        
        public PageReference deleteBinding() {
            if (isAdministrator()) {
                
                String name = ApexPages.currentPage().getParameters().get('name');
                Wrike_Bindings__c binding =  Wrike_Bindings__c.getValues(name);             
                if (binding != null) {
                    
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(name);
                    String label = objType.getDescribe().getLabel();
                    
                    if (!deletePage(name, binding.Type__c)) return null;
                    deleteCustomField(name, binding.Type__c);
                    
                    Map<String,Object> bindings = getBindings();
                    bindings.remove(name);

                    delete binding;
                    
                    JSONGenerator generator = JSON.createGenerator(false);
                    generator.writeObject(bindings);
                    bindingsJSON = generator.getAsString();
                }
            }
            return null;
        }
        
        private Boolean isAdministrator() {
            Profile sfUserProfile = [SELECT
                Name,
                PermissionsAuthorApex,
                PermissionsAPIEnabled,
                PermissionsCustomizeApplication,
                PermissionsViewSetup,
                PermissionsViewAllUsers,
                PermissionsViewAllData,
                PermissionsManageSharing,
                PermissionsManageIPAddresses
                FROM Profile WHERE Id = :UserInfo.getProfileId()];

            return sfUserProfile.PermissionsAuthorApex &&
                sfUserProfile.PermissionsAPIEnabled &&
                sfUserProfile.PermissionsCustomizeApplication &&
                sfUserProfile.PermissionsViewSetup &&
                sfUserProfile.PermissionsViewAllUsers &&
                sfUserProfile.PermissionsViewAllData &&
                sfUserProfile.PermissionsManageSharing &&
                sfUserProfile.PermissionsManageIPAddresses;
        }
        
        private String getUserJSON() {
          return wrikeApiGet('/contacts/?me');
        }
        
        private Map<String,String> getAccounts() {
            String accountsBody = wrikeApiGet('/accounts/');
            if (accountsBody == null) {
                return null;
            }
          
            Map<String,String> result = new Map<String,String>();
            String error = null;
            JSONParser parser = JSON.createParser(accountsBody);
            
            String id = null, name = null;          
            while (parser.nextToken() != null) {
                if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    if(parser.getText() == 'id'){
                        parser.nextToken();
                        id = parser.getText();
                    } else if(parser.getText() == 'name'){
                        parser.nextToken();
                        name = parser.getText();
                    } else if(parser.getText() == 'error'){
                        parser.nextToken();
                        error = parser.getText();
                    }
                }
                else if(parser.getCurrentToken() == JSONToken.END_OBJECT){
                    if (id != null && name != null) {
                        result.put(id, name);
                    }
                    id = null;
                    name = null;
                }
            }
            
            return (error == null)? result : null;
        }
        
        private List<Object> getObjects() {
            
            // Standard objects list with extandable fields is taken from
            // http://www.salesforce.com/us/developer/docs/object_reference/Content/sforce_api_objects_custom_objects.htm#i1436378
            
            Set<String> standardObjectNames = new Set<String> { 
                'Account','Campaign','Case','Contact','Contract','Event',
                'Lead','Opportunity','Product2','Solution','Task','User' };
            
            List<Object> objects = new List<Object>();
                
            //Put custom objects here too
            List<Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe().Values();    

            for(Schema.SObjectType obj : globalDescribe) {
                DescribeSObjectResult describe = obj.getDescribe();
                if (standardObjectNames.contains(describe.getName()) ||
                        describe.isCustom() && !describe.isCustomSetting() ) {
                    
                    Map<String,Object> props = new Map<String,Object>();
                    props.put('name', describe.getName());
                    props.put('label', describe.getLabel());
                    props.put('labelPlural', describe.getLabelPlural()); 
                    props.put('custom', describe.isCustom());
                    
                    Map<String, Schema.SobjectField> fieldsmap = 
                        describe.fields.getMap();
                    
                    props.put('wrikeTaskField', fieldsmap.containsKey('Wrike_Task_ID__c'));
                    props.put('wrikeFolderField', fieldsmap.containsKey('Wrike_Folder_ID__c'));

                    System.debug(Logginglevel.INFO, describe);
                    objects.add(props);
                }
            }
            
            return objects;
        }
        
        private Map<String,Object> getBindings() {
            Map<String,Object> bindingsMap = new Map<String,Object>();
            for (Wrike_Bindings__c binding : Wrike_Bindings__c.getAll().values()) {
                Map<String,String> bindingParams = new Map<String,String>();
                bindingParams.put('type', binding.Type__c);
                bindingParams.put('rule', binding.Rule__c);
                bindingParams.put('parentId', binding.ParentId__c);
                bindingParams.put('nameTemplate', binding.NameTemplate__c);
                bindingsMap.put(binding.Name, bindingParams);
            }
            return bindingsMap;
        }
        
        public static Boolean createCustomField(String objName, String typee) {
            
            String field = getCustomFieldName(typee);
                
            // tasks and events share Activity object custom fields 
            if('Task'.equals(objName) || 'Event'.equals(objName)) objName = 'Activity';
                                
            MetadataService.MetadataPort service = createService();     
            MetadataService.CustomField customField = new MetadataService.CustomField();
            customField.fullName = objName + '.' + field + '__c';
            customField.label = field;
            customField.type_x = 'Text';
            customField.length = 42;
            List<MetadataService.SaveResult> results =      
                service.createMetadata(
                    new MetadataService.Metadata[] { customField });                
            
            MetadataService.SaveResult result = results[0];
            System.debug(Logginglevel.INFO, result);
            return result==null || result.success;
        }
        
        public static Boolean deleteCustomField(String objName, String typee) {
            
            String field = getCustomFieldName(typee);
               
            if('Task'.equals(objName) || 'Event'.equals(objName))
            {
           		Wrike_Bindings__c coupledBinding =  Wrike_Bindings__c.getValues('Task'.equals(objName) ? 'Event' : 'Task');
           		if (coupledBinding != null) return false;
           		objName = 'Activity';
            }
                                
            MetadataService.MetadataPort service = createService();     
            List<MetadataService.DeleteResult> results =        
            service.deleteMetadata(
                'CustomField', new String[] { objName + '.' + field + '__c' });            
            
            MetadataService.DeleteResult result = results[0];
            System.debug(Logginglevel.INFO, result);
            return result==null || result.success;
        }
        
        private static String getCustomFieldName(String typee)
        {
        	return (typee == 'FOLDER')?
                'Wrike_Folder_ID' : 'Wrike_Task_ID';
        }
    
    
        public static Boolean createPage(String objName, String typee) {
            
            String sourcePageName = getSourcePageName(typee);
            String controllerString = (typee == 'FOLDER')?
                'Wrike_FolderController' : 'Wrike_TaskController';
            
            String searchString = 'controller="' +  controllerString + '"';
            String replaceString = + 'standardController="'+ objName +'" '+
                'extensions="' +  controllerString + '"';
            
            MetadataService.MetadataPort service = createService();     
            MetadataService.IReadResult readResult =        
                    service.readMetadata('ApexPage', new String[] { sourcePageName });
            MetadataService.Metadata[] records = readResult.getRecords();
        
            MetadataService.ApexPage sourcePage = (MetadataService.ApexPage) records[0];
            String source = EncodingUtil.base64Decode(sourcePage.content).toString(); 
            
            Integer i = source.indexOf(searchString); 
            if (i < 0) return false;
            
            Integer len = searchString.length();
            String modifiedSource =
                    source.substring(0, i) + replaceString + source.substring(i + len);
            
            String targetPageName = getTargetPageName(objName, sourcePageName);
            String labelName = (typee == 'FOLDER')? 'Wrike Tasks' : 'Wrike Task';

            MetadataService.ApexPage apexPage = new MetadataService.ApexPage();
            apexPage.apiVersion = 31;
            apexPage.fullName = targetPageName;
            apexPage.label = labelName;
            apexPage.content = EncodingUtil.base64Encode(Blob.valueOf(modifiedSource));
            List<MetadataService.SaveResult> results = 
                    service.createMetadata(new MetadataService.Metadata[] { apexPage });                
            
            MetadataService.SaveResult saveResult = results[0];
            System.debug(Logginglevel.INFO, saveResult);
            //autoadding to layouts disabled
            if (ApexPages.currentPage().getParameters().containsKey('modifylayouts')) {
            	addApexPageToLayouts(targetPageName, objName, service);
            }
            return saveResult==null || saveResult.success;
        }
        
        private static String getTargetPageName(String objName, String sourcePageName)
        {
        	return (sourcePageName + '_' + objName).replaceAll('__c','_c'); // double underscores are not allowed
        }
        
        private static String getSourcePageName(String typee)
        {
        	return (typee == 'FOLDER')? 'Wrike_FolderView' : 'Wrike_TaskView';
        }
        
        private static void addApexPageToLayouts(final String apexPageName, final String objectName, final MetadataService.MetadataPort service) {
            final String[] objectLayoutNames = listObjectLayouts(objectName, service);
            if(!objectLayoutNames.isEmpty()) {
                MetadataService.Metadata[] layouts = service.readMetadata('Layout', objectLayoutNames).getRecords();
                for(MetadataService.Layout layout : (MetadataService.Layout[])layouts) {
                    if(layout.layoutSections == null) {
                        layout.layoutSections = new List<MetadataService.LayoutSection>();
                    } 
                    MetadataService.LayoutSection section = new MetadataService.LayoutSection();
                    section.style = 'OneColumn';
                    MetadataService.LayoutColumn column = new MetadataService.LayoutColumn();
                    MetadataService.LayoutItem layoutItem = new MetadataService.LayoutItem();
                    layoutItem.page_x = apexPageName;
                    layoutItem.height = 355;
                    layoutItem.width = '100%';
                    column.layoutItems = new List<MetadataService.LayoutItem> { layoutItem }; 
                    section.layoutColumns = new List<MetadataService.LayoutColumn> { column };        
                    layout.layoutSections.add(section); 
                }                  
                service.updateMetadata(layouts);
            }
        }
        
        private static void removeApexPageFromLayouts(final String apexPageName, final String objectName, final MetadataService.MetadataPort service) {
            final String[] objectLayoutNames = listObjectLayouts(objectName, service);
            if(!objectLayoutNames.isEmpty()) {
                MetadataService.Metadata[] layouts = service.readMetadata('Layout', objectLayoutNames).getRecords();
                MetadataService.Metadata[] updatedLayouts = new MetadataService.Metadata[] {};
                for(MetadataService.Layout layout : (MetadataService.Layout[])layouts) {
                    final MetadataService.Layout updatedLayout = removeApexPageFromLayout(layout, apexPageName);
                    if(updatedLayout != null) {
                        updatedLayouts.add(updatedLayout);
                    }
                } 
                if(!updatedLayouts.isEmpty()) {
                    service.updateMetadata(updatedLayouts);
                }                 
            }
        }
        
        private static MetadataService.Layout removeApexPageFromLayout(final MetadataService.Layout layout, final String apexPageName) {
            if(layout.layoutSections != null) {
                for(Integer s = 0; s < layout.layoutSections.size(); s++) {
                    final MetadataService.LayoutSection section = layout.layoutSections[s];
                    if(section.layoutColumns != null) {
                        for(MetadataService.LayoutColumn column : section.layoutColumns) {
                            if(column.layoutItems != null) {
                                for(Integer i=0; i < column.layoutItems.size(); i++) {
                                    if(column.layoutItems[i].page_x == apexPageName) {
                                        if(section.layoutColumns.size() == 1 && column.layoutItems.size() == 1) {
                                            layout.layoutSections.remove(s);    
                                        } else {
                                            column.layoutItems.remove(i);
                                        }
                                        return layout;
                                    }
                                }
                            }
                        }
                    }
                     
                }
            }
            if(layout.relatedContent != null && layout.relatedContent.relatedContentItems != null) {
                for(Integer i = 0; i < layout.relatedContent.relatedContentItems.size(); i++) {
                    final MetadataService.RelatedContentItem contentItem = layout.relatedContent.relatedContentItems[i];
                    if(contentItem.layoutItem != null && contentItem.layoutItem.page_x == apexPageName) {
                        layout.relatedContent.relatedContentItems.remove(i);
                        return layout;
                    }
                }
            }
            return null;
        }
        
        private static String[] listObjectLayouts(final String objectName, final MetadataService.MetadataPort service) {
            MetadataService.ListMetadataQuery layoutQuery = new MetadataService.ListMetadataQuery();
            layoutQuery.type_x = 'Layout';
            MetadataService.FileProperties[] layoutMetaList = service.listMetadata(new List<MetadataService.ListMetadataQuery> { layoutQuery }, 31);
            String[] objectLayoutNames = new String[] {};
            for(MetadataService.FileProperties layoutMeta : layoutMetaList) {
                if(layoutMeta.fullName.startsWith(objectName + '-')) {
                    objectLayoutNames.add(layoutMeta.fullName);
                }
            }
            return objectLayoutNames;
        }
        
        public static Boolean deletePage(String objName, String typee) {
            
            String sourcePageName = getSourcePageName(typee);
            String targetPageName = getTargetPageName(objName, sourcePageName);
                                
            MetadataService.MetadataPort service = createService(); 
            //autoadding to layouts disabled
            if (ApexPages.currentPage().getParameters().containsKey('modifylayouts')) {
            	removeApexPageFromLayouts(targetPageName, objName, service);
            }    
            List<MetadataService.DeleteResult> results =        
            service.deleteMetadata(
                'ApexPage', new String[] { targetPageName });              
            
            MetadataService.DeleteResult result = results[0];
            System.debug(Logginglevel.INFO, result);
            return result==null || result.success;
        }
        
        public static MetadataService.MetadataPort createService() {
             
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            return service;     
        }
 }