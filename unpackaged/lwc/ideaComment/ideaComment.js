import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';

// wire adapters
import getIdeaComment from '@salesforce/apex/IdeaCtrl.getIdeaComment';

import { NavigationMixin } from 'lightning/navigation';


export default class IdeaComment extends LightningElement {

    @api id;
    @api cid; //CommunityId

    @api showComments = false;
    @api hasComments = false;
    @api totalComments = 0;
    @api totalCommentsLabel = "Comments ";


    @track error;
    @track ideaComment;


    
  
    // wiring getIdeaComment
    @wire(getIdeaComment, {cid: '$cid', iid: '$id'})
    wiredGetIdeaComment({ data, error }) {
        if (error) {
            console.log(error);
            this.error = JSON.stringify(error);
            // TODO: improve error notifications
        } else {
            this.ideaComment = data;
            // console.log(data);
            if (data && data.length !== 0) {
                this.totalComments = data.length;
                this.hasComments = true;
                this.totalCommentsLabel += `( ${this.totalComments} )` ;
            } else {
                this.hasComments = false; 
            }

        }
    }

   // Handlers

    // Show Comment 
    handleGetIdeaComment( event ) {
        // console.log('rendering comments');
        this.showComments = !this.showComments;
        refreshApex(this.ideaComment);
    }
    
    /*

    //  lifecycle hook fires when a component is inserted into the DOM
    //  https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.create_lifecycle_hooks_dom
    //  disconnectedCallback() lifecycle hook fires when a component is removed from the DOM
    connectedCallback() {
       this.handleGetIdeaComment();
       console.log('connectedCallback');
    }
    
    handleGetIdeaComment( ) {
        console.log('rendering comments');
        refreshApex(this.ideaComment);
        getIdeaComment( {cid: this.cid, iid: this.id} )
        .then(data => {
            this.ideaComment = data;
            console.log(data);
            if (data && data.length !== 0) {
                this.totalComments = data.length;
                this.hasComments = true;
                console.log('hasComments', this.hasComments);
                this.totalCommentsLabel += `( ${this.totalComments} )` ;
            } else {
                this.hasComments = false; 
            }

        })
        .catch(error => {
            alert (error);
            this.error = error;
        });
    }
    */

   addLikeHandler(event) {
       alert('addLikeHandler');
   }

   addDislikeHandler(event) {
    alert('addDislikeHandler');
   }

   // navigate
   navigateToChatter() {
    // Use the built-in 'Navigate' method
    this[NavigationMixin.Navigate]({
        // Pass in pageReference
        type: 'standard__namedPage',
        attributes: {
            pageName: 'chatter'
        }
    });
}

    

 


}