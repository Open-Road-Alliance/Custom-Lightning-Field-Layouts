@isTest
public with sharing class RelatedObjectsTest {
    public static testmethod void testValues() {
        VisualEditor.DesignTimePageContext ctxt = new VisualEditor.DesignTimePageContext();
        ctxt.entityName = 'Account';
        ctxt.pageType = 'RecordPage';

        RelatedObjects rel = new RelatedObjects(ctxt);

        Test.startTest();

         VisualEditor.DynamicPickListRows rows = rel.getValues();
        
         Test.stopTest();

         System.assert(rows.size() > 0, 'No picklist values for Account');
    }

    public static testmethod void testDefaultValue() {
        VisualEditor.DesignTimePageContext ctxt = new VisualEditor.DesignTimePageContext();
        ctxt.entityName = 'Account';
        ctxt.pageType = 'RecordPage';

        RelatedObjects rel = new RelatedObjects(ctxt);

        Test.startTest();

         VisualEditor.DataRow def = rel.getDefaultValue();
        
         Test.stopTest();

         System.assertEquals('This Account', def.getLabel(), 'Picklist default value is incorrect');
    }
}
