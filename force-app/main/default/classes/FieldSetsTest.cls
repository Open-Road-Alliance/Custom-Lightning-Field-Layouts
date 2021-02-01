@isTest
public with sharing class FieldSetsTest {
    public static testmethod void testValues() {
        VisualEditor.DesignTimePageContext ctxt = new VisualEditor.DesignTimePageContext();
        ctxt.entityName = 'Account';
        ctxt.pageType = 'RecordPage';

        FieldSets rel = new FieldSets(ctxt);
        Integer numFieldsets = Schema.getGlobalDescribe().get(ctxt.entityName).getDescribe().fieldSets.getMap().keySet().size();

        Test.startTest();

         VisualEditor.DynamicPickListRows rows = rel.getValues();
        //  system.debug(rows.size());
        
         Test.stopTest();

        //  system.debug(rows.size());
        //  system.debug(numFieldsets);

         System.assert(rows.size() >= numFieldsets, 'Number of field sets do not match');
        // System.assertEquals(0, numFieldsets, 'Picklist default value is incorrect');
    }

    public static testmethod void testDefaultValue() {
        VisualEditor.DesignTimePageContext ctxt = new VisualEditor.DesignTimePageContext();
        ctxt.entityName = 'Account';
        ctxt.pageType = 'RecordPage';

        FieldSets rel = new FieldSets(ctxt);

        Test.startTest();

         VisualEditor.DataRow def = rel.getDefaultValue();
         VisualEditor.DynamicPickListRows rows = rel.getValues();
        
         Test.stopTest();

         System.assertEquals(rows.size() > 0 ? rows.get(0).getLabel() : '', def.getLabel(), 'Picklist default value is incorrect');
    }
}
