({
    //Вспомогательная функция для получения курсов валют на 1 день и возможностью менять базовую валюту
    getRates : function (cmp, event, helper) {

        //Получение текущей даты с компонента
        let currentDate = cmp.get("v.currentDate");
        //Получение текущего значения Select базовой валюты
        let baseCurrency = cmp.find("mySelect").get("v.value"); 

        if(currentDate == ''){
            cmp.set("v.message",'Error:'+' You did not choose a date! Enter DATE!');
        } else {
            //Вешаем событие для обращения в controller
            let action = cmp.get("c.getWrapperTable");
            //Устанавливаем значение передоваемое в controller
            action.setParams({"currentDate" : currentDate, "baseCurrency" : baseCurrency});
            action.setCallback(this, function(response){
                let state = response.getState();
                if(state === 'SUCCESS'){
                    //Установка полей таблицы
                    cmp.set('v.columns', [
                        {label: 'Currency', fieldName: 'targetCurrency', type: 'text'},
                        {label: 'Rates', fieldName: 'rates', type: 'number', cellAttributes: { alignment: 'left' }},
                    ]);

                    let result = response.getReturnValue();
                    //Записываем значения для отображения их в dataTable
                    cmp.set('v.exchangeRate', result.exchangeRate);   
            
                    //Выводит сообщение о выбранной дате
                    cmp.set('v.displayDate', 'Exchange rates for this date: ' + cmp.get('v.currentDate'));

                    //Обнуление даты выбранного переуда
                    cmp.set('v.startDate', '');
                    cmp.set('v.endDate', '');
                    //Обнуление сообщения
                    cmp.set("v.message",'');
                
                } else {
                    cmp.set("v.message",'Error:'+' There is no data in the database and the API service is not available! try to get the data a little later!');
                    //alert('There is no data in the database and the API service is not available! try to get the data a little later!');
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getRatesMinMax : function (cmp, event, helper){
        //Получение минимальной и максимальной даты 
        let startDate = cmp.get('v.startDate');
        let endDate = cmp.get('v.endDate');
		//Получение текущего значения Select базовой валюты
		let baseCurrency = cmp.find("mySelect").get("v.value");
		//Проверяем установлены ли значения даты и правильно ли они выбраны
        if(startDate == '' || endDate == ''){
			cmp.set("v.message",'Error:'+' You did not choose a period! Enter the DATE MIN VALUE and the DATE MAX VALUE!');
            //alert('You did not choose a period! Enter the DATE MIN VALUE and the DATE MAX VALUE!');
        } else if (startDate >= endDate){
			cmp.set("v.message",'Error:'+' You entered an invalid date! DATE MIN VALUE must be less than DATE MAX VALUE');
            //alert('You entered an invalid date! DATE MIN VALUE must be less than DATE MAX VALUE');
        } else {
            //Вешаем событие для обращения в controller
            let action2 = cmp.get("c.getWrapperTablePeriod");
            //Устанавливаем значения передоваемое в controller
            action2.setParams({"baseCurrency" : baseCurrency , "startDate" : startDate, "endDate" : endDate});
            action2.setCallback(this, function(response){
                let state = response.getState();
                if(state === 'SUCCESS'){
                    let result = response.getReturnValue();
                    cmp.set('v.columns', result.nameTableColumns);
                    cmp.set('v.exchangeRate', result.listRatesPeriod);   
					
                    //Выводит сообщение о выбранной дате
                    cmp.set('v.displayDate', 'Exchange rates from ' + cmp.get('v.startDate') + ' to ' + cmp.get('v.endDate'));
                    
                    //Обнуление даты текущего значения
                    cmp.set('v.currentDate', '');
                    
					//Обнуление сообщения
                    cmp.set("v.message",'');
                    
                } else {
					cmp.set("v.message",'Error:'+' There is no data in the database and the API service is not available! try to get the data a little later!');
                    //alert('There is no data in the database and the API service is not available! try to get the data a little later!');
                }
            });
            $A.enqueueAction(action2);
        }

    }

})