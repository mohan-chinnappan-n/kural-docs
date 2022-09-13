public with sharing class Wrike_TaskController extends Wrike_AbstractSectionController {
    
    ApexPages.StandardController controller;
    
    String nameField = 'Name';
	
	public Wrike_TaskController(ApexPages.StandardController controller) {
        
        super(controller.view().getUrl());
        this.controller = controller;
        
        controller.addFields(new List<String>{'Wrike_Task_ID__c', nameField });
        SObject record = controller.getRecord();        
        
        binding = Wrike_Bindings__c.getValues(
        		record.getSObjectType().getDescribe().getName());
        
        this.deltaJSON = '';
    }

	public Wrike_TaskController() {
		super(null);
	}
    
	private Wrike_Bindings__c binding;

    public String state { get; set; }

    public String taskId { get; set; }
    
    public String taskStatus { get; set; }
    
    public String callbackUrl { get; set; }
    
    public String folderId { get; set; }

    public String accountId { get; set; }

    public String taskPermalink { get; set; }

    public String preloadedTaskJSON { get; set; }

    public String deltaJSON { get; set; }


    public PageReference ensureTask() {
 
 		String action = Apexpages.currentPage().getParameters().get('action');
		if (action != null && action == 'create') {
			taskId = 'NEW';
			folderId = Apexpages.currentPage().getParameters().get('folder');
			callbackUrl = Apexpages.currentPage().getParameters().get('callback');
		}
        else if (action != null && action == 'edit') {
        	taskId = Apexpages.currentPage().getParameters().get('task');
        	callbackUrl = Apexpages.currentPage().getParameters().get('callback');
        }
		else {
	        SObject record = controller.getRecord();
	       
	        if(!Wrike_PrivilegedUtils.hasWrikeTaskId(record.getSObjectType())) {
	            state = 'corrupted';
	            return null;
	        }
	        
	        taskId = Wrike_PrivilegedUtils.getWrikeTaskId(
	        		record.getSObjectType(), (String)record.get('id'));
	
	        if(taskId == null || !Pattern.matches('^[0-9A-Z]{16}$', taskId) ) {
	            //create one

	            String leadName = String.valueOf(record.get(nameField));
	
	            String newTaskJSON = wrikeApiPost('/folders/' +  
	            	binding.ParentId__c + '/tasks ',
	                'title=' + EncodingUtil.urlEncode(leadName, 'UTF-8') +
	                '&dates=%7Btype%3D%22Backlog%22%3Bduration%3D480%7D'
	                );
	     
	            taskId = parseJSON(newTaskJSON, 'id');
	            if (taskId == null || !Pattern.matches('^[0-9A-Z]{16}$', taskId)) {
	                state = 'corrupted';
	                return null;
	            } 
	            else {
	            	Wrike_PrivilegedUtils.setWrikeTaskId(
	        			record.getSObjectType(), (String)record.get('id'), taskId);
	                update record;
	
	                PageReference page = new PageReference(ApexPages.currentPage().getUrl());
	                page.setRedirect(true);
	                return page;
	            }
	
	        }      
		}
		
        if (taskId == 'NEW') {
        	state = 'ok';        
        }
        else {
        	preloadedTaskJSON = getTaskJSON();
        	state = parseJSON(preloadedTaskJSON, 'error');

	        if (state == 'not_authorized') {
	
	            if (refreshExpiredToken()) {
	
	               PageReference page = new PageReference(ApexPages.currentPage().getUrl());
	               page.setRedirect(true);
	               return page;
	            }
	        }
	        
	        if (state == null) {
	                
	            String id = parseJSON(preloadedTaskJSON, 'id');
	            taskStatus = parseJSON(preloadedTaskJSON, 'status');
	            accountId = parseJSON(preloadedTaskJSON, 'accountId');
	            taskPermalink = parseJSON(preloadedTaskJSON, 'permalink');
	            
	            state = id == taskId &&
	                    Pattern.matches('^[0-9A-Z]{8}$', accountId) &&
	                    taskPermalink.startsWith(WRIKE_DOMAIN + '/open.htm?')?
	                'ok' : 'corrupted';
	        }
        }
        return null;
    }

    public String getTaskJSON() {

        String json = preloadedTaskJSON != null ?
            preloadedTaskJSON : wrikeApiGet('/tasks/' + taskId);

        preloadedTaskJSON = null;
        return json;
    }
    
    public String getWorkflowsJSON()
    {
    	return wrikeApiGet('/accounts/' + getWrikeAccountId() + '/workflows');
    }

    public String getTaskCommentsJSON() {

        return wrikeApiGet('/tasks/' + taskId + '/comments');
    }

    public String getTaskAttachmentsJSON() {

        return wrikeApiGet('/tasks/' + taskId + '/attachments');
    }

    public String getContactsJSON() {
       
       return wrikeApiGet('/accounts/' + getWrikeAccountId() + '/contacts/');
    }

	public PageReference back() {
		PageReference page = new PageReference(callbackUrl);
		page.setRedirect(true);
		return page;
	}
    	
    public PageReference save() {
        
        String changeSet = Apexpages.currentPage().getParameters().get('changeSet');
        	
        if (taskId == 'NEW') {
        	String response = wrikeApiPost('/folders/' + folderId + '/tasks', changeSet);
        	System.debug(response);
    	}
        else {
        	String response = wrikeApiPut('/tasks/' + taskId, changeSet);
        	System.debug(response);
        }
        if (callbackUrl != null) {
        	PageReference page = new PageReference(callbackUrl);
			page.setRedirect(true);
			return page;		
        	
        }
        else {
        	return null;
        }
    }
    
    public PageReference complete() {

    	String response = wrikeApiPut('/tasks/' + taskId, 'status=Completed');
    	System.debug(response);

        if (callbackUrl != null) {
        	PageReference page = new PageReference(callbackUrl);
			page.setRedirect(true);
			return page;		
        	
        }
        else {
        	return null;
        }
    }

}