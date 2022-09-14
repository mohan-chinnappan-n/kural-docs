import { LightningElement, wire } from 'lwc';
import basePath from '@salesforce/community/basePath';
import { CurrentPageReference } from 'lightning/navigation';

export default class Header extends LightningElement {

  basePathValue = basePath;
  CurrentPageReferenceValue;

  @wire(CurrentPageReference)
  pageReference({ state }) {
    this.CurrentPageReferenceValue = JSON.stringify(state);
  }

}