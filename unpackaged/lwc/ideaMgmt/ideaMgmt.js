import { LightningElement, wire, track } from 'lwc';

import getIdeaInfo from "@salesforce/apex/IdeaController.getIdeaInfo";

import { getListUi, MRU } from 'lightning/uiListApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';



const columns = [
    { label: "Id", fieldName: "Id", sortable: "true" },
    { label: "Title", fieldName: "Title", sortable: "true" },
    { label: "NumComments", fieldName: "numComments", sortable: "true" },
    { label: "Body", fieldName: "Body", sortable: "false" },
    { label: "VoteScore", fieldName: "VoteScore", sortable: "true" },
    { label: "VoteTotal", fieldName: "TotalVotes", sortable: "true" },





];

export default class IdeaMgmt extends LightningElement {

    columns = columns;
    @track ideaInfo;

    @wire(getIdeaInfo)
    wiredCallback(result) {
      if (result.data) {
        this.ideaInfo = result.data;
        console.log(this.ideaInfo);
      } else if (result.error) {
        console.log(result.error);
      }
    }

    onMouseover() {
      alert('mouseover');
    }


}