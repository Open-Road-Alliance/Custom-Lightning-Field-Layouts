import { LightningElement, wire, track, api } from "lwc";
// export default class CustomLightningFieldLayouts extends LightningElement {}
import fieldSetFields from "@salesforce/apex/RecordDetails.getFieldList";

export default class MyFieldSetComponent extends LightningElement {
  @track accs;
  @track error;
  @api recordId;
  @api object;
  @api fieldSet;
  @api icon;
  @api title;
  @api columns;
  @api mode;
  @api isReadOnly;

  @wire(fieldSetFields, {
    recordId: "$recordId",
    picklistValue: "$object",
    fieldSetName: "$fieldSet"
  })
  fieldList;

  get fields() {
    console.log(this);
    return this.fieldList.data.fieldArray;
  }

  get rid() {
    return this.fieldList.data.recordId;
  }

  get objName() {
    return this.fieldList.data.objectApiName;
  }

  get displayMode() {
    return this.isReadOnly ? "readonly" : this.mode;
  }

  handleSubmit(event) {
    event.preventDefault(); // stop the form from submitting
    const fields = event.detail.fields;
    // fields.LastName = "My Custom Last Name"; // modify a field
    this.template.querySelector("lightning-record-form").submit(fields);
  }
}
