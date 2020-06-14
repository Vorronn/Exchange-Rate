public with sharing class ExchangeRateCalloutService {

    public static String baseRate {set; get;}
    public static String dateRates {set; get;}

    /*++++++++++++++++++++++++++++++++++++getRates()+++++++++++++++++++++++++++++++++++++++++++++++*/
    //Получение курсов валют с заданными параметрами для передачи в ExchangeRateSchedule
    public static void getRates(){
        //Получение метаданных
        API__mdt apiString = getApiConfiguration();
        String settingMethod = apiString.Setting_method__c;
        //Установка текущего дня
        dateRates = String.valueOf(date.today());
        baseRate = apiString.Base_Currency__c;
        //Получение строки Url
        String Url = getStringWithParameters(dateRates, baseRate);
        //Выполнение Http запроса
        getExchangeRate(Url, settingMethod, dateRates, baseRate);
    } 

    /*++++++++++++++++++++++++++++++++++++getRates()+++++++++++++++++++++++++++++++++++++++++++++++*/

    /*++++++++++++++++++++++++++++++++++++getExchangeRate++++++++++++++++++++++++++++++++++++++++++*/
    //Функция Http запроса для добавления новых Log записей
    @future (callout = true)
    public static void getExchangeRate(String Url, String method, String setDate, String setBase) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Url);
        request.setMethod(method);
        HttpResponse response = Http.send(request);
        //Функция добаления записей  Log__c
        insertInformation(Url, response, setDate, setBase);
    }
    /*++++++++++++++++++++++++++++++++++++getExchangeRate++++++++++++++++++++++++++++++++++++++++++*/

    /*++++++++++++++++++++++++++++++++++++insertInformation++++++++++++++++++++++++++++++++++++++++*/
    //Функция добавления новых Log записей
    public static void insertInformation(String Url, HttpResponse setparser, String setDate, String setBase){
        String nameLogs = setDate + '&base=' + setBase;
        Log__c newLog = new Log__c();
        if(setparser.getStatusCode() == 200){
            newLog.Name = nameLogs;
            newLog.Status_Code__c = String.valueOf(setparser.getStatusCode());
            newLog.Response_Body__c = setparser.getBody();
        } else {
            newLog.Name = nameLogs;
            newLog.Status_Code__c = String.valueOf(setparser.getStatusCode());
            newLog.Response_Body__c = Url;
        }
        insert newLog;
    }
    /*++++++++++++++++++++++++++++++++++++insertInformation++++++++++++++++++++++++++++++++++++++++*/

    /*++++++++++++++++++++++++++++++++++++updateExchangeRate+++++++++++++++++++++++++++++++++++++++*/
    //Функция Http запроса для обновления существующих записей Log с getStatusCode() != 200
    @future (callout = true)
    public static void updateExchangeRate(String Url, String method, String nameLog) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Url);
        request.setMethod(method);
        HttpResponse response = Http.send(request);
        updateInformation(Url, response, nameLog);
    }
    /*++++++++++++++++++++++++++++++++++++updateExchangeRate+++++++++++++++++++++++++++++++++++++++*/

    /*++++++++++++++++++++++++++++++++++++updateInformation++++++++++++++++++++++++++++++++++++++++*/
    //Функция обновления существующих записей Log с getStatusCode() != 200
    public static void updateInformation(String Url, HttpResponse setparser, String nameLog){
        Log__c updateLog = [SELECT Name, Status_Code__c, Response_Body__c FROM Log__c Where Name =: nameLog];
        if(setparser.getStatusCode() == 200 ){
            updateLog.Status_Code__c = String.valueOf(setparser.getStatusCode());
            updateLog.Response_Body__c = setparser.getBody();
            update updateLog ;
        } else {
            return;
        }
    }
    /*++++++++++++++++++++++++++++++++++++updateInformation++++++++++++++++++++++++++++++++++++++++*/

    /*++++++++++++++++++++++++++++++++++++getStringWithParameters()++++++++++++++++++++++++++++++++*/
    //Получение строки из параметров baseRate и dateRate
    public static String getStringWithParameters(String setDate, String setBase){
        //Создание пользовательского обеъекта Metadata с получением значения из getApiConfiguration()
        API__mdt apiString = getApiConfiguration();
        //Получение строки начального значения URL для запроса
        String settingUrl = apiString.API_URL__c;
        //Добваление и возвращение строки с дополнительными изменяемыми параметрами
        settingUrl += setDate + '?base=' + setBase;
        return settingUrl;
    }
    /*++++++++++++++++++++++++++++++++++++getStringWithParameters()++++++++++++++++++++++++++++++++*/

    /*++++++++++++++++++++++++++++++++++++getApiConfiguration()++++++++++++++++++++++++++++++++++++*/
    //Получение значений из CustomMetadata
    public static API__mdt getApiConfiguration(){
        List <API__mdt> apiConfiguration = [SELECT Setting_Method__c, API_URL__c, Base_Currency__c FROM API__mdt];
        return apiConfiguration[0]; 
    }
    /*++++++++++++++++++++++++++++++++++++getApiConfiguration()++++++++++++++++++++++++++++++++++++*/

    //Вспомогательные функции для отладки

    /*++++++++++++++++++++++++++++++++++++deleteObjects()++++++++++++++++++++++++++++++++++++++++++*/
    //Удаление всех объектов
    /*
    public static void deleteObjects(){
        List<Exchange_Rate__c> oldListExchangeRate = new List<Exchange_Rate__c>();
        List<Log__c> oldListLog = new List<Log__c>();
        oldListExchangeRate = [SELECT Id FROM Exchange_Rate__c];
        oldListLog = [SELECT Id FROM Log__c];
        delete oldListExchangeRate;
        delete oldListLog;
        System.debug('Delete all objects');
    }
    */
    /*++++++++++++++++++++++++++++++++++++deleteObjects()++++++++++++++++++++++++++++++++++++++++++*/

    /*++++++++++++++++++++++++++++++++++++setRuntime()+++++++++++++++++++++++++++++++++++++++++++++*/
    //Установки даты выполнения работы
    /*
    public static void setRuntime(String dateAndTime){
        ExchangeRateSchedule newSchedule = new ExchangeRateSchedule();
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year '0 07 0 1 6 ? 2020'
        String sch = dateAndTime;
        String jobID = System.schedule('GET Exchange Rate'+dateAndTime, sch, newSchedule);
    }
    */
    /*++++++++++++++++++++++++++++++++++++setRuntime()+++++++++++++++++++++++++++++++++++++++++++++*/
}