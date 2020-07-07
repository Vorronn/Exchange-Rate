@isTest
public class ExchangeRateScheduleTest {

    static testmethod void tester(){
        ExchangeRateSchedule newExchangeRateSchedule = new ExchangeRateSchedule();
        String sch = '20 30 9 10 3 ?';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExchangeRateControllerMock());
        String jobID = System.schedule('test system', sch, newExchangeRateSchedule);
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM Log__c]);
    }

    
    static testmethod void tester3(){
        ExchangeRateSchedule newExchangeRateSchedule = new ExchangeRateSchedule();
        String sch = '20 30 9 10 3 ?';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExchangeRateCalloutServiceMock());
        String jobID = System.schedule('test system', sch, newExchangeRateSchedule);
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM Log__c]);
    }

    @TestSetup
    public static void SetupTest() {
        Log__c newLog = new Log__c();
        newLog.Name = '2020-03-04&base=GBP';
        newLog.Status_Code__c = '400';
        newLog.Response_Body__c = 'new ExchangeRateControllerMock()';
        insert newLog;

    }

    
    static testmethod void tester2(){
        ExchangeRateSchedule newExchangeRateSchedule = new ExchangeRateSchedule();
        String sch = '20 30 9 10 3 ?';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExchangeRateControllerMock());
        String jobID = System.schedule('test system', sch, newExchangeRateSchedule);
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM Log__c]);
    }


    
    
}