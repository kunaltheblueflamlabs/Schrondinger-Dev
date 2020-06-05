/**
 * Created by rohit on 10/1/18.
 */

public with sharing class LicenseGenerationService {

    public LicenseGenerationService() {

    }

    public LicenseGenerationResponse getResponse(licenseGenerationRequest licenseGenerationRequest) {

        HttpRequest request = createHttpRequest(licenseGenerationRequest);
        System.debug('Request Body: = ' + request.getBody());
        Http h = new Http();
        HttpResponse response = h.send(request);

        System.debug('status = ' + response.getStatus());
        System.debug('status code = ' + response.getStatusCode());
        System.debug('body = ' + response.getBody());

        LicenseGenerationResponse licenseGenerationResponse = (LicenseGenerationResponse) JSON.deserialize(response.getBody(), LicenseGenerationResponse.class);
        licenseGenerationResponse.httpStatusCode = response.getStatusCode();
        licenseGenerationResponse.httpStatus = response.getStatus();
        return licenseGenerationResponse;
    }


    private HttpRequest createHttpRequest(LicenseGenerationRequest licenseGenerationRequest) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint(licenseGenerationRequest.api_url);
            
        httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        //httpRequest.setBody(JSON.serialize(licenseGenerationRequest));
        httpRequest.setBody(licenseGenerationRequest.getFormBody());
        return httpRequest;
    }
}