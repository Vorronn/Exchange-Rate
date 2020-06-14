public class WrapperRates {
    //Класс обертка для lightning component
    public class WrapperRatesTable {
        @AuraEnabled
        public List<WrapperExchangeRates> exchangeRate {get; set;}
        @AuraEnabled
        public List<String> wrapPickList {get; set;}
    }

    //Класс обертка для получения курсов валют относительно базовой валюты для одного объекта
    public class WrapperExchangeRates {
        @AuraEnabled
        public String baseCurrency {get; set;}
        @AuraEnabled
        public String targetCurrency {get; set;}
        @AuraEnabled
        public String rates {get; set;}

        //Конструктор для данного класса
        public WrapperExchangeRates(String baseCurrency, String targetCurrency, String rates){
            this.baseCurrency = baseCurrency;
            this.targetCurrency = targetCurrency;
            this.rates = rates;
        }
    }
    
}
