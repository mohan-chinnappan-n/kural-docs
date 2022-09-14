import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Footer  extends NavigationMixin(LightningElement) {

    footerItems = [
        {link: '#help',label:'Help'},
        {link: '#contact',label:'Contact'},
        {link: '#privacy',label:'Privacy'},
    ];
    

    recordPageUrl;

    navigateToFilesHome() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'ContentDocument',
                actionName: 'home'
            }
        });
    }

    navigateToLogin() {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                 
            }
        });
    }


    connectedCallback() {
        // Generate a URL to a Contact record page
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: '0033h000012b5UtAAI',
                actionName: 'view',
            },
        }).then((url) => {
            this.recordPageUrl = url;
        });
    }


}