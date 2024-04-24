global without sharing class VFPNameObjectLookupsAttribute extends VisualEditor.DynamicPickList {
    VisualEditor.DesignTimePageContext context;

    global VFPNameObjectLookupsAttribute(VisualEditor.DesignTimePageContext context) {
       this.context = context;
    }

    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  lookupRows = new VisualEditor.DynamicPickListRows();

        List<String> lookupFields = getLookupFieldsFromObject(context.entityName);
        lookupRows.addRow(new VisualEditor.DataRow('None','None'));
        for (String  lookupField : lookupFields) {
            lookupRows.addRow( new VisualEditor.DataRow(lookupField, lookupField));
        }
        return lookupRows;
    }

    private List<String> getLookupFieldsFromObject(String objectName) {
        System.debug('objectName: ' + objectName);
        Map<String, Schema.SObjectField> objectFields
                                = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        List<String> lookupFieldNames = new List<String>();
        for(Schema.SObjectField fld :objectFields.values()){
            schema.describeFieldResult dfield = fld.getDescribe();
            string fldType = string.valueOf(dfield.getType());   
            if (fldType == 'REFERENCE'){ // Lookup field!
                lookupFieldNames.add(string.valueOf(dfield.Name));
            }
        }
        return lookupFieldNames;
    }
}