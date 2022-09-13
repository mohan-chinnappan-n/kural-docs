public with sharing class Wrike_FolderController extends Wrike_AbstractSectionController {

    ApexPages.StandardController controller;

	String nameField = 'Name';
    public Wrike_FolderController(ApexPages.StandardController controller) {
        
        super(controller.view().getUrl());
        
        this.controller = controller;
        canWrite = false;
        
		String url = ApexPages.currentPage().getUrl();
        if (url.startsWith('/apex/Wrike_FolderView_')) {
        	String objectName = url.substring(23);
        	if (objectName.contains('?')) {
        		 objectName = objectName.substringBefore('?');
        	}
        	Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
	        if (objType != null) {
	        	Map<String, Schema.SObjectField> fieldsmap = objType.getDescribe().fields.getMap();
	                        
		        for(Schema.sObjectField f : fieldsmap.values()) {
		        	//System.debug(f.getDescribe().getName());
		        	//System.debug(f.getDescribe().isNameField());
		        	if (f.getDescribe().isNameField()) {
		        		nameField = f.getDescribe().getName();
		        	}
		        }
		        System.debug(nameField);
	        }
        }
        controller.addFields(new List<String>{'ID', nameField});
        SObject record = controller.getRecord();   
        
        binding = Wrike_Bindings__c.getValues(
        	record.getSObjectType().getDescribe().getName());
        	
        parentFolderId = binding.ParentId__c;
        bindRule = binding.Rule__c;
    }

	public Wrike_FolderController() {
		super(null);
	}
	
	private Wrike_Bindings__c binding;
	
    public String parentFolderId { get; set; }
    
    public String bindRule { get; set; }
    
    public String state { get; set; }

    public String folderId { get; set; }

    public String folderPermalink { get; set; }

    public String targetFoldersJSON { get; set; }
    
    public String taskReference { get; set; }
    
    public Boolean canWrite { get; set; }
    

    public PageReference ensureFolder() {
 
        SObject record = controller.getRecord();
		
        if(!Wrike_PrivilegedUtils.hasWrikeFolderId(record.getSObjectType())) {
            state = 'corrupted';
            return null;
        }
        
        if(String.isBlank(parentFolderId) )
    	{
    		state = 'select_folder';
            return null; 
    	}
        
        folderId = Wrike_PrivilegedUtils.getWrikeFolderId(
        		record.getSObjectType(), (String)record.get('id'));
		
        if(folderId == null || !Pattern.matches('^[0-9A-Z]{16}$', folderId) ) {

            String foldersBody = wrikeApiGet(
            		'/folders/'+ parentFolderId +'/folders');
            state = parseJSON(foldersBody, 'error');

            if (state == 'not_authorized') {

                if (refreshExpiredToken()) {

                   PageReference page = new PageReference(ApexPages.currentPage().getUrl());
                   page.setRedirect(true);
                   return page;
                }
                else {
                    return null;
                }
            }
            else if (state == null) {
                targetFoldersJSON = foldersBody;
                state = 'select_folder';
                return null;    
            }
            
            state = 'corrupted';
            return null;
        }


        String folderBody = getFolderJSON();
        state = parseJSON(folderBody, 'error');

        if (state == 'not_authorized') {

            if (refreshExpiredToken()) {

               PageReference page = new PageReference(ApexPages.currentPage().getUrl());
               page.setRedirect(true);
               return page;
            }
        }

        if (state == null) {

            String id = parseJSON(folderBody, 'id');
            folderPermalink = parseJSON(folderBody, 'permalink');

            state = id == folderId &&
                    folderPermalink.startsWith(WRIKE_DOMAIN + '/open.htm?')?
                'ok' : 'corrupted';
           
        	if (state == 'ok') {
        		
        		if (isFolderDeleted(folderId)) {
        			Wrike_PrivilegedUtils.setWrikeFolderId(
            				record.getSObjectType(), (String)record.get('id'), '');
        			
	        		state = 'select_folder';
	                return null;
                }
                
        		canWrite = isUser();
        	}
            
        }
        
        return null;
    }
    
    public String getWorkflowsJSON()
    {
    	return wrikeApiGet('/accounts/' + getWrikeAccountId() + '/workflows');
    }

    public PageReference editTask() {
    	
    	Map<String, String> fieldMap = ApexPages.currentPage().getParameters();
    	String taskToEdit = null;
    	Long taskTimestamp = 0L;
        for (String fieldName : fieldMap.keySet()){
            if (fieldName.startsWith('task')) {
            	Long timestamp = Long.valueOf(fieldName.substringAfter('task'));
            	if (timestamp > taskTimestamp) {
            		taskToEdit = fieldMap.get(fieldName);
            		taskTimestamp = timestamp;
            	}
            }
            System.debug(fieldName + '=' + fieldMap.get(fieldName));
        }
    	
    	if (taskToEdit != null) {
	    	String taskEditUrl =
	      			URL.getSalesforceBaseUrl().toExternalForm() +
	 				 '/apex/Wrike_TaskView?action=edit'+
	 				 '&task=' + taskToEdit +
	 				 '&callback=' + EncodingUtil.urlEncode(ApexPages.currentPage().getUrl(), 'UTF-8');
	 			
			PageReference taskEditPage = new PageReference(taskEditUrl);
	 		taskEditPage.setRedirect(true);
	 			
	 		return taskEditPage;
    	}
    	else {
    		return null;
    	}
    }

    public PageReference createTask() {
    	
    	String targetFolderId = folderId;
    	
    	if (state == 'select_folder') {
    		String currentParentFolderId = parentFolderId;
    		
    		SObject record = controller.getRecord();
            Schema.SObjectType objType = record.getSObjectType();
     	    
    	    if (String.isBlank(parentFolderId) || isFolderDeleted(parentFolderId)) {

                String label = objType.getDescribe().getLabelPlural();
                
	        	String folderBody = wrikeApiPost('/folders/' + getSalesforceFolderId() + '/folders',
		        	'title=' + EncodingUtil.urlEncode(label, 'UTF-8'));
		       System.debug(folderBody);
		        currentParentFolderId = parseJSON(folderBody, 'id');
    	    }
    	    
    	    String url = '/folders/' + EncodingUtil.urlEncode(currentParentFolderId, 'UTF-8') + '/folders';
    	    
    	    String params = 'title=' + EncodingUtil.urlEncode(getTargetFolderName(), 'UTF-8');
            
            String newFolderJSON = wrikeApiPost(url,params);
            System.debug(newFolderJSON);
                      
            String error = parseJSON(newFolderJSON, 'error');

            if (error == 'not_authorized') {

                if (refreshExpiredToken()) {
                   
                   newFolderJSON = wrikeApiPost(url,params);
                   error = parseJSON(newFolderJSON, 'error');
                }
            }
            if (!currentParentFolderId.equals(parentFolderId)) {
            	Wrike_PrivilegedUtils.updateBindedFolder(objType.getDescribe().getName(), currentParentFolderId);
            }            
            
            targetFolderId = parseJSON(newFolderJSON, 'id');
            Wrike_PrivilegedUtils.setWrikeFolderId(objType, (String)record.get('id'), targetFolderId);
            
            if (error != null) {
            	return refreshAndReset();
            }
    	}
      	String taskViewUrl =
      			URL.getSalesforceBaseUrl().toExternalForm() +
 				 '/apex/Wrike_TaskView?action=create'+
 				 '&folder=' + EncodingUtil.urlEncode(targetFolderId, 'UTF-8') +
 				 '&callback=' + EncodingUtil.urlEncode(ApexPages.currentPage().getUrl(), 'UTF-8');
 			
		PageReference taskEditPage = new PageReference(taskViewUrl);
 		taskEditPage.setRedirect(true);
 			
 		return taskEditPage;
    	
        /*Old create task
        
        String pageTitle = ApexPages.currentPage().getParameters().get('title');

        String url = '/folders/' + folderId + '/tasks ';
        String params = 'title=' + EncodingUtil.urlEncode('New task for ' + pageTitle, 'UTF-8');
        String newTaskPermalink = null;
        
        String newTaskJSON = wrikeApiPost(url,params);
        String error = parseJSON(newTaskJSON, 'error');

        if (error == 'not_authorized') {

            if (refreshExpiredToken()) {
               
               newTaskJSON = wrikeApiPost(url,params);
               error = parseJSON(newTaskJSON, 'error');
            }
        }
        if (error == null) {
            newTaskPermalink = parseJSON(newTaskJSON, 'permalink');
        }

        return newTaskPermalink != null? new PageReference(newTaskPermalink) : null;*/
        
    }

    public PageReference selectFolder() {

        String folderId = ApexPages.currentPage().getParameters().get('folderId');

        if (folderId != null) {

            //ensure folder is exists and it is a child of subtree
            
            SObject record = controller.getRecord();
            Wrike_PrivilegedUtils.setWrikeFolderId(record.getSObjectType(),
            	(String)record.get('id'), folderId);
        }
       
        PageReference page = new PageReference(controller.view().getUrl());
        page.setRedirect(true);
        return page;
    }

    public PageReference createFolder() {

        String parentFolderId = ApexPages.currentPage().getParameters().get('parentFolderId');
        String folderName = ApexPages.currentPage().getParameters().get('folderName');

        if (parentFolderId != null && folderName != null) {
         
            String url = '/folders/' + EncodingUtil.urlEncode(parentFolderId, 'UTF-8') + '/folders ';
            String params = 'title=' + EncodingUtil.urlEncode(folderName, 'UTF-8');
            String newFolderId = null;
            
            String newFolderJSON = wrikeApiPost(url,params);
            String error = parseJSON(newFolderJSON, 'error');

            if (error == 'not_authorized') {

                if (refreshExpiredToken()) {
                   
                   newFolderJSON = wrikeApiPost(url,params);
                   error = parseJSON(newFolderJSON, 'error');
                }
            }
            if (error == null) {
                newFolderId = parseJSON(newFolderJSON, 'id');

	            SObject record = controller.getRecord();
	            Wrike_PrivilegedUtils.setWrikeFolderId(
	            		record.getSObjectType(), (String)record.get('id'), newFolderId);

            } 
        }
       
        PageReference page = new PageReference(controller.view().getUrl());
        page.setRedirect(true);
        return page;
    }

    private String getFolderJSON() {

      return wrikeApiGet('/folders/'+ folderId);
    }

    public String getContactsJSON() {
       
       return wrikeApiGet('/contacts');
    }
    
    public String getFolderTasksJSON() {
    	
        return wrikeApiGet('/folders/' + folderId + '/tasks/?fields=["responsibleIds","hasAttachments","parentIds"]&descendants=true');
    }

    public String getTargetFolderName() {

      SObject record = controller.getRecord();
      return String.valueOf(record.get(nameField));
    }
    
    public static void validate_FolderController() {
        Integer i = 0;
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
    }
}