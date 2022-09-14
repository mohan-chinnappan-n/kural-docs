import { LightningElement } from "lwc";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";

// import jquery & dataTables library from static resource
// get via: curl -O  https://code.jquery.com/jquery-3.6.0.min.js
// store it as jquery360 in static resources

import jquery360 from "@salesforce/resourceUrl/jquery360";

// get via:  curl -O https://datatables.net/releases/DataTables-1.10.24.zip and
// store it in static resources as jdatatable
import jdataTable from "@salesforce/resourceUrl/jdatatable";

import getOpptys from "@salesforce/apex/Jdt.getOpptys";
const columnHeaders = ["Name", "StageName", "Amount", "CloseDate", "Type"];

const columns = [
  {
    className: "details-control", // for the details td
    orderable: false,
    data: null,
    defaultContent: ""
  },
  { data: "Name" },
  { data: "StageName" },
  { data: "Amount" },
  { data: "CloseDate" },
  { data: "Type" }
];

export default class Jdt extends LightningElement {
  opportunities = []; // array property to store list of Opportunity

  getDetailsData(d) {
    // `d` is the original data object for the row
    return `<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">
        <tr><td><b>Name:</b></td><td>${d.Name}</td></tr>
        <tr><td><b>StageName:</b></td><td>${d.StageName}</td></tr>
        <tr><td><b>Amount:</b></td><td>${d.Amount}</td></tr>
        <tr><td colspan='2'>Additonal info here...</td></tr>
        </table>`;
  }

  // The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
  async connectedCallback() {
    // call apex class method which will return the list<Opportunity>
    // assign returned list of records to ‘recordsQueried’ property
    this.opportunities = await getOpptys();

    // load required jquery and datatable from org's static resources
    Promise.all([
      loadScript(this, jquery360),
      loadScript(
        this,
        jdataTable + "/DataTables-1.10.24/media/js/jquery.dataTables.min.js"
      ),
      loadStyle(
        this,
        jdataTable + "/DataTables-1.10.24/media/css/jquery.dataTables.min.css"
      )
    ]).then(() => {
      // below is possible since we have lwc:dom='manual' in the markup
      const tableEle = this.template.querySelector(".tableCls");

      // table headers <thead>
      let columnHeaderHtml = "<thead> <tr>";
      columnHeaderHtml += `<th></th>`;
      columnHeaders.forEach((header) => {
        columnHeaderHtml += `<th>${header} </th>`;
      });
      columnHeaderHtml += "</tr></thead>";
      // set <thead> element inside table element
      tableEle.innerHTML = columnHeaderHtml;

      let opptyDataTable = $(tableEle).DataTable({
        data: this.opportunities,
        columns,
        "order": [[1, 'asc']]
      });

      const elements = this.template.querySelectorAll(
        ".tableCls > tbody"
      );
      elements.forEach((ele) => {
        ele.addEventListener("click", (event) => {
          const item = event.target;
          // if you want to have this toggle available for entire row, comment out the next line
          if (!item.classList.contains('details-control')) { return }
          const parent = item.parentElement;
          const row = opptyDataTable.row(parent);
          if (row.child.isShown()) {
            // This row is already open - close it
            row.child.hide();
            parent.classList.remove('shown');
          } else {
            // Open this row
            // get the details data
            const details = this.getDetailsData(row.data());
            // console.log(details);
            row.child(details).show(); // fill the row child with details table and show it
            parent.classList.add('shown');
          }
        });
      });
    });
  }
}