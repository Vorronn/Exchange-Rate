public with sharing class ExchangeRateController {
    //Функция для получения значений Picklist
    @AuraEnabled
    public static WrapperRates.WrapperRatesTable getPicklistValue(){
        WrapperRates.WrapperRatesTable newWrapperRates = new WrapperRates.WrapperRatesTable();
        newWrapperRates.wrapPickList = getNamePicklistValue();
        return newWrapperRates;
    }

    //Функция возращающая значения для класса обертки и передачи его в Lightning component
    @AuraEnabled
    public static WrapperRates.WrapperRatesTable getWrapperTable(String currentDate, String baseCurrency){
        WrapperRates.WrapperRatesTable newWrapperRates = new WrapperRates.WrapperRatesTable();
        newWrapperRates.exchangeRate = objectToWrapper(currentDate, baseCurrency);
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
            exchangeRate = Database.query('SELECT Id, Name, Base_Currency__c, Date__c' + fieldsTypeCurrency + ' FROM Exchange_Rate__c' + ' WHERE Name like \'%'+ currentDate + '%\' '+' LIMIT 1');
            return exchangeRate;

        } else {
            //Получаем запись объекта сразу из нашей базы данных
            exchangeRate = Database.query('SELECT Id, Name, Base_Currency__c, Date__c' + fieldsTypeCurrency + ' FROM Exchange_Rate__c' + ' WHERE Name like \'%'+ currentDate + '%\' '+' LIMIT 1');
            return exchangeRate;
        }
    }

    // Заполнение списка данных для обертки класса Wrapper на каждую валюту
    @AuraEnabled
    public static List<WrapperRates.WrapperExchangeRates> objectToWrapper (String currentDate, String baseCurrency) {
        List<WrapperRates.WrapperExchangeRates> newListWrapperExchangeRates = new List<WrapperRates.WrapperExchangeRates>();
        //Получаем запись из базы данных с помощью функции
        Exchange_Rate__c rate = getRate(currentDate);
        //Серелизуем объект в JSON формат
        String serialezeRate = JSON.serialize(rate);
        //Десерилизуем JSON строку в Map
        Map<String, Object> newMap = (Map<String, Object>) JSON.deserializeUntyped(serialezeRate);
        //Получаем поля типа CURRENCY
        Map<String, DescribeFieldREsult> fieldsCurrency = getMapFieldTypeCurrency();
        //вычисляем значение базовой валюты
        Decimal baseCurrencyRate;
        for(String key : fieldsCurrency.keySet()){
            if(fieldsCurrency.get(key).label == baseCurrency){
                baseCurrencyRate = Decimal.valueOf(String.valueOf(newMap.get(key)));
            }
        }
        //Проходим циклом и создаем List значений Базовой валюты, Целевой валюты, Цены на нее
        //Размер List равен количеству полей типа CURRENCY
        for(String key : fieldsCurrency.keySet()){
            if(fieldsCurrency.get(key).label != baseCurrency){
                newListWrapperExchangeRates.add(new WrapperRates.WrapperExchangeRates(fieldsCurrency.get(key).label, Decimal.valueOf(String.valueOf(newMap.get(key)))/baseCurrencyRate));
            } else {
                continue;
            }
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
    
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    //Функция возращающая значения для класса обертки и передачи его в Lightning component при запросе периода
    @AuraEnabled
    public static WrapperRates.WrapperRatesTable getWrapperTablePeriod(String baseCurrency, String startDate, String endDate){
        WrapperRates.WrapperRatesTable newWrapperRates = new WrapperRates.WrapperRatesTable();
        newWrapperRates.nameTableColumns = getListNameTableColumns(baseCurrency);
        newWrapperRates.listRatesPeriod = objectToWrapperPeriod(baseCurrency, startDate, endDate);   
        return newWrapperRates;
    }
    
	//Функция получения запроса на выбранный период
    //@AuraEnabled
    public static String getExchangeRatePeriod(String baseCurrency, String startDate, String endDate){
        //Получение метаданных
		API__mdt apiString = ExchangeRateCalloutService.getApiConfiguration();
        String settingMethod = apiString.Setting_method__c;
        String urlApi = apiString.API_URL__c;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(urlApi + 'history?start_at=' + startDate + '&end_at=' + endDate + '&base=' + baseCurrency);
        request.setMethod(settingMethod);
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        return response.getBody();
    }

    // Функция для получения колонок для таблицы при выборе периода курсов валют
    @AuraEnabled
    public static List<WrapperRates.NameTableColumns> getListNameTableColumns(String baseCurrency){
        List<WrapperRates.NameTableColumns> listNameTableColumns = new List<WrapperRates.NameTableColumns>();
        //Заполение аттрибута для таблицы, что бы данные отображались в левой стороне
        WrapperRates.CellAttribut cellAttributes= new WrapperRates.CellAttribut('left');
        //Получение полей типа currency
        Map<String, DescribeFieldREsult> fieldsCurrency = getMapFieldTypeCurrency();
        //Заполнение колонок для отображения валют за исключением базовой валюты
        for(String key : fieldsCurrency.keySet()){
            if(fieldsCurrency.get(key).label != baseCurrency){
                listNameTableColumns.add(new WrapperRates.NameTableColumns(fieldsCurrency.get(key).label, fieldsCurrency.get(key).Name, 'number', cellAttributes));
            } else {
                continue;
            }
        }
        //Заполнение колонки для отображения даты
        listNameTableColumns.add(new WrapperRates.NameTableColumns('date', 'Date__c', 'date', cellAttributes));
        return listNameTableColumns;
    }

    //Функция для создания данных для заполнения таблицы на выбранный период
    @AuraEnabled
    public static List<SObject> objectToWrapperPeriod (String baseCurrency, String startDate, String endDate) {
        List<SObject> newRate = new List<Exchange_Rate__c>();
        //Получаем запись из запроса
        String ratePeriod = getExchangeRatePeriod(baseCurrency, startDate, endDate);
        //Применяем даты для вычисления количество дней за которые надо получить курсы
        DateTime startDay = Date.valueOf(startDate);
        DateTime endDay = Date.valueOf(endDate);
        //Переводим в миллисекунды
        Long milliseconds = endDay.getTime() - startDay.getTime();
        //Вычисляем разницу в днях
        Integer numDay = (Integer)(milliseconds / (24 * 60 * 60 * 1000));
        //Создаем переменную для получения даты и для обработки JSON
		String currentDate = '';
        //Проходим циклом по каждому дню, исключая выходные дни
        for(Integer i = 0; i < numDay+1; i++){
            currentDate = String.valueOf(Date.valueOf((startDay.addDays(i))));
			//Получаем Map response
            Map<String, Object> newMap = (Map<String, Object>) JSON.deserializeUntyped(ratePeriod);
            //Получаем Map rates
            Map<String, Object> rates = (Map<String,Object>) newMap.get('rates');
            //Проверяем есть ли дата JSON если нет то пропускаем этот день
            if(String.valueOf(rates.get(currentDate)) != null){
                //Получаем Map на каждую запрашиваемую дату
                Map<String, Object> dateDay = (Map<String, Object>) rates.get(currentDate);            
               // newListWrapperExchangeRates.add(new WrapperRates.WrapperRatesPeriod(dateDay, currentDate));
                //Получаем список валют имеющихся в базе
				Map<String, DescribeFieldREsult> fieldsCurrency = getMapFieldTypeCurrency();
                //Проходим циклом по каждой валюте и записываем в Wrapper Class
                SObject oneRate = new Exchange_Rate__c();
				for(String key : fieldsCurrency.keySet()){
                    if(fieldsCurrency.get(key).label != baseCurrency){
                        oneRate.put(fieldsCurrency.get(key).Name, Decimal.valueOf(String.valueOf(dateDay.get(fieldsCurrency.get(key).label))));
                    } else {
                        continue;
                    }
                }
                //записываем данные даты в Wrapper Class
                oneRate.put('Date__c', Date.valueOf(currentDate).addDays(1));
                newRate.add(oneRate);
            } else {
                continue;
            }
        }
        return newRate;
    } 
}