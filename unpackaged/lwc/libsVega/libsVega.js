import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import VEGA from '@salesforce/resourceUrl/vega';
export default class LibsVega extends LightningElement {

    vegaInitialized = false;

    renderedCallback() {
        if (this.vegaInitialized) {
            return;
        }
        this.vegaInitialized = true;

        Promise.all([
            loadScript(this, VEGA + '/vega-embed.6.12.2.js'),
            loadScript(this, VEGA + '/vega-lite.4.17.0.js '),
            loadScript(this, VEGA + '/vega.5.17.0.js')

        ])
            .then(() => {
                this.initializeVega();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Vega libs',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }


    initializeVega() {
        console.log('initializeVega');

        const yourVlSpec = {
            $schema: 'https://vega.github.io/schema/vega-lite/v4.json',
            description: 'A simple bar chart with embedded data.',
            data: {
              values: [
                {a: 'A', b: 28},
                {a: 'B', b: 55},
                {a: 'C', b: 43},
                {a: 'D', b: 91},
                {a: 'E', b: 81},
                {a: 'F', b: 53},
                {a: 'G', b: 19},
                {a: 'H', b: 87},
                {a: 'I', b: 52}
              ]
            },
            mark: 'bar',
            encoding: {
              x: {field: 'a', type: 'ordinal'},
              y: {field: 'b', type: 'quantitative'}
            }
          };
          vegaEmbed('.vis', yourVlSpec)
          .then(result => console.log(result))
          .catch(console.warn);



    }


}