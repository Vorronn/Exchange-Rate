global class ExchangeRateSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        //Вызов функции для получения курсов валют каждый день в 12 PM
        ExchangeRateCalloutService.getRates();

        //Проверяем есть ли записи с Status_Code__c != 200 и если такие есть то обновляем запись 
        List<Log__c> updateLog = [SELECT ID, Name, Status_Code__c, response_Body__c FROM Log__c WHERE Status_Code__c <> '200'];
        if(updateLog.size() != 0){ 
            for (Log__c lg: updateLog){
                String Url = lg.response_Body__c;
                String nameLog = lg.Name;
                API__mdt apiString = ExchangeRateCalloutService.getApiConfiguration();
                String settingMethod = apiString.Setting_method__c;
                ExchangeRateCalloutService.updateExchangeRate(Url, settingMethod, nameLog);
            }
        }
    }
}