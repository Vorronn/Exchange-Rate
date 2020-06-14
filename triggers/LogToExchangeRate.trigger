trigger LogToExchangeRate on Log__c (after insert, after update) {
    //Создание списка SObject на основании Exchange_Rate__c
    List<SObject> newRate = new List<Exchange_Rate__c>();
    for(Log__c lg : Trigger.new){
        if(lg.Status_Code__c == '200'){
            //Десериализация Response_Body__c
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(lg.Response_Body__c);
            //Выделение записей rates
            Map<String, Object> rates = (Map<String, Object>) responseBody.get('rates');

            //Создание объекта SObject и заполнение его полей
            SObject oneRate = new Exchange_Rate__c();
            oneRate.put('Name', lg.Name);
            oneRate.put('Log__c', lg.Id);
            oneRate.put('Date__c', Date.valueOf(String.valueOf(responseBody.get('date'))));
            oneRate.put('Base_Currency__c', String.valueOf(responseBody.get('base')));

            //Получение объекта типа Exchange_Rate__c
            SObjectType exchangeRateObject = Schema.getGlobalDescribe().get('Exchange_Rate__c');
            //Получение всех полей выбранного объекта
            Map<String, SObjectField> allFields = exchangeRateObject.getDescribe().fields.getMap();
            //Устанавливаем список ключей всех полей
            Set<String> newStringFields = allFields.keySet();
            //Проходим циклом по всем полям для записи нужных нам полей
            for(String str : newStringFields){
                SObjectField oneField = allFields.get(str);
                DescribeFieldREsult fieldsValue = oneField.getDescribe();
                //Получение полей типа CURRENCY и запись их в SObject
                if (fieldsValue.getType() == Schema.DisplayType.CURRENCY){
                    oneRate.put(fieldsValue.getName(), Decimal.valueOf(String.valueOf(rates.get(fieldsValue.getLabel()))));
                } 
            } 
            newRate.add(oneRate);
        }
    }
    insert newRate;
}