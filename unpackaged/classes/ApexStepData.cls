@RestResource(urlMapping='/data')   // Defines the class to the call by analytics
global with sharing class ApexStepData {
    
    @HttpPost   // Annotation Specified that this method needs to be called.
    global static String data_val(String industry) {
        // If No Industry is Specified in that case returning all elements.
        if (industry == null) {
            JSON.serialize(new PackagedReturnItem([select id,name,Industry from account ]));
        }
        // serialize the response for the Analytics        
        return JSON.serialize(new PackagedReturnItem([select id,name,Industry from account where industry=:industry]));
        
    }
    // Metadata Structure returns alongside Data
    public class ReturnMetadata {
        
        public List<String> strings; // Name of all the columns returned that is considered as text
        public List<String> numbers; // Name of all the columns returned that is considered as numeric
        public List<String> groups;  // Name of all the columns returned that is considered as groups
        
        public ReturnMetadata(List<String> strings, List<String> numbers, List<String> groups) {
            this.strings = strings;
            this.numbers = numbers;
            this.groups = groups;
        }
    }
    // Combined Structure of Data and Metadata
    public class PackagedReturnItem {
        
        public List<sobject> data;
        public ReturnMetadata metadata;
        
        public PackagedReturnItem(List<sobject> data) {
            this.data = data;
            this.metadata = new ReturnMetadata(new List<String>{'Id','Name','Industry'}, new List<String>(), new List<String>());
        }   
    }  
    
}