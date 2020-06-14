@isTest
global class ExchangeRateControllerMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"rates":{"CAD":1.6951552657,"HKD":9.7216925907,"ISK":165.5795283492,"PHP":62.5623013882,"DKK":8.3132073368,"HUF":384.5682109606,"CZK":29.6850086414,"GBP":1.0,"RON":5.3936555723,"SEK":11.6153202877,"IDR":17680.6377878129,"INR":94.7003400792,"BRL":6.3543513408,"RUB":86.7627808441,"HRK":8.4434409322,"JPY":136.5668729442,"THB":39.6264704243,"CHF":1.2026537325,"EUR":1.1150136589,"MYR":5.360651168,"BGN":2.1807437141,"TRY":8.4593856275,"CNY":8.9274683615,"NOK":11.8244968501,"NZD":1.9523889168,"ZAR":21.1918381,"USD":1.2543903663,"MXN":27.291185817,"SGD":1.7570385237,"AUD":1.8147962313,"ILS":4.3561353627,"KRW":1526.1526453699,"PLN":4.9475386073},"base":"GBP","date":"2020-06-04"}}');
        response.setStatusCode(200);
        return response;
    }

}
