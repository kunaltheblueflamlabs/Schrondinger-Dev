/**
 * Created by rohit on 10/1/18.
 */

public with sharing class LicenseGenerationRequest {

    public String request_type;
    public String token;
    public String signature;
    public String sign_only;
    public String file_contents;
    public String api_url='';

    public static LicenseGenerationRequest parse(String json) {
        return (LicenseGenerationRequest) System.JSON.deserialize(json, LicenseGenerationRequest.class);
    }

    public String getFormBody() {
        String body = 'request_type=' + request_type + '&token=' + token + '&signature=' + signature +
                '&sign_only=' + sign_only + '&file_contents=' + file_contents;
        return body;
    }

}