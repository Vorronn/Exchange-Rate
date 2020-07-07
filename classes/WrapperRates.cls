public class WrapperRates {
    //Класс обертка для lightning component
    public class WrapperRatesTable {
        @AuraEnabled
        public List<WrapperExchangeRates> exchangeRate {get; set;}
        @AuraEnabled
        public List<String> wrapPickList {get; set;}
        @AuraEnabled
        public List<NameTableColumns> nameTableColumns {get; set;}
        @AuraEnabled
        public List<SObject> listRatesPeriod {get; set;}
    }

    //Класс обертка для получения курсов для заданного периода
    public class NameTableColumns {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String fieldName {get; set;}
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public CellAttribut cellAttributes {get; set;}

        //Конструктор для данного класса
        public NameTableColumns(String label, String fieldName, String type, CellAttribut cellAttributes){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.cellAttributes = cellAttributes;
        }
    }

    //класс для выравнивания числовых значений по левому краю
    public class CellAttribut {
        @AuraEnabled
        public String alignment {get; set;}

        public CellAttribut(String alignment){
            this.alignment = alignment;
        }
    }

    //Класс обертка для получения курсов валют относительно базовой валюты для одного объекта
    public class WrapperExchangeRates {
        @AuraEnabled
        public String targetCurrency {get; set;}
        @AuraEnabled
        public Decimal rates {get; set;}

        //Конструктор для данного класса
        public WrapperExchangeRates(String targetCurrency, Decimal rates){
            this.targetCurrency = targetCurrency;
            this.rates = rates;
        }
    }
    
}