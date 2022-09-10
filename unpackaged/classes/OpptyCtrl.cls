public with sharing class OpptyCtrl {
    @AuraEnabled(cacheable=true)

    public static List<Opportunity> getOpps( String searchKey, String sortBy,  String sortDirection, Integer count) {
      
        String query = 'SELECT Id, Name,StageName,CloseDate FROM Opportunity';
        
        if ( searchKey != null && searchKey != '' ) {
            String key = '%' + searchKey + '%';
            query += ' WHERE Name LIKE :key';
        }
        if ( sortBy != null && sortDirection != null ) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        query = query + ' LIMIT :count';
        return Database.query( query );
    }
}