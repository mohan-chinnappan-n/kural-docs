import { LightningElement } from "lwc";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";

import bootstrap502 from "@salesforce/resourceUrl/bootstrap502";

export default class Bscaro extends LightningElement {
    
  async connectedCallback() {
    // load required jquery and datatable from org's static resources
    Promise.all([
      loadScript(this, bootstrap502 + "/bootstrap.bundle.min.js"),
      loadStyle(this, bootstrap502 + "/bootstrap.min.css")
    ]).then(() => {
      console.log("bootstrap loaded...");


      const caro1 = this.template.querySelector('#carousel-1');
      const carousel = new bootstrap.Carousel(caro1);


/*
      let items = this.template.querySelectorAll(".carousel .carousel-item");
      console.log(items.length);
      const minPerSlide = 4;
      
      if (items.length < 2) {
        this.template.querySelector("#nb").style.display = "none";
      } else {
        this.template.querySelector("#nb").style.display = "none2;";
      }
    

      // this.template.querySelector( "#ns").textContent = `Number of slides in the view: ${minPerSlide}`;
      items.forEach((el) => {

        console.log(el);
        let next = el.nextElementSibling;
        for (let i = 1; i < minPerSlide; i++) {
          if (!next) {
            // wrap carousel by using first child
            next = items[0];
          }
          let cloneChild = next.cloneNode(true);
          el.appendChild(cloneChild.children[0]);
          next = next.nextElementSibling;
        }
      });
      */
    });
    
  }
  
  
}