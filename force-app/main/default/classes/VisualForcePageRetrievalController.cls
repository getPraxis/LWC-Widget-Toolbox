public without sharing class VisualForcePageRetrievalController {

    @AuraEnabled(cacheable=true) 
    public static List<String> getValuesForParameters(String sObjectName, String recordId, List<String> parameters) {
        List<String> paramValues = new List<String>();
        System.debug('record Id: ' + recordId);
        if (String.isNotBlank(sObjectName) && String.isNotBlank(recordId) && !parameters.isEmpty()) {
            String params = String.join(parameters, ',');
            String soql = 'SELECT ' + params + ' FROM ' + sObjectName + ' WHERE Id = :recordId LIMIT 1';
            System.debug('soql: ' + soql);
            List<SObject> values = Database.query(soql);
           
            for(String parameter : parameters) {
                paramValues.add( (String)values[0].get(parameter) );
            }
        }
        System.debug('values for Params: ' + paramValues);
        return paramValues;
    }


    @AuraEnabled(cacheable=true)
    public static List<ApexPage> getSpecificPageByNameSpaceAndPageName(String pageNameToParse) {
       
        if (String.isBlank(pageNameToParse)) { 
            return new List<ApexPage>();
        }

        String nameSpace    = '';
        String pageName     = '';

        List<ApexPage> pages;
        List<String> tokens =new List<String>();
        tokens.add(pageNameToParse.substringBefore('.'));
        tokens.add(pageNameToParse.substringAfter ('.'));
        system.debug('tokensize: ' + tokens.size());
        if (tokens.size() > 0) {
            if (String.isNotBlank(tokens[1])) {
                nameSpace = (tokens[0].equalsIgnoreCase('none')) ? '' : tokens[0];
                pageName  = tokens[1];
            } 
            else {
                nameSpace   = '';
                pageName    = tokens[0];
            }
        } 
       
        System.debug('nameSpace: ' + namespace);
        System.debug('pageName: ' + pageName);
        if (String.isBlank(nameSpace)) {
            pages = [SELECT 
                        Id, 
                        Name,
                        NamespacePrefix,
                        MasterLabel
                     FROM 
                        ApexPage 
                     WHERE
                        Name = :pageName];
        }
        else {
            pages = [SELECT 
                        Id, 
                        Name,
                        MasterLabel,
                        namespaceprefix
                     FROM 
                        ApexPage 
                     WHERE
                        Name = :pageName
                     AND 
                        nameSpacePrefix = : nameSpace];
        
        }
        return pages;
    }

    @AuraEnabled(cacheable=true)
    public static List<KeyValuePairs> getVFPByNamespaceKeyValuePairs(){
        List<ApexPage> pages = retrieveApexPagesByNamespace();
        List<KeyValuePairs> kvps = new List<KeyValuePairs>();
        try {

            for(ApexPage page : pages) {
               kvps.add( new KeyValuePairs(page));
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return kvps;
    }

    public class KeyValuePairs {
        @AuraEnabled
        public String Label {get;set;}
        public String Value {get;set;}
        public KeyValuePairs(ApexPage page) {
            String Namespace = (String.IsBlank(page.NamespacePrefix)) ? 'None' : page.NamespacePrefix;
            System.debug(page.namespacePrefix + ' - ' + page.name);
            this.Label = Namespace + '.' + page.name;
            this.Value = Namespace + '.' + page.name;
        }
    }
    //I am purposely not putting this in a Selector class because in theory this should
    //only be used once and is confined just within the scope of this component.  If this
    //should become more widely used by other components or places then a Selector
    //should be created.
    private static List<ApexPage> retrieveApexPagesByNamespace() {
        return [SELECT 
                    Id, 
                    NamespacePrefix, 
                    Name, 
                    MasterLabel 
                FROM 
                    ApexPage 
                ORDER BY 
                    NamespacePrefix, 
                    Name 
                LIMIT 
                    50000];  
    }

    /*private static Map<String,List<ApexPage> > mapPagesByNamespace() {
        List<ApexPage> pages = retrieveApexPagesByNamespace();
        Map<String, List<ApexPage> > pagesByNamespace = new Map<String, List<ApexPage> > ();

        for(ApexPage page : pages) {
            String namespace = (String.isBlank(page.NamespacePrefix)) ? 'None' : page.NamespacePrefix;
            if(!pagesByNamespace.containsKey(namespace)) {
                pagesByNamespace.put(namespace, new List<ApexPage>());
            }

            pagesByNamespace.get(namespace).add(page);
        }
        return pagesByNamespace;
    }*/
}