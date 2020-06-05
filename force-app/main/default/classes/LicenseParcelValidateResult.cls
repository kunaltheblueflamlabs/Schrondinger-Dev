/**
 * Created by rohit on 8/28/18.
 */

public with sharing class LicenseParcelValidateResult {

    public LicenseParcelBean bean {get; private set;}

    public Boolean valid {get; set;}
    public String errorMessage {get; set;}
    public String warningMessage {get; set;}
}