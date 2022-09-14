import { LightningElement,  wire } from 'lwc';
import getAccountList from '@salesforce/apex/AccountController.getAccountList';


export default class Account2 extends LightningElement {

    columns = [{  label: 'Id', fieldName: 'Id' },
{  label: 'Name', fieldName: 'Name' },
];
    // Let’s use the apex wire service to get record data and display some field names.
    @wire(getAccountList)
    accounts;

}