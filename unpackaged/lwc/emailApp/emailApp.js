import { LightningElement, api } from 'lwc';

export default class EmailApp extends LightningElement {
    @api messageBody;
    @api subject;
    @api people;
}