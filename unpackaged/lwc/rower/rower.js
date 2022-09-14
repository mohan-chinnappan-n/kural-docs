import { LightningElement, api, track } from 'lwc';

export default class Rower extends LightningElement {
 
    @api index;
    @api rc;
    @track isNewRow;
    connectedCallback() {
        console.log(this.rc);
        this.isNewRow = this.index % this.rc === 0;
    }

    

}