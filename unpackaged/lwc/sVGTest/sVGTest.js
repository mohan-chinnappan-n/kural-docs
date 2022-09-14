import { LightningElement } from 'lwc';

export default class SVGTest extends LightningElement {

    title = "SVG Test";

    circles = [
        {id: 1, r:10 ,cx: 50, cy:50, fill: '#99ccff'},
        {id: 2, r:20 ,cx: 70, cy:70, fill: '#cc99ff'},
        {id: 3, r:30 ,cx: 80, cy:80, fill: '#ff99cc'}
    ];
 


}