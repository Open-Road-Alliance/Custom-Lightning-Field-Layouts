public class FieldSets extends VisualEditor.DynamicPickList
{
    VisualEditor.DesignTimePageContext context;

    /**
     * @description Apex class constructot passing context from the Lightning Web Component
     * @param context The DesignTimePageContext to get Entity Name and Page Type
     */
    public FieldSets(VisualEditor.DesignTimePageContext context) {
        this.context = context;
    }

    private static Map<String, String> getFieldSetNames(Schema.DescribeSObjectResult objectDesc) 
    {
        // Schema.SObjectType objectType = recordId.getSObjectType();
        // Schema.DescribeSObjectResult objectDesc = objectType.getDescribe();
        String objectName = objectDesc.getName();
        String objectLabel = objectDesc.getLabel();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(objectName);
        Map<String, String> fieldSets = new Map<String, String>();
        Map<String, Schema.FieldSet> fieldSetsMap = objSchema.getDescribe().fieldSets.getMap();

        // Grab field sets for current object
        for (String f : fieldSetsMap.keySet())
        {
            Schema.FieldSet fs = fieldSetsMap.get(f);
            String label = fs.getLabel() + ' (' + objectLabel + ')';

            fieldSets.put(label, fs.getName());
        }

        // Loop through fields
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
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

                if (name != objectName)
                {
                    objSchema = schemaMap.get(name);
                    fieldSetsMap = objSchema.getDescribe().fieldSets.getMap();

                    for (String f : fieldSetsMap.keySet())
                    {
                        Schema.FieldSet fs = fieldSetsMap.get(f);
                        String label = fs.getLabel() + ' (' + refDesc.getLabel() + ')';

                        fieldSets.put(label, fs.getName());
                    }
                }
            }
        }

        return fieldSets;
    }
    
    public override VisualEditor.DynamicPickListRows getValues()
    {
        Schema.DescribeSObjectResult objectDesc = ((SObject) (Type.forName(
                        'Schema.' + this.context.entityName
                    )
                    .newInstance()))
                .getSObjectType()
                .getDescribe(SObjectDescribeOptions.DEFERRED);
        Map<String, String> fieldSets = getFieldSetNames(objectDesc);

        VisualEditor.DynamicPickListRows  values = new VisualEditor.DynamicPickListRows();
        for (String fieldSetLabel : fieldSets.keySet())
        {
            VisualEditor.DataRow val = new VisualEditor.DataRow(fieldSetLabel, fieldSets.get(fieldSetLabel));
            values.addRow(val);
        }
        
        return values;
    }

    public override VisualEditor.DataRow getDefaultValue()
    {
        VisualEditor.DynamicPickListRows values = getValues();

        return values.size() > 0 ? values.get(0) : new VisualEditor.DataRow('', '');
    }
}