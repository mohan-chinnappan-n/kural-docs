import { LightningElement, api } from 'lwc';

export default class Caro extends LightningElement {

spv = 1;

@api 
get slidesPerView() {
    return this.spv;
}
set slidesPerView(data) {
    this.spv = Number(data);
}


// =======
  slides = [];
  // getters and setting for slidesData
  @api 
  get slidesData() {
      return this.slides;

  };

  // when the data is passed to this component
  //   massage it
  set slidesData(data) {
    this.slides =   data.map((item, index) => {
          return index < this.spv ? {
              ...item,
              index,
              sindex: index+1,
              classes: 'slds-show',
              dotClasses: 'dot active'
          } : {
              ...item,
              index,
              sindex: index+1,

              classes: 'slds-hidden',
              dotClasses: 'dot'

          }
      });
  }



}