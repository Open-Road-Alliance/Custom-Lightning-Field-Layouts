public class RelatedObjects extends VisualEditor.DynamicPickList
{

    VisualEditor.DesignTimePageContext context;

    /**
     * @description Apex class constructot passing context from the Lightning Web Component
     * @param context The DesignTimePageContext to get Entity Name and Page Type
     */
    public RelatedObjects(VisualEditor.DesignTimePageContext context) {
        this.context = context;
    }

    private Map<String, String> getRelatedObjects(Schema.DescribeSObjectResult objectDesc) 
    {
        // Schema.SObjectType objectType = recordId.getSObjectType();
        // Schema.DescribeSObjectResult objectDesc = objectType.getDescribe();
        String objectName = objectDesc.getName();
        String objectLabel = objectDesc.getLabel();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String, String> relatedObjects = new Map<String, String>();
        for (String fieldName: fieldMap.keySet())
        {
            //get all the fields label for Account Object
            String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();

            //get data types for each fields
            Schema.DescribeFieldResult description = fieldMap.get(fieldName).getDescribe();
            Schema.DisplayType fielddataType = description.getType();
            if(fielddataType == Schema.DisplayType.Reference) 
            {
                Schema.SObjectType refObj = description.getReferenceTo()[0];
                Schema.DescribeSObjectResult refDesc = refObj.getDescribe();
                String name = refDesc.getName();
                // String label = refDesc.getLabel();
                relatedObjects.put(description.getLabel().replace(' ID', '') + ' (' + name + ')', description.getName() + '~~~' + name);
            }
        }

        relatedObjects.put('This ' + objectLabel, 'This_' + objectName + '__0');

        return relatedObjects;
    }

    public override VisualEditor.DataRow getDefaultValue()
    {
        Schema.DescribeSObjectResult objectDesc = ((SObject) (Type.forName(
                        'Schema.' + this.context.entityName
                    )
                    .newInstance()))
                .getSObjectType()
                .getDescribe(SObjectDescribeOptions.DEFERRED);
        String objectName = objectDesc.getName();
        String objectLabel = objectDesc.getLabel();

        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('This ' + objectLabel, 'This_' + objectName + '__0');
        return defaultValue;
    }
    
    public override VisualEditor.DynamicPickListRows getValues() 
    {
        Schema.DescribeSObjectResult objectDesc = ((SObject) (Type.forName(
                        'Schema.' + this.context.entityName
                    )
                    .newInstance()))
                .getSObjectType()
                .getDescribe(SObjectDescribeOptions.DEFERRED);

        // Schema.SObjectType objectType = recordId.getSObjectType();
        // Schema.DescribeSObjectResult objectDesc = objectType.getDescribe();
        Map<String, String> relatedObjects = getRelatedObjects(objectDesc);

        VisualEditor.DynamicPickListRows  values = new VisualEditor.DynamicPickListRows();
        for (String relatedObjectLabel : relatedObjects.keySet())
        {
            VisualEditor.DataRow val = new VisualEditor.DataRow(relatedObjectLabel, relatedObjects.get(relatedObjectLabel));
            values.addRow(val);
        }
        
        return values;
    }
}