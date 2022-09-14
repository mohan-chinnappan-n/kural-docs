import { LightningElement } from 'lwc';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import getTasks from '@salesforce/apex/Tasks.getTasks';
import gantt from "@salesforce/resourceUrl/gantt3";
import jquery360 from "@salesforce/resourceUrl/jquery360";


export default class Gantt extends LightningElement {

    tasks = []; // array property to store list of Tasks

    // The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
    async connectedCallback() {
        // call apex class method which will return the list<Task>
        this.tasks = await getTasks();
        console.log(this.tasks);

        Promise.all([

            loadScript(this, jquery360),

            loadScript(
                this,
                gantt + "/js/moment.min.js"
              ),

            loadScript(
              this,
              gantt + "/js/frappeGanttJS.js"
            ),
            loadStyle(
              this,
              gantt + "/css/frappe-gantt.css"
            )

          ]).then(() => {
            // below is possible since we have lwc:dom='manual' in the markup
            const ganttClass = this.template.querySelector(".gantt");
           //  ganttEle.innerHTML = "Gantt resources are loaded.<br>Gantt chart going to come here";


        var tasks2 = [

            {
                id: 'Spot Trade-in Base Management Kick off',
                name: 'Spot Trade-in Base Management Kick off',
                start: '2022-03-01',
                end: '2022-03-03',
                progress: 100,
                dependencies: '',
                custom_class: 'bar-milestone' // optional
            },
            {
                id: 'Spot Trade-in Operation Technical Evaluation',
                name: 'Spot Trade-in Operation Technical Evaluation',
                start: '2022-06-20',
                end: '2022-08-31',
                progress: 100,
                dependencies: '',
                custom_class: 'bar-milestone' // optional
            },
    
           
            {
                id: 'Credit card Financing IT work & Target Live date',
                name: 'Credit card Financing IT work & Target Live date',
                start: '2022-04-07',
                end: '2022-07-29',
                progress: 100,
                dependencies: '',
                custom_class: 'bar-milestone' // optional
            },
            {
                id: 'BPNL Pitch sell in',
                name: 'BPNL Pitch sell in',
                start: '2022-09-05',
                end: '2022-09-05',
                progress: 100,
                dependencies: '',
                custom_class: 'bar-milestone' // optional
            },
    
            {
                id: 'BPNL Evaluation and Launch',
                name: 'BPNL Evaluation and Launch',
                start: '2022-09-12',
                end: '2023-01-20',
                progress: 100,
                dependencies: '',
                custom_class: 'bar-milestone' // optional
            },
    
    
    
            ];

            console.log(tasks2);


            var arr = [1, 2, 3, 4, 5, 6];
            var tasks = arr.map(function(i){
                return {
                    start: "2016-10-0"+i,
                    end: "2016-11-0"+i,
                    name: "Task "+i,
                    id: "Task"+i,
                    progress: i*10
                }
            });
            tasks[1].dependencies = 'Task1';
            tasks[2].dependencies = 'Task2';


            const opts = {
                header_height: 50,
                column_width: 30,
                step: 24,
                view_modes: ['Quarter Day', 'Half Day', 'Day', 'Week', 'Month'],
                bar_height: 20,
                bar_corner_radius: 3,
                arrow_curve: 5,
                padding: 18,
                view_mode: 'Day',
                date_format: 'YYYY-MM-DD',
                custom_popup_html: null
            }


            var gantt = new Gantt(ganttClass, tasks );

          });


    }

}