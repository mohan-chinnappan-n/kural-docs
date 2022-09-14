// navigationToPagesExample.js
import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavigationToPagesExample extends NavigationMixin(LightningElement) {

     label = 'Navigate to Salesforce';

    navigateToObjectHome() {
        // Navigate to the Case object home page.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'home'
            }
        });
    }

    navigateToListView() {
        // Navigate to the Contact object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'list'
            },
            state: {
                // 'filterName' is a property on the page 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                filterName: 'Recent' // or by 18 char '00BT0000002TONQMA4'
            }
        });
    }

    navigateToNewRecordPage() {
        // Opens the new Account record modal
        // to create an Account.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            }
        });
    }

    navigateToRecordViewPage() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: 'a03B0000002tEurIAE',
                objectApiName: 'namespace__ObjectName', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    navigateToRecordEditPage() {
        // Opens the Account record modal
        // to view a particular record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: '001B000000ZBz22IAD',
                objectApiName: 'Account', // objectApiName is optional
                actionName: 'edit'
            }
        });
    }

    navigateToRelatedList() {
        // Navigate to the CaseComments related list page
        // for a specific Case record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: '500xx000000Ykt4AAC',
                objectApiName: 'Case',
                relationshipApiName: 'CaseComments',
                actionName: 'view'
            }
        });
    }

    navigateToTabPage() {
        // Navigate to a specific CustomTab.
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                // CustomTabs from managed packages are identified by their
                // namespace prefix followed by two underscores followed by the
                // developer name. E.g. 'namespace__TabName'
                apiName: 'CustomTabName'
            }
        });
    }

    navigateToWebPage() {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'http://salesforce.com'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }
}