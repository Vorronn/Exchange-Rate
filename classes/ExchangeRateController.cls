public with sharing class ExchangeRateController {     

    //Функция возращающая значения для класса обертки и передачи его в Lightning component
    @AuraEnabled
    public static WrapperRates.WrapperRatesTable getWrapperTable(String currentDate){
        WrapperRates.WrapperRatesTable newWrapperRates = new WrapperRates.WrapperRatesTable();
        newWrapperRates.exchangeRate = objectToWrapper(currentDate);
        newWrapperRates.wrapPickList = getNamePicklistValue();
        return newWrapperRates;
    }

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    //Функция для получения полей типа currency
    public static Map<String, DescribeFieldREsult> getMapFieldTypeCurrency(){
        Map<String, DescribeFieldREsult> fieldsTypeCurrency = new Map<String, DescribeFieldREsult>();
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
            //Если поле имеет тип CURRENCY то мы его добавляем в нашу Map
            if (fieldsValue.getType() == Schema.DisplayType.CURRENCY){
                fieldsTypeCurrency.put(fieldsValue.Name, fieldsValue);
            } 
        } 
        return fieldsTypeCurrency;
    }

    //Функция получения строки курсов валют используемых в нашем объекте, для добавления их в SOQL запрос
    public static String getStringFieldsTypeCurrency(){
        String fieldsTypeCurrency = '';
        //Получаем Map где записаны все CURRECY поля из функции getMapFieldTypeCurrency
        Map<String, DescribeFieldREsult> fieldsCurrency = getMapFieldTypeCurrency();
        //Проходим циклом и записываем их в одну строку
        for(String key : fieldsCurrency.keySet()){
            fieldsTypeCurrency += ', ' + key;
        }
        //Возвращаем строку, в дальнейшем для добавления их для SOQL запроса
        return fieldsTypeCurrency;
    }

    //Функуция Http запроса если нашего объекта на данную дату нету в базе Salesforce
    //@future (callout = true)
    public static void newGetRate(String currentDate){
        //Получение значений метаданных
        API__mdt apiString = ExchangeRateCalloutService.getApiConfiguration();
        String settingMethod = apiString.Setting_method__c;
        String dateRates = currentDate;
        String baseRate = apiString.Base_Currency__c;
        //Получение строки функции с вводом даты и базовой валюты
        String Url = ExchangeRateCalloutService.getStringWithParameters(dateRates, baseRate);

        //Http запрос и получение ответа
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Url);
        request.setMethod(settingMethod);
        HttpResponse response = Http.send(request);

        //Запись объекта типа Log__c
        ExchangeRateCalloutService.insertInformation(Url, response, dateRates, baseRate);
    }

    // Полученеие эксземпляра из объекта из базы или с помощью обращения к API и создать новые записи
    @AuraEnabled
    public static Exchange_Rate__c getRate(String currentDate){
        //Получение строки полей типа CURRENCY
        String fieldsTypeCurrency = getStringFieldsTypeCurrency();
        Exchange_Rate__c exchangeRate = new Exchange_Rate__c();
        //Проверяем есть ли объкт в нашей базе данных на выбранную дату
        Integer num = Database.countquery('SELECT count() ' + 'FROM Exchange_Rate__c' + ' WHERE Name like \'%'+ currentDate + '%\' ');
        if(num == 0){
            //Функции вызова Http запроса
            newGetRate(currentDate);
            //После записи объекта получаем его уже из нашей базы данных
            exchangeRate = Database.query('SELECT Id, Name, Base_Currency__c' + fieldsTypeCurrency + ' FROM Exchange_Rate__c' + ' WHERE Name like \'%'+ currentDate + '%\' '+' LIMIT 1');
            return exchangeRate;

        } else {
            //Получаем запись объекта сразу из нашей базы данных
            exchangeRate = Database.query('SELECT Id, Name, Base_Currency__c' + fieldsTypeCurrency + ' FROM Exchange_Rate__c' + ' WHERE Name like \'%'+ currentDate + '%\' '+' LIMIT 1');
            return exchangeRate;
        }
    }

    // Заполнение списка данных для обертки класса Wrapper на каждую валюту
    @AuraEnabled
    public static List<WrapperRates.WrapperExchangeRates> objectToWrapper (String currentDate) {
        List<WrapperRates.WrapperExchangeRates> newListWrapperExchangeRates = new List<WrapperRates.WrapperExchangeRates>();
        //Получаем запись из базы данных с помощью функции
        Exchange_Rate__c rate = getRate(currentDate);
        //Серелизуем объект в JSON формат
        String serialezeRate = JSON.serialize(rate);
        //Десерилизуем JSON строку в Map
        Map<String, Object> newMap = (Map<String, Object>) JSON.deserializeUntyped(serialezeRate);
        //Получаем поля типа CURRENCY
        Map<String, DescribeFieldREsult> fieldsCurrency = getMapFieldTypeCurrency();
        //Проходим циклом и создаем List значений Базовой валюты, Целевой валюты, Цены на нее
        //Размер List равен количеству полей типа CURRENCY
        for(String key : fieldsCurrency.keySet()){
            newListWrapperExchangeRates.add(new WrapperRates.WrapperExchangeRates(String.valueOf(newMap.get('Base_Currency__c')), fieldsCurrency.get(key).label, String.valueOf(newMap.get(key))));
        }   
        return newListWrapperExchangeRates;
    }

    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    // Получение значений Picklist для запроса по валютам
    @AuraEnabled
    public static List<String> getNamePicklistValue() {
        List<String> listNamePicklistValue = new List<String>();
        //Получение описания объекта Exchange Rate, поля Base Currency
        Schema.DescribeFieldResult fieldResult = Exchange_Rate__c.Base_Currency__c.getDescribe();
        //Получение полного описания всех значений PickList 
        List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
        //Цикл для получения листа значений имени PickList
        for(Schema.PicklistEntry  pickListEntry : pickListEntries){
            String currencyOption = pickListEntry.getValue();
            listNamePicklistValue.add(currencyOption);
            System.debug(currencyOption);
        } 
        return listNamePicklistValue;
    }

}