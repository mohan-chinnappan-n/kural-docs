import { LightningElement, api, track, wire } from 'lwc';

import { refreshApex } from '@salesforce/apex';

// wire adapters
import addComment from '@salesforce/apex/IdeaCtrl.addComment';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class IdeaCommentUtil extends LightningElement {

    @track newComment = '';
    @api error;
    @api id;
    @api cid;

    @track addCommentResult;

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({ title, message, variant, mode });
        this.dispatchEvent(event);
    }


    // handlers
    handleSaveComment(event) {
        const editor = this.template.querySelector('lightning-input-rich-text');
        this.newComment = editor.value;

        // alert (this.cid +  this.id +  this.newComment);
        addComment( {iid: this.id, comment: this.newComment} )
        .then(result => {
            this.addCommentResult = result;

            this.addCommentResult = result;
            this.showToast('Save New Comment', 'Your Comment for the Idea is saved!', 'success', 'dismissable');
            this.disableSaveIdea = true;

            // alert (result);
            const addCommentEvent = new CustomEvent('addcomment', {
                detail: 'comment got added'
            });
            this.dispatchEvent(addCommentEvent);
            // getRecordNotifyChange(this.addCommentResult);

        })
        .catch(error => {
            this.error = error;
            this.showToast('Save New Comment', `Your New Comment for this Idea  was not saved: ${error}`, 'danger', 'dismissable');
            
        });

    }

}