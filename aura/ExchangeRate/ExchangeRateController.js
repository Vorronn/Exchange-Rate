({
    doInit : function (cmp, event, helper) {
        //Установка полей таблицы
        cmp.set('v.columns', [
            {label: 'Currency', fieldName: 'targetCurrency', type: 'text'},
            {label: 'Rates', fieldName: 'rates', type: 'number', cellAttributes: { alignment: 'left' }},
        ]);
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        //Получение последней возможной даты и установка минимального и максимального значения даты
        //Получение текущей даты в формате yyyy-mm-dd
        let currentDate = new Date();
        let dd = String(currentDate.getDate() - 1).padStart(2, '0');
        let mm = String(currentDate.getMonth() + 1).padStart(2, '0');
        let yyyy = currentDate.getFullYear();
        currentDate = yyyy + '-' + mm + '-' + dd;
        //Установка текущей даты
        cmp.set('v.currentDate', currentDate);
        //Установка максимальной даты
        cmp.set('v.maxDate', cmp.get('v.currentDate'));
        //Установка минимальной даты ограниченной возможностями API
        cmp.set('v.minDate', '1999-01-04');
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        //Получаем значение пиклиста
        let action = cmp.get("c.getPicklistValue");
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                let result = response.getReturnValue();
                cmp.set('v.currencies', result.wrapPickList);   

                //Вызов для получения курсов валют на последнюю возможную дату
                helper.getRates(cmp, event, helper);
            }
            else {
                cmp.set("v.message",'Error:'+' There is no data in the database and the API service is not available! try to get the data a little later!');
            }
        });
        $A.enqueueAction(action);
    },

    //При нажатии кнопки вызываем helper и получаем курсы валют на интересующую нас дату и базовую валюту
    getExchangeRate : function(cmp, event, helper) {
        helper.getRates(cmp, event, helper);

    },
        
    //При нажатии кнопки вызываем helper и получаем изменение курсов валют на интересующий нас период и базовую валюту
    getPeriod : function(cmp, event, helper){
        helper.getRatesMinMax(cmp, event, helper);

    }
});