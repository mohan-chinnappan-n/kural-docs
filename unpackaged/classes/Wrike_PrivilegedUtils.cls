public class Wrike_PrivilegedUtils {
	
	public static String getWrikeFolderId(Schema.SObjectType recordType, String recordId) {
		
		String objectName = recordType.getDescribe().getName();
		
		SObject record = Database.query(
			'Select Id, Wrike_Folder_ID__c From ' + objectName +' Where Id = \'' + recordId + '\'');
	    
	    return (String) record.get('Wrike_Folder_ID__c');
	}
	
	public static void setWrikeFolderId(Schema.SObjectType recordType, String recordId, String value) {
		
		String objectName = recordType.getDescribe().getName();
		
		SObject record = Database.query(
			'Select Id, Wrike_Folder_ID__c From ' + objectName +' Where Id = \'' + recordId + '\'');
			
		record.put('Wrike_Folder_ID__c', value);
		update record;
	}
	
	public static boolean hasWrikeFolderId(Schema.SObjectType recordType) {
		  
      	Map<String, Schema.SobjectField> fields = 
            recordType.getDescribe().fields.getMap();
		
		return fields.containsKey('Wrike_Folder_ID__c');
	}
     
	public static String getWrikeTaskId(Schema.SObjectType recordType, String recordId) {
		
		String objectName = recordType.getDescribe().getName();
		
		SObject record = Database.query(
			'Select Id, Wrike_Task_ID__c From ' + objectName +' Where Id = \'' + recordId + '\'');
	    
	    return (String) record.get('Wrike_Task_ID__c');
	}
	
	public static void setWrikeTaskId(Schema.SObjectType recordType, String recordId, String value) {
		
		String objectName = recordType.getDescribe().getName();
		
		SObject record = Database.query(
			'Select Id, Wrike_Task_ID__c From ' + objectName +' Where Id = \'' + recordId + '\'');
			
		record.put('Wrike_Task_ID__c', value);
		update record;
	}
	
	public static boolean hasWrikeTaskId(Schema.SObjectType recordType) {
		  
      	Map<String, Schema.SobjectField> fields = 
            recordType.getDescribe().fields.getMap();
		
		return fields.containsKey('Wrike_Task_ID__c');
	}
         	
    public static void updateBindedFolder(String objectName, String folderId) {
            
        Wrike_Bindings__c binding = 
            Wrike_Bindings__c.getValues(objectName);
        	
        if (binding != null) {
            binding.ParentId__c = folderId;
        	update binding;
        }
            
    }
        	
}