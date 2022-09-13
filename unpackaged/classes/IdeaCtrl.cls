public with sharing class IdeaCtrl {

    // Idea
    @AuraEnabled(cacheable=true)
    public static List<Idea>  getIdeas(String searchKey, String sortBy, String sortDirection) {

        String query = 'SELECT Id, Title, Body, NumComments, VoteScore, VoteTotal, IsHtml, CommunityId, CreatorName, CreatedById, CreatorSmallPhotoUrl FROM Idea';

        if ( searchKey != null && searchKey != '' ) {
           String key = '%' + searchKey + '%';
           query += ' WHERE Title LIKE :key';
        }
        if ( sortBy != null && sortDirection != null ) {
           query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }


       return Database.query( query );
    }

   // IdeaComment
   /*
      To use @wire to call an Apex method, you must set cacheable=true.
      To call an Apex method imperatively, you can choose to set cacheable=true
   */

    @AuraEnabled(cacheable=true)
    public static List<IdeaComment>  getIdeaComment(Id cid, String iid) {
       List<String> res = iid.split('-');
       Id ideaId = Id.valueOf(res[0]);
      
       return [
               SELECT Id, 
               CreatorName, CreatorSmallPhotoUrl, CreatorFullPhotoUrl, 
               CommentBody, IsHtml, 
               UpVotes, 
               CommunityId,

               CreatedById
               
               FROM IdeaComment
               WHERE
                CommunityId =  :cid
                 AND
                IdeaId = :ideaId
                ORDER BY CreatedDate DESC
               
        ] ;
    }


    @AuraEnabled
    public static Boolean  addComment(Id cid, String iid,  String comment) {
       List<String> res = iid.split('-');
       Id newId = Id.valueOf(res[0]);
       IdeaComment ic = new IdeaComment(CommentBody=comment, IdeaId=newId);

       IdeaComment[] ics = new List<IdeaComment>();
       ics.add(ic);
       try {
          insert ics;
          return true;
       } catch (DmlException e) {
          System.debug('An unexpected error has occurred: ' + e.getMessage());
          return false;
       }
    }

    @AuraEnabled
    public static Boolean  addIdea(Id cid,  String ideaTitle, String ideaBody) {
     
       Idea newIdea = new Idea(Body=ideaBody, Title=ideaTitle, CommunityId=cid);

       Idea[] ideas = new List<Idea>();
       ideas.add(newIdea);
       try {
          insert ideas;
          return true;
       } catch (DmlException e) {
          System.debug('An unexpected error has occurred: ' + e.getMessage());
          return false;
       }
    }


}