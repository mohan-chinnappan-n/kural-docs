import { LightningElement, api } from 'lwc';

import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTasks from '@salesforce/apex/Tasks.getTasks';
import gantt from "@salesforce/resourceUrl/gantt15";
import jquery360 from "@salesforce/resourceUrl/jquery360";


export default class Jqg extends LightningElement {


    @api scale= "weeks";
    @api maxScale = "months";
    @api minScale = "weeks";

    @api itemsPerPage = 10;
    @api scrollToToday = false;
    @api useCookie = false;
    @api navigate = "scroll";


    tasks = []; // array property to store list of Tasks

    // The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
    async connectedCallback() {
        // call apex class method which will return the list<Task>
        this.tasks = await getTasks();
        console.log(this.tasks);
        const dc = dt => new Date(dt).getTime();


        let gTasks = [];

        const today = new Date().getTime();
        this.tasks.map(t => {

            let customClass = "ganttBlue";

            if (dc(t.APM_StartDate__c) < today) {
                customClass = "ganttRed";
            }
            const item = {
                name: "SM",
                desc: t.Subject,
                values: [{
                    from: dc(t.APM_StartDate__c || "2022-02-20"),
                    to: dc(t.ActivityDate), 
                    label: t.Subject,
                    customClass,
                    dataObj: { label: t.Subject, start: t.APM_StartDate__c, end: t.ActivityDate}
                }]
            }
            gTasks.push(item);

        });

        console.log(gTasks);

        Promise.all([

            loadScript(this, jquery360),

            loadScript(
                this,
                gantt + "/js/jquery.fn.gantt.js"
              ),

         
            loadStyle(
              this,
              gantt + "/css/jqg.css"
            )

          ]).then(() => {
            // below is possible since we have lwc:dom='manual' in the markup
            const ganttClass = this.template.querySelector(".gantt");

          


            $(ganttClass).gantt({
                source: gTasks,

                navigate: this.navigate,

                scale:  this.scale,
                maxScale: this.maxScale,
                minScale: this.minScale,
                itemsPerPage: this.itemsPerPage,
                scrollToToday: this.scrollToToday,
                useCookie: this.useCookie,

                onItemClick: function(data) {
                    alert(JSON.stringify(data, null, 4));
                },
                onAddClick: function(dt, rowId) {
                    // alert("Empty space clicked - add an item!");
                },
                onRender: function() {
                    if (window.console && typeof console.log === "function") {
                        console.log("chart rendered");
                    }
                }
            }); 

             

          });


    }

}