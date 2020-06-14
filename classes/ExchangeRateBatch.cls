global class ExchangeRateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    //String query;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT ID, Name, Status_Code__c, response_Body__c FROM Log__c WHERE Status_Code__c <> '200' LIMIT 200]);
    }
    global void execute(Database.BatchableContext bc, List<Log__c> updateLog) {
        for (Log__c lg: updateLog){
            String Url = lg.response_Body__c;
            String nameLog = lg.Name;
            API__mdt apiString = ExchangeRateCalloutService.getApiConfiguration();
            String settingMethod = apiString.Setting_method__c;
            ExchangeRateCalloutService.updateExchangeRate(Url, settingMethod, nameLog);
        }
    }
    global void finish(Database.BatchableContext bc) {
        
    }
}