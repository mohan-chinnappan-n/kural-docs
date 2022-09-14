import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import D3 from '@salesforce/resourceUrl/d3lib';
import SLIDER  from '@salesforce/resourceUrl/d3slider'; 


export default class Slider extends LightningElement {

  svgWidth = 400;
  svgHeight = 400;
  rangeValue = "";

  d3Initialized = false;

  renderedCallback() {
      if (this.d3Initialized) {
          return;
      }
      this.d3Initialized = true;

      Promise.all([
          loadScript(this, D3 + '/d3.v5.min.js'),
          loadScript(this, SLIDER +  '/d3-simple-slider.min.js')

      ])
          .then(() => {
              console.log('Libs are loaded');
              this.initializeD3();  
          })
          .catch(error => {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error loading D3',
                      message: error.message,
                      variant: 'error'
                  })
              );
          });
  }

  initializeD3() {

    const data = [0, 100];
    const width = 800;

    const current = [20,40];
    const ticks = 10;
    const fillColor = '#ff99cc';
    console.log(this.template.querySelector('div.slider'));
    const sliderDiv = d3.select(this.template.querySelector('div.slider'));
    const sliderValueDiv = d3.select(this.template.querySelector('div.vrange'));

    // Range
    const sliderRange = d3
      .sliderBottom()
      .min(d3.min(data))
      .max(d3.max(data))
      .width(width)
      .ticks(ticks)
      .default(current)
      .fill(fillColor);

      sliderRange.on('onchange', val => {
        console.log('onchange');
        sliderValueDiv.text(val.map(d3.format('d')).join('-'));
      });
     
      sliderDiv
      .append('svg')
      .attr('width', width + 100)
      .append('g')
      .attr('transform', 'translate(10,10)')
      .call(sliderRange);
    
    this.rangeValue = sliderRange.value().join('-'); 
    sliderValueDiv.text( this.rangeValue);

        

       
  }

}