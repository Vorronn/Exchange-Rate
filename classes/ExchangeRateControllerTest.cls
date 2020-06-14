@isTest
public class ExchangeRateControllerTest {
    
    @testSetup
    public static void setupDate() {
        List<Exchange_Rate__c> fullList = new List<Exchange_Rate__c>();
        fullList.add(new Exchange_Rate__c(Base_Currency__c = 'GBP', USD__c = 1.2455, EUR__c = 1.1234, GBP__c = 1.0000, CAD__c = 1.7432, Date__c = date.valueOf('2020-03-04'), Name = '2020-03-04&base=GBP'));
        fullList.add(new Exchange_Rate__c(Base_Currency__c = 'GBP', USD__c = 1.2455, EUR__c = 1.1234, GBP__c = 1.0000, CAD__c = 1.7432, Date__c = date.valueOf('2020-04-04'), Name = '2020-04-04&base=GBP'));
        fullList.add(new Exchange_Rate__c(Base_Currency__c = 'GBP', USD__c = 1.2455, EUR__c = 1.1234, GBP__c = 1.0000, CAD__c = 1.7432, Date__c = date.valueOf('2020-05-04'), Name = '2020-05-04&base=GBP'));
        insert fullList;

    }

    @isTest
    public static void test1(){
        Test.startTest();
        WrapperRates.WrapperRatesTable tableWrapper = ExchangeRateController.getWrapperTable('2020-04-04');
        System.assert(tableWrapper!=null);
        Test.stopTest();
    }

    @isTest
    public static void test2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExchangeRateControllerMock());
        WrapperRates.WrapperRatesTable tableWrapper = ExchangeRateController.getWrapperTable('2020-06-04');
        System.assert(tableWrapper!=null);
        Test.stopTest();
    }
}
