@isTest
public with sharing class RecordDetailsTest {
    public static testmethod void testValues() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;

        Map<String, Schema.FieldSet> fieldSets = Schema.getGlobalDescribe().get('Account').getDescribe().fieldSets.getMap();
        Set<String> keySet = fieldSets.keySet();
        List<String> keys = new List<String>();

        keys.addAll(keySet);

        String fieldSetName = keys.size() > 0 ? fieldSets.get(keys.get(0)).getName() : '';

        RecordDetails.setMock(new List<SObjectField> { Account.Name, Account.AnnualRevenue });   

        Test.startTest();
        RecordDetails.FieldLayout res = RecordDetails.getFieldList(acc.Id, 'This_Account__0', fieldSetName);
        RecordDetails.FieldLayout res2 = RecordDetails.getFieldList(acc.Id, 'This_Account__0', '');
        Test.stopTest();

        system.assertEquals(acc.Id, res.recordId, 'Does not match');

    }
}
