import { LightningElement, api, track, wire } from 'lwc';
import getApexPage from '@salesforce/apex/VisualForcePageRetrievalController.getSpecificPageByNameSpaceAndPageName';
import getParameterValues from '@salesforce/apex/VisualForcePageRetrievalController.getValuesForParameters';


export default class VisualForcePageHost extends LightningElement {
    //https://aphria--sit--rstkf.visualforce.com/apex/apinvh?Id={recordId}
    //https://https://aphria--sit--rstkf.visualforce.com/apex/cashreceiptsjournal
   
    baseUrl=undefined;
    storedPageValue = undefined;
    showIFrame = false;
    fields = [];
    localParameter2LookupField=undefined;
    localParameter2LookupActualValue=undefined;
    
    @api pageHeight;
    @api vfpChosenFromDesigner;
    @api recordId;
    @api parameterName;
    @api parameterLookupField;
    @api Parameter2Name;
    @api objectApiName;

    @api
    get Parameter2LookupField() {
       return this.localParameter2LookupField;
    }

    set Parameter2LookupField(value) {
        this.localParameter2LookupField = value;
    }
   
    @track src = '';
    
    connectedCallback() {
        this.baseUrl =  window.location.origin.split(/[.]/)[0];   
        console.log('Record Id: ' , this.recordId);
        console.log('Object Name: ' , this.objectApiName);   
    }


    /*@wire(getRecord, {recordId: '$recordId', fields: '$fields'})
     localObject;*/

    @wire(getApexPage, { pageNameToParse : '$vfpChosenFromDesigner'})
    wiredPages({ error, data }) {
        console.log()
        if (data) {
            if (data.length) {
                this.storedPageValue = data[0];
                this.src = this.generateUrl(this.storedPageValue);
                this.showIFrame = true;
            }
    
            if (this.localParameter2LookupField && this.localParameter2LookupField !== 'None' && 
                this.recordId && this.objectApiName ) {
                this.getParameterValueFromApex(this.storedPageValue);
            }
        } 
        else if (error) {
            console.log('error: ' + JSON.stringify(error));
        }
    }
  
    getParameterValueFromApex(apexPage) {
        let pageValue =apexPage
        getParameterValues({sObjectName : this.objectApiName, recordId: this.recordId, parameters : [this.localParameter2LookupField]})
        .then(result => {
            this.localParameter2LookupActualValue = result[0];
            if(pageValue) {
                this.src = this.generateUrl(pageValue);
            }
        });
    }
    generateUrl(pageValue) {
        let visualForce = (pageValue.NamespacePrefix) ? this.baseUrl + '--' + pageValue.NamespacePrefix : this.baseUrl;
        visualForce += '.visualforce.com/apex/' + pageValue.Name + '?' + this.parameterName + '=' + this.recordId;
        if(this.Parameter2Name && this.localParameter2LookupActualValue) {
            visualForce += (this.Parameter2Name) ? '&' + this.Parameter2Name + '='  + this.localParameter2LookupActualValue: '' ;
        }
        console.log('VFP URL: ', visualForce);
        return visualForce;
    }
}