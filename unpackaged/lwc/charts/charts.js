import { LightningElement, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import chartJs from '@salesforce/resourceUrl/chartJs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Charts extends LightningElement {

    get options() {
        return [
            { label: 'Bar', value: 'bar' },
            { label: 'Doughnut', value: 'doughnut' }
        ];
    }
    error;
    chart;
    ctx;
    chartjsInitialized = false;
    config;
    // chartType = 'doughnut';
    @api ctype = 'doughnut';
    @api cdata = [10,20,11,22];
    @api cbgcolors =  ['#99ccff', '#ff99cc', '#cc99ff', '#ffcc99'];
    @api clabel = 'Idea Status';
    // https://www.chartjs.org/docs/latest/general/colors.html

    
    handleChange(event) {
        this.config.type = event.target.value;
        this.chart = new window.Chart(this.ctx, this.config);
    }
    renderedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;

        Promise.all([
            loadScript(this, chartJs + '/Chart.min.js'),
            loadStyle(this, chartJs + '/Chart.min.css')
        ]).then(() => {
             this.config = {
                    type: this.ctype,
                    data: {
                        datasets: [
                            {
                                data:  this.cdata,
                                backgroundColor: this.cbgcolors,
                                label: this.clabel
                            }
                        ],
                        labels: ['Open', 'Closed', 'Under Review', 'New']
                    },
                    options: {
                        responsive: true,
                        legend: {
                            position: 'right'
                        },
                        animation: {
                            animateScale: true,
                            animateRotate: true
                        }
                    }
                };
                // disable Chart.js CSS injection
                window.Chart.platform.disableCSSInjection = true;

                const canvas = document.createElement('canvas');
                // append canvas to the div
                this.template.querySelector('div.chart').appendChild(canvas);
                this.ctx = canvas.getContext('2d');
                this.chart = new window.Chart(this.ctx, this.config);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Chart',
                        message: 'Chart rendering Complete',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in rendering chart',
                        message: error.message,
                        variant: 'error'
                    })
                );
                alert(error);
            });
    }
}