import { LightningElement, api, track } from 'lwc';

import { refreshApex } from '@salesforce/apex';

// wire adapters
import addIdea from '@salesforce/apex/IdeaCtrl.addIdea';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class IdeaNew extends LightningElement {

    @api newIdeaBody;
    @api newIdeaTitle;

    @api cid;
    // https://help.salesforce.com/articleView?id=ideas_communities.htm&type=5
    // https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_community.htm
    // $ sfdx mohanc:data:query -q q/community.sql -u mohan.chinnappan.n_ea2@gmail.com -f json
    /*
    [
    {
        "attributes": {
            "type": "Community",
            "url": "/services/data/v50.0/sobjects/Community/09a3h000000bD9zAAE"
        },
        "Id": "09a3h000000bD9zAAE",
        "Name": "Internal Zone",
        "NetworkId": null
    }
]
*/

  @track disableSaveIdea;


    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({ title, message, variant, mode });
        this.dispatchEvent(event);
    }

    connectedCallback() {
        this.disableSaveIdea = true;

    }



    // handlers
    handleSaveIdea(event) {
        const editor = this.template.querySelector('lightning-input-rich-text');
        this.newIdeaBody = editor.value;
        const titleInput = this.template.querySelector('lightning-input');
        this.newIdeaTitle = titleInput.value;

        // console.log(this.newIdeaBody, this.newIdeaTitle);

        // alert (this.cid +  this.id +  this.newComment);
        addIdea( {cid: this.cid, ideaTitle: this.newIdeaTitle, ideaBody: this.newIdeaBody, } )
        .then(result => {
            this.addCommentResult = result;
            this.showToast('Save New Idea', 'Your New Idea is saved!', 'success', 'dismissable');
            this.disableSaveIdea = true;


        })
        .catch(error => {
            this.error = error;
            this.showToast('Save New Idea', `Your New Idea was not saved: ${error}`, 'danger', 'dismissable');
        });

    }

    // handlers

    handleIdeaBodyChange(event) {
        this.disableSaveIdea = false;
        
    }

}