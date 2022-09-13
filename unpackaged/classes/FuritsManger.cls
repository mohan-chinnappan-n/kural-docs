@RestResource(urlMapping='/fruits')

global with sharing class FuritsManger {

    @HttpPost
    global static String getFruits(String item) {
     
        Integer qty = Integer.valueof(Math.random() * 100);
        
        String result = '[ {"name": "' + item.toUpperCase()  + '", "qty" : ' + qty + '}]';
        JSONParser parser = JSON.createParser(result);
        
        List<Fruit> fruits = new List<Fruit>();

        
        while (parser.nextToken() != null) {
        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
            while (parser.nextToken() != null) {
               
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    Fruit fruit = (Fruit)parser.readValueAs(Fruit.class);
                    fruits.add(fruit);
            
                    parser.skipChildren();
                }
            }
        }
    }
  
    return JSON.serialize(new PackagedReturnItem(fruits));
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
        
        public List<Fruit> data;
        public ReturnMetadata metadata;
        
        public PackagedReturnItem(List<Fruit> data) {
            this.data = data;
            this.metadata = new ReturnMetadata(new List<String>{'name'}, new List<String>{'qty'}, new List<String>());
        }   
    }  
    
    
 }