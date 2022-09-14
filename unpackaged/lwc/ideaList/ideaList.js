import { LightningElement, wire, track } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import Account_OBJECT from '@salesforce/schema/Account';



export default class IdeaList extends LightningElement {
    @track sobjectResult;
    @wire(getListUi, {
        objectApiName: Account_OBJECT,
        listViewApiName: 'AllAccounts'
    })
    wiredlistView({
        error,
        data
    }) {
        if (data) {
            this.sobjectResult = data.records.records;
        } else if (error) {
            this.error = error;
        }
    }

}