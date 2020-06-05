/**
 * Created by rohit on 9/25/18.
 */

public with sharing class LicenseParcelTriggerHandler {

    private Boolean isExecuting;

    public LicenseParcelTriggerHandler(Boolean isExecuting) {
        this.isExecuting = isExecuting;
    }

    public void doBeforeInsert(List<License_Parcel__c> licenseParcels) {
        //for (License_Parcel__c licenseParcel : licenseParcels) {
        for (Integer i = 0; i < licenseParcels.size(); i++) {
            License_Parcel__c licenseParcel = licenseParcels.get(i);
            String uid = generateHashKey(i, licenseParcel.License_Event__c);
            System.debug('uid = ' + uid);
            licenseParcel.UID__c = uid;
        }
    }

    public String generateHashKey(Integer i, Id eventId) {
        String hashString = 'Sch0d!ng3r' + i + eventId +
                String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        return EncodingUtil.convertToHex(hash);

    }
}