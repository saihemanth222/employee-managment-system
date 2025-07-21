@isTest
public class MockNewShipToAPI implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success","message":"Mock response"}');
        res.setStatusCode(200);
        return res;
    }
}