@isTest
global class ExchangeRateCalloutServiceMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"error":"There is no data for dates older then 1999-01-04."}');
        response.setStatusCode(400);
        return response;
    }
}