import { LightningElement, api, wire , track} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import Id from '@salesforce/user/Id';


import getIdeas from '@salesforce/apex/IdeaCtrl.getIdeas';




export default class IdeasComp extends LightningElement {

    userId = Id;





    @track allIdeas;

    ideasColumns = [
     //   { label: 'Id', fieldName: 'Id' },
        { label: 'Title', fieldName: 'Title',   sortable: true},
        { label: 'NumComments', fieldName: 'NumComments', label:'Total Comments',   sortable: true},
     // { label: 'VoteScore', fieldName: 'VoteScore', label:'Vote Score',  sortable: true},
        { label: 'VoteTotal', fieldName: 'VoteTotal', label: 'Total Votes', sortable: true},
        { label: 'CommunityId', fieldName: 'CommunityId',   sortable: false},
        { label: 'CreatorName', fieldName: 'CreatorName'},
        { label: 'CreatorById', fieldName: 'CreatedById'}
        
    ];

    @track dtConfig = {
        objectName: "Idea",
        //queryFilters: "Title LIKE '%LWC%' ",
        pageSize: 5,
        tableConfig: {
            columns: [
                { api: 'Title', label: 'Title', fieldName: 'Title', sortable: true },
                { api: 'NumComments', label: 'NumComments', fieldName: 'NumComments', sortable: true },
                { api: 'VoteTotal', label: 'Total Votes', fieldName: 'VoteTotal', sortable: true }

 
 
            ],
            maxRowSelection: 1
        }
    };

    // chart parmeters
    @api chartData = [30,20,11,22];
    @api chartBgColors =  ['#99ccff', '#ff99cc', '#cc99ff', '#ffcc99'];
    @api chartType = 'doughnut';
    @api chartLabel = 'Idea Status';
    

    @api showIdeasList = false;

    // search
    @api searchKey = '';

    // sort 
    @api sortedBy = 'Title';
    @api sortedDirection = 'asc';

    //comment
    @api showAddComment = false;

    //idea
    @track showAddIdea = false;

    //idea details
    @track showIdeaDetail  = false;

    @api cii;

    @track disablePostNewIdeaBtn;


    

    // wiring getIdeas
    @wire(getIdeas, {searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection'})
    wiredGetIdeas({ data, error }) {
        if (error) {
            console.log(error);
            // TODO: improve error notifications
        } else {
            this.allIdeas = data;
            console.log(data);
        }
    }




    // Handlers

    // search 
    handleSearchChange( event ) {
        this.searchKey = event.target.value;
        // this.dtConfig.queryFilters = `Title LIKE %${this.searchKey}%`;
        // Data provisioned by Apex is not managed and you must handle data refresh on your own
        refreshApex(this.allIdeas);
        this.showIdeasList = true;
    }

    // sorting
    sortColumns( event ) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        return refreshApex(this.allIdeas);
    }

    // comments
    handleAddComment(event) {
        this.showAddComment = true;
    }

    handleAddCommentEvent(event) {
        //alert('handleAddCommentEvent');
        refreshApex(this.allIdeas);
    } 

    handelRowSelection(event){
        this.showIdeaDetail = true;

    }
    // https://sfdctree.wordpress.com/2020/10/20/lwc-lightning-data-table-with-pagination-searching-and-sorting/

    
    handlePostNewIdea(event) {
        this.showAddIdea = true;
        this.disablePostNewIdeaBtn = true;
    }





}