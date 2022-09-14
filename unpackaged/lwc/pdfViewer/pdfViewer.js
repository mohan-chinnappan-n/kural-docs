import { LightningElement, api } from 'lwc';

export default class PdfViewer extends LightningElement {
    @api fileId;
    @api height;
 
    get pdfHeight() {
        return this.height;
    }
    get url() {
        // refer doc: https://github.com/mohan-chinnappan-n/lwc-components/tree/master/pdf-viewer
        return `/sfc/servlet.shepherd/document/download/${this.fileId}`;
    }

}