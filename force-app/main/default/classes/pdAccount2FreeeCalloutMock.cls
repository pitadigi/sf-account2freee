global class pdAccount2FreeeCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        String endPoint = req.getEndpoint();

        HttpResponse res = new HttpResponse();

        if(endPoint == 'callout:Freee/companies') {
            res.setStatusCode(200);
            String body = '{"companies": [{"id": 12345678}]}';
            res.setBody(body);
        }
        else if(endPoint.indexOf('callout:Freee/partners') != (-1)) {
            String method = req.getMethod();
            if(method == 'GET') {
                res.setStatusCode(200);
                String body = '{"partners": []}';
                res.setBody(body);
            }
            else {
                res.setStatusCode(201);
                
            }
        }

        return res;
    }
}
