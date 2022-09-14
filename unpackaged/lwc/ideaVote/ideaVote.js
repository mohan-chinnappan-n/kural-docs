import { LightningElement, api, track } from 'lwc';

import Id from '@salesforce/user/Id';

export default class IdeaVote extends LightningElement {

    @api vt;
    @api cbid;
    userid = Id;
    finished = false;

    /*
       - user can demote once:  10 to 0 on others idea (-10)
       - user can promote other idea once by +10 point


    */

    get sameUser() {
        return this.userid === this.cbid;
    }

    handleUpVote() {
        this.finished = true;
        this.vt += 10;
    }
    handleDownVote() {
        if (this.vt >= 10) { 
            this.finished = true;
            this.vt -= 10;
        }
    }


  
}