import { LightningElement, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import fg from '@salesforce/resourceUrl/fg';

import {GanttUtil} from 'c/ganttUtil';
import { getAnalyticsLimits } from 'lightning/analyticsWaveApi';


export default class Fgantt extends LightningElement {
    @api recordId;
    @track error;
    @track chartjsInitialized = false;
    @track viewMode = 'day';

x

    async connectedCallback() {
       //  renderedCallback () {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;
        console.log('chart loading');
        // https://mohansun-ea-02-dev-ed.lightning.force.com/resource/1648309758000/fg/js/moment.js
        // https://github.com/salesforce/lwc/issues/2640
        Promise.all([
            // loadScript(this, fg + "/js/jquery360.js"),

             loadScript(this, fg + "/js/snap.svg.js"), // --- not getting loaded, getting undefined error
            // loadScript(this, fg + "/js/moment.js"),
            loadScript(this, fg + "/js/fg.js"),
            loadStyle(this, fg + "/css/fg.css")
        ])
        .then(() => {
            console.log('----OK -----');
            var chartClass = this.template.querySelector(".gantt");
            var tasks = [
                {
                id: 'Task 1',
                name: 'Redesign website',
                start: '2016-10-28',
                end: '2017-02-31',
                progress: 20
                },
                {
                    id: 'Task 1',
                    name: 'Redesign website',
                    start: '2016-12-28',
                    end: '2017-04-31',
                    progress: 20
                }
            ]

        //var gantt = new Gantt(chartClass, tasks);
        // gantt.change_view_mode('Month');

        // this.drawCircles(chartClass);

        const gu = new GanttUtil();
        gu.drawCircles(chartClass, Snap);
        console.log('parsedDate',  gu.date_utils.parse('2022-10-12'));
        console.log('padStart', gu.padStart('apple', 20, '$'));
      
        console.log('createSVG', gu.createSVG('g', {class: 'bar-group'}))


        })
        .catch(error => {
            this.error = error;
            console.log('Error:----> ' + error);
        });
    }
}