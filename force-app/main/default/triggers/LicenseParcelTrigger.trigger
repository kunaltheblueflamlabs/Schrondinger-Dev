/**
 * Created by rohit on 9/25/18.
 */

trigger LicenseParcelTrigger on License_Parcel__c (before insert) {

    LicenseParcelTriggerHandler handler = new LicenseParcelTriggerHandler(Trigger.isExecuting);
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.doBeforeInsert(Trigger.new);
        }
    }
}