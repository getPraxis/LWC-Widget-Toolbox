@isTest
private without sharing class VFPNamePicklistAttributeTest {
    
    @isTest
    private static void testAll() {
       
        VFPNamePicklistAttribute pickList = new VFPNamePicklistAttribute();
        VisualEditor.DynamicPickListRows rows = pickList.getValues();
        System.assert(rows.size() > 0, 'Expected some rows but got zero');

        VisualEditor.DataRow row = pickList.getDefaultValue();
        System.assert(row.getLabel().equalsIgnoreCase('No Page')); 
    }
}