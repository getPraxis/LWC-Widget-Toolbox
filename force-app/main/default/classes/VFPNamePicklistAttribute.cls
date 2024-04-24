global without sharing class VFPNamePicklistAttribute extends VisualEditor.DynamicPickList {
   
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('No Page', 'None.None');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  pageNames = new VisualEditor.DynamicPickListRows();
        List<VisualForcePageRetrievalController.KeyValuePairs> kvps = VisualForcePageRetrievalController.getVFPByNamespaceKeyValuePairs();
        for (VisualForcePageRetrievalController.KeyValuePairs kvp : kvps) {
            pageNames.addRow( new VisualEditor.DataRow(kvp.Label, kvp.Value));
        }

        return pageNames;
    }
}