import { LightningElement, wire } from 'lwc';
import { getListInfoByName } from 'lightning/uiListsApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';

export default class WireGetRecordAccount extends LightningElement {

    error;
    displayColumns;

    // Let’s use the wire service to get record data and display some field names.

    @wire(getListInfoByName, { objectApiName: ACCOUNT_OBJECT, listViewApiName: 'AllAccounts' })
    listInfo({ error, data }) {
    
    if (data) {
        this.displayColumns = data.displayColumns;
        this.error = undefined;
    } else if (error) {
        this.error = error;
        this.displayColumns = undefined;
    }
    }        
    

}