@isTest
private without sharing class VFPNameObjectLookupsAttributeTest {
  
    @isTest
    private static void testAllValues() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName  = 'Account';
        context.pageType    = 'RecordPage';
        VFPNameObjectLookupsAttribute objectLookup = new VFPNameObjectLookupsAttribute(context);
        VisualEditor.DynamicPickListRows rows = objectLookup.getValues();
        System.assert(rows.size() > 0, 'Expected some rows but got zero');

        VisualEditor.DataRow row = objectLookup.getDefaultValue();
        System.assert(row.getLabel().equalsIgnoreCase('none'));
    }
}