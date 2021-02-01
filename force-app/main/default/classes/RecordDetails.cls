// public with sharing class RecordDetails {
//     @AuraEnabled(cacheable=true)
//     public static List<Schema.FieldSetMember> getFields(String sObjectName, String fieldSetName) 
//     {
//         try 
//         {
//             Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
//             Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(sObjectName);
//             Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();

//             Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

//             return fieldSetObj.getFields(); 
//         } catch (Exception e) {
//             throw new AuraHandledException(e.getMessage());
//         }
        
//     }
// }

public with sharing class RecordDetails {

    private static List<IFieldSetMember> getFields(String apiName, String fieldSetName) {
        /*
            Gets the fields to display from the field set. 
            INPUT 
                APIName         : (Account, customobject__c)
                FieldSetName    : Name of associated field set

            OUTPUT
                Fields within the Fieldsetname
        */
        // All sObject names
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
        // Object that we are iterested in
        Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(apiName);
        // Description for object that we are interested in
        Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
        // FieldSetNames associated with this object 
        //Map<String,Schema.FieldSet> fieldSetObj = describeSObjectResultObj.FieldSets.getMap();
        // Populate fieldset class with the fields from fieldsetname that we are intersted in
        // Schema.FieldSet aFieldSet = fieldSetObj.get(fieldSetName);

        // return aFieldSet.getFields();        
        return construct(describeSObjectResultObj.fieldSets.getMap().get(fieldSetName));
    }

// private static List<String> getFieldSet(String objectApiName, String fieldSetName) 
// {
//     Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
//         Schema.SObjectType schema = schemaMap.get(objectApiName);
//         Map<String, String> fieldSets = new Map<String, String>();
//         Map<String, Schema.FieldSet> fieldSetsMap = schema.getDescribe().fieldSets.getMap();
//         Schema.FieldSet fieldSet = fieldSetsMap.get(fieldSetName);
//     /*
//         Returns fieldsetnames that we are interested in using.  Method makes a call to a custom metadata type that allows sytem administrators to define which fieldsets they are interested in displaying.

//         INPUT
//             objectApiName: Object with FieldSet
//         OUTPUT
//             Fieldsetname associated with the object
//     */
//     list_APIName__mdt list_APIName = [SELECT Id FROM list_APIName__mdt WHERE Label = :objectApiName]; 
//     List<List_Field_Set_Name__mdt> fieldSets = [SELECT Id, DeveloperName, List_APIName__c FROM List_Field_Set_Name__mdt WHERE List_APIName__c = :list_APIName.Id];

//     List<String> Results = new List<String>();

//     for (List_Field_Set_Name__mdt fieldSet : fieldSets) {
//         Results.add(fieldSet.DeveloperName);
//     }
//     return Results;
// }

    @AuraEnabled(cacheable=true)
    public static FieldLayout getFieldList(Id recordId, String picklistValue, String fieldSetName) {
        try
        {

        
        /*
            Queries object based on the fields listed in their fieldsetname.  Using LWC record Id and ObjectApiName, we can determine what object we are looking at and populate data accordingly.

            INPUT
                recordId        : ID passed from current record
                objectAPIName   : ObectAPIName of record
            OUTPUT
                Field Name and Field value
        */
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

            String objectName = picklistValue.contains('~~~') ? picklistValue.split('~~~')[1] : picklistValue.replace('This_', '').replace('__0', '');
            String fieldName = picklistValue.contains('~~~') ? picklistValue.split('~~~')[0] : '';
            Schema.SObjectType recordObjectType = recordId.getSObjectType();
            Schema.DescribeSObjectResult recordDesc = recordObjectType.getDescribe();
            Map<String, Schema.SObjectField> recordFields = recordDesc.fields.getMap();
            Id lookupId;

            if (fieldName != '') {
                SObject record = database.query('SELECT ' + String.escapeSingleQuotes(fieldName) + ' FROM ' + String.escapeSingleQuotes(recordDesc.getName()) + ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\'');
                lookupId = (Id) record.get(fieldName);
            }
            
            Schema.SObjectType objectType = schemaMap.get(objectName);
            Schema.DescribeSObjectResult objectDesc = objectType.getDescribe();
                // String objectName = objectDesc.getName();
            // query string to build
            Id recordOrLookupId = picklistValue == 'This_' + recordObjectType + '__0' ? recordId : lookupId;
            String query = 'SELECT ';

            // List of field set names associated with object
            // List<String> fieldSetNames = getFieldSet(objectName, fieldSetName);
            // Fields in each field set name
            List<String> fieldDescriptions = new List<String>(); 

            // Get the field set name
            // for (String fieldSetName : fieldSetNames) {
                // If we have fields, add them to the list
                for(RecordDetails.IFieldSetMember f : getFields(objectName, fieldSetName)) {
                    if (f.getFieldPath() != 'Id') {
                    query += f.getFieldPath() + ', ';
                    fieldDescriptions.Add(f.getFieldPath());
                    }
                } 

            // }

            // Query for the fields that we have in our list
            query += 'Id FROM '+ objectName +' WHERE ID=\''+recordOrLookupId+'\'';

            // Instantiate object 
            SObject obj = recordOrLookupId.getSObjectType().newSObject(recordOrLookupId);

            obj = database.query(query);

            // Add values to a generic object tha can be used to display on any page
            FieldLayout layout = new FieldLayout();
            layout.recordId = recordOrLookupId;
            layout.objectApiName = objectName;
            List<FieldDefinition> field = new List<FieldDefinition>();
            List<String> fieldArray = new List<String>();
            for (String f : fieldDescriptions) {
                if ((Obj.get(f) != null) || (obj.get(f) != '')){
                    FieldDefinition fieldDef = new FieldDefinition();
                    fieldDef.apiFieldName = f;
                    fieldDef.fieldValue   = String.valueOf(obj.get(f));
                    if ((fieldDef.fieldValue != null) && (fieldDef.fieldValue != ''))
                    {
                        field.Add(fieldDef);
                    }
                    fieldArray.add(f);
                }
            }
            layout.fieldArray = fieldArray;
            layout.fieldDefinitions = field;
            return layout;
        }
        catch(Exception e)
        {
            //throw new AuraHandledException(e.getMessage());
            FieldLayout layout = new FieldLayout();
            layout.recordId = recordId;
            layout.errorMessage = e.getMessage();
            return layout;
        }
    }

    public class FieldDefinition {
        @AuraEnabled
        public String apiFieldName {get;set;}
        @AuraEnabled
        public String fieldValue {get;set;}
    }

    public class FieldLayout {
        @AuraEnabled
        public String recordId {get;set;}
        @AuraEnabled
        public String objectApiName {get;set;}
        @AuraEnabled
        public List<FieldDefinition> fieldDefinitions {get;set;}
        @AuraEnabled
        public List<String> fieldArray {get;set;}
        @AuraEnabled
        public String errorMessage {get;set;}
    }

    public interface IFieldSetMember {
            //  public interface IFieldSetMember
// {
    // Boolean getDBRequired();
    String getFieldPath();
    // String getLabel();
    // Boolean getRequired();
    // Schema.DisplayType getType();
// }
}

    //private FieldSetMemberListFactory() {} 

     private static List<IFieldSetMember> mockFieldSetMemberList;

     /** 
      * Constructs a IFieldSetMember list based on the given field set
      **/
     public static List<IFieldSetMember> construct(Schema.FieldSet fieldSet)
     {
          // Return the mock response?
          if (Test.isRunningTest() && mockFieldSetMemberList!=null) 
          {
              return mockFieldSetMemberList;
          } 
          else 
          {
              // Return the actual response from an actual FieldSet resolved at runtime
          List<IFieldSetMember> fieldSetMemberList = new List<IFieldSetMember>();
          for(Schema.FieldSetMember member : fieldSet.getFields())
          {
              fieldSetMemberList.add(new RuntimeContextImpl(member));
          }
          return fieldSetMemberList;
          }
     }

     /**
      * Provides a mock response to the 'construct' method during a test context
      **/
     
     @TestVisible private static void setMock(List<SObjectField> mockFields)
     {
          // Mocks the list of fields via a list of SObjectField's
          mockFieldSetMemberList = new List<IFieldSetMember>();
          for(SObjectField field : mockFields)
          {
              mockFieldSetMemberList.add(new TestContextImpl(field));
          }
     }

     public class RuntimeContextImpl implements IFieldSetMember
     {
         public Schema.FieldSetMember fieldSetMember;
            // Implement the constructor and methods by delegating to Schema.FieldSetMember methods
            public String getFieldPath() 
            {
                return fieldSetMember.getFieldPath();
            }

            public RuntimeContextImpl(Schema.FieldSetMember fieldSetMember)
            {
                this.fieldSetMember = fieldSetMember;
            }
     }

     public class TestContextImpl implements IFieldSetMember
     {
         public SObjectField field;

          // Implement the constructor and methods by delegating to SObjectField.getDescribe result
            public String getFieldPath() 
            {
                return field.getDescribe().getName();
            }

            public TestContextImpl(SObjectField field)
            {
                this.field = field;
            }
     }
}
