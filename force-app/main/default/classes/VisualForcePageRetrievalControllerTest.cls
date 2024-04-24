@isTest 
private without sharing class VisualForcePageRetrievalControllerTest {
   
    @isTest
    private static void getValuesForParameters_Test() {
        Account acct = new Account(Name = 'California Test Account');
        insert acct;

        Test.startTest();
        List<String> retValues = 
            VisualForcePageRetrievalController.getValuesForParameters('Account', acct.Id, new List<String>{'Name'});
        Test.stopTest();

        System.assert(retValues.size() > 0, 'Expected at least one name returned');
        System.assert(retValues[0] == 'California Test Account', 'Expected name to be California Test Account');
    }

    @isTest
    private static void getASpecificApexPageByName() {
      
        Test.startTest();
        List<ApexPage> pages = VisualForcePageRetrievalController.getSpecificPageByNameSpaceAndPageName('ChangePassword');
        List<ApexPage> pages2= VisualForcePageRetrievalController.getSpecificPageByNameSpaceAndPageName('');
        List<ApexPage> pages3= VisualForcePageRetrievalController.getSpecificPageByNameSpaceAndPageName('namespace.test');
        Test.stopTest();

        System.Assert(pages.size() > 0, 'Expected at least one apex page');
        System.Assert(pages[0].name == 'ChangePassword', 'Expected page name to be ChangePassword');

        System.Assert(pages2.size() == 0, 'Expected no results');
        System.Assert(pages3.size() == 0, 'Expected no results');
    }
    @isTest
    private static void getAllVisualForcePagesKeyValuePairs_Test() {

        Test.startTest();
        List<VisualForcePageRetrievalController.KeyValuePairs> kvps = VisualForcePageRetrievalController.getVFPByNamespaceKeyValuePairs();
        Test.stopTest();

        System.assert(kvps.size() > 0, 'Expected at least one visual force page');
    }
}