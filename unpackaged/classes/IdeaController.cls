public with sharing class IdeaController {

   @AuraEnabled(cacheable=true)
   public static List<Idea>  getIdeaInfo(){ 
        return [SELECT Id,Title,Body,Categories, isHTML, numComments, VoteScore, VoteTotal, Status FROM Idea] ;
   }

}