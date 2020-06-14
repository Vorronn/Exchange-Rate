({
    //Вспомогательная функция для получения курсов валют на 1 день и возможностью менять базовую валюту
    getRates : function (cmp, event, helper) {
        //Получение текущей даты с компонента
        let currentDate = cmp.get("v.currentDate");
        if(currentDate == ''){
            alert('You did not choose a date! Enter DATE!');
        } else {
            //Вешаем событие для обращения в controller
            let action = cmp.get("c.getWrapperTable");
            //Устанавливаем значение передоваемое в controller
            action.setParams({"currentDate" : currentDate});
            action.setCallback(this, function(response){
                let state = response.getState();
                if(state === 'SUCCESS'){
                    let result = response.getReturnValue();
                    //Записываем значения для отображения их в dataTable
                    cmp.set('v.exchangeRate', result.exchangeRate);   
                    //Записываем значения Select базовой валюты
                    cmp.set('v.currencies', result.wrapPickList);                 
                    //Выводит сообщение о выбранной дате
                    cmp.set('v.displayDate', 'exchange rates for this date: ' + cmp.get('v.currentDate'));
                    //Получение текущего значения Select базовой валюты
                    let baseCurrency = cmp.find("mySelect").get("v.value");
                    //Получение значений курсов валют dataTable
                    let exchangeRates= cmp.get("v.exchangeRate");
                    let ratess;
                    //С помощью цикла вычисляем нужную нам стоимость валюты
                    for(let i=0; i < exchangeRates.length; i++){
                        if(exchangeRates[i].targetCurrency == baseCurrency){
                            ratess = exchangeRates[i].rates;
                        }
                    }
                    //Переписываем все значения курсов валют с учетом базовой валюты и обновляем компонент dataTable
                    for(let i=0; i < exchangeRates.length; i++){
                        exchangeRates[i].baseCurrency = baseCurrency;
                        exchangeRates[i].rates = String((exchangeRates[i].rates/ratess).toFixed(4));
                    }
                    cmp.set('v.exchangeRate', exchangeRates);

                    //Обнуление даты выбранного переуда
                    cmp.set('v.startDate', '');
                    cmp.set('v.endDate', '');
                
                } else {
                    alert('There is no data in the database and the API service is not available! try to get the data a little later!');
                }
            });
            $A.enqueueAction(action);
        }
    },

    //Функция для отображения изменения курсов валют в зависимости от вабранного переода
    getRatesMinMax : function (cmp, event, helper){
        //Получение минимальной и максимальной даты 
        let startDate = cmp.get('v.startDate');
        let endDate = cmp.get('v.endDate');
        let startRate;
        let endRate;
        //Проверяем установлены ли значения даты и правильно ли они выбраны
        if(startDate == '' || endDate == ''){
            alert('You did not choose a period! Enter the DATE MIN VALUE and the DATE MAX VALUE!');
        } else if (startDate >= endDate){
            alert('You entered an invalid date! DATE MIN VALUE must be less than DATE MAX VALUE');
        } else {
            //Вешаем событие для обращения в controller
            let action2 = cmp.get("c.getWrapperTable");
            //Устанавливаем значение передоваемое в controller
            action2.setParams({"currentDate" : startDate});
            action2.setCallback(this, function(response){
                let state = response.getState();
                if(state === 'SUCCESS'){
                    let result = response.getReturnValue();
                    startRate = result.exchangeRate;   
                    //Получение текущего значения Select базовой валюты
                    let baseCurrency = cmp.find("mySelect").get("v.value");
                    let ratesStart;
                    //С помощью цикла вычисляем нужную нам стоимость валюты
                    for(let i=0; i < startRate.length; i++){
                        if(startRate[i].targetCurrency == baseCurrency ){
                            ratesStart = startRate[i].rates;
                        }
                    }
                    //Переписываем все значения курсов валют с учетом базовой валюты 
                    for(let i=0; i < startRate.length; i++){
                        startRate[i].baseCurrency = baseCurrency;
                        startRate[i].rates = String((startRate[i].rates/ratesStart).toFixed(4));
                    }
                    //Записываем значения курсов валют во временные данные
                    cmp.set('v.startRate', startRate);
                } else {
                    alert('There is no data in the database and the API service is not available! try to get the data a little later!');
                }
            });
            $A.enqueueAction(action2);

            //Вешаем событие для обращения в controller
            let action3 = cmp.get("c.getWrapperTable");
            //Устанавливаем значение передоваемое в controller
            action3.setParams({"currentDate" : endDate});
            action3.setCallback(this, function(response){
                let state = response.getState();
                if(state === 'SUCCESS'){
                    let result = response.getReturnValue();
                    endRate = result.exchangeRate;                 
                    //Получение текущего значения Select базовой валюты
                    let baseCurrency = cmp.find("mySelect").get("v.value");
                    let ratesEnd;
                    //С помощью цикла вычисляем нужную нам стоимость валюты
                    for(let i=0; i < endRate.length; i++){
                        if(endRate[i].targetCurrency == baseCurrency ){
                            ratesEnd = endRate[i].rates;
                        }
                    }
                    //Переписываем все значения курсов валют с учетом базовой валюты 
                    for(let i=0; i < startRate.length; i++){
                        endRate[i].baseCurrency = baseCurrency;
                        endRate[i].rates = String((endRate[i].rates/ratesEnd).toFixed(4));
                    }
                    //Записываем значения курсов валют во временные данные
                    cmp.set('v.endRate', endRate);

                    //Получение данных текущего курса и данные из временно записанных
                    let exchangeRates= cmp.get("v.exchangeRate");
                    let exchangeRatesStart = cmp.get("v.startRate");
                    let exchangeRatesEnd = cmp.get("v.endRate");
                    //C помщью цикла записываем изменения значений курсов валют минимальной и максимальной даты
                    for(let i=0; i < exchangeRates.length; i++){
                        exchangeRates[i].baseCurrency = baseCurrency;
                        exchangeRates[i].rates = exchangeRatesStart[i].rates + '  --->  ' + exchangeRatesEnd[i].rates;
                    }
                    //Записываем полученные изменения в dataTable для обновления компонента
                    cmp.set('v.exchangeRate', exchangeRates);
                    //Выводит сообщение о выбранной дате
                    cmp.set('v.displayDate', 'сhange in exchange rates from ' + cmp.get('v.startDate') + ' to ' + cmp.get('v.endDate'));
                    //Обнуление даты текущего значения
                    cmp.set('v.currentDate', '');
                } else {
                    alert('There is no data in the database and the API service is not available! try to get the data a little later!');
                }
            });
            $A.enqueueAction(action3);
        }

    }
})