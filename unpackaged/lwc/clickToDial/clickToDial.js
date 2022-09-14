import { LightningElement } from 'lwc';
const columns = [
    { label: 'Label', fieldName: 'name' },
    { label: 'Phone', fieldName: 'phone', type: 'phone' },
];
const   data = [
    {name: "Dennis Ritchie", phone: "12007878000"},
    {name: "Ken Thompson", phone: "12007878001"}

]

export default class ClickToDial extends LightningElement {
    data =  data;
    columns = columns;
}