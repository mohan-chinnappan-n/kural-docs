import { LightningElement, api } from 'lwc';

export default class IdeaItem extends LightningElement {

    @api idea;


    handleAddCommentEvent(event) {
        alert('handleAddCommentEvent');
    }


}