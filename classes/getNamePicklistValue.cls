public class getNamePicklistValue {
    // private static final String EXCHANGERATE_URL = 'https://api.exchangeratesapi.io/latest?base=GBP';
    // private static final String GET = 'GET';
        
    // public class rates{
    //     public String CAD;
    //     public String HKD;
    //     public String ISK;
    //     public String PHP;
    //     public String DKK;
    //     public String HUF;
    //     public String CZK;
    //     public String GBP;
    //     public String RON;
    //     public String SEK;
    //     public String IDR;
    //     public String INR;
    //     public String BRL;
    //     public String RUB;
    //     public String HRK;
    //     public String JPY;
    //     public String THB;
    //     public String CHF;
    //     public String EUR;
    //     public String MYR;
    //     public String BGN;
    //     //public String TRY;
    //     public String CNY;
    //     public String NOK;
    //     public String NZD;
    //     public String ZAR;
    //     public String USD;
    //     public String MXN;
    //     public String SGD;
    //     public String AUD;
    //     public String ILS;
    //     public String KRW;
    //     public String PLN;

    // }

    // public class met {
    //     public rates rates;
    //     public String base;
    //     public Date data;
    // }
    
    
    // // Получение значений Picklist для запроса по валютам
    // public List<String> getNamePicklistValue1() {
    //     List<String> listNamePicklistValue = new List<String>();
    //     //Получение описания объекта Exchange Rate, поля Base Currency
    //     Schema.DescribeFieldResult fieldResult = Exchange_Rate__c.Base_Currency__c.getDescribe();
    //     //Получение полного описания всех значений PickList 
    //     List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
    //     //Цикл для получения листа значений имени PickList
    //     for( Schema.PicklistEntry  pickListEntry : pickListEntries){
    //         String currencyOption = pickListEntry.getValue();
    //         listNamePicklistValue.add(currencyOption);
    //     	System.debug(currencyOption);
    //     } 
	// 	return listNamePicklistValue;
    // }
    

//    SObjectType objToken = Schema.getGlobalDescribe().get('Exchange_Rate__c');
//        DescribeSObjectResult objDef = objToken.getDescribe();
//        Map<String, SObjectField> fields = objDef.fields.getMap();
//        Set<String> fieldSet = fields.keySet();
//         for(String s:fieldSet)
//         {
//            SObjectField fieldToken = fields.get(s);
//            DescribeFieldResult selectedField = fieldToken.getDescribe();
//            System.debug(selectedField.getName());
//         }
//       Map<String, Schema.SObjectField> prodFieldMap = null;


    // Это то что должно быть
    // public void getNameFields(){
    //     SObjectType exchangeRateObject = Schema.getGlobalDescribe().get(NAMEOBJECT);
    //     Map<String, SObjectField> currencyFields = exchangeRateObject.getDescribe().fields.getMap();
    //     // Schema.SObjectTypeFields
    //     Set<String> newListstring = currencyFields.keySet();
    //     for(String s : newListstring){
    //         SObjectField tt = currencyFields.get(s);
    //         DescribeFieldREsult nn = tt.getDescribe();
    //         System.debug(nn.getLabel());
            
    //     }
    // }
    private final String NAMEOBJECT = 'Exchange_Rate__c';

    public static Map<String, String> getNameFields(){
        Map<String, String> typeCurrency = new Map<String, String>();
        SObjectType exchangeRateObject = Schema.getGlobalDescribe().get('Exchange_Rate__c');
        Map<String, SObjectField> allFields = exchangeRateObject.getDescribe().fields.getMap();
        // Schema.SObjectTypeFields
        Set<String> newStringFields = allFields.keySet();
        for(String str : newStringFields){
            SObjectField oneField = allFields.get(str);
            DescribeFieldREsult fieldsValue = oneField.getDescribe();
            if (fieldsValue.getType() == Schema.DisplayType.CURRENCY){
                typeCurrency.put(fieldsValue.getName(), fieldsValue.getLabel());
                //System.debug(typeCurrency);
            } 
        } 
        //System.debug(typeCurrency);
        return typeCurrency; 
    }
}