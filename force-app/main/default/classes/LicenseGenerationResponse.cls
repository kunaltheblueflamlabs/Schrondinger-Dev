/**
 * Created by rohit on 10/1/18.
 */

public with sharing class LicenseGenerationResponse {

    public String status;
    public String file_contents;
    public String message;

    public Integer httpStatusCode;
    public String httpStatus;


    public static LicenseGenerationResponse parse(String json) {
        return (LicenseGenerationResponse) System.JSON.deserialize(json, LicenseGenerationResponse.class);
    }

}