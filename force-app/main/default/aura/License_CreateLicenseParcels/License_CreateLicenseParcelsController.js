/**
 * Created by rohit on 9/7/18.
 */
({
    doInit : function(component, event, helper) {
        console.log('License_CreateLicenseParcels.doInit()');
        helper.doInit(component);
    },

    submitClickHandler : function(component, event, helper) {
        console.log('License_CreateLicenseParcels.submitClickHandler()');
        helper.createRequest(component);
    },

    cancelClickHandler : function(component, event, helper) {
        console.log('License_CreateLicenseParcels.cancelClickHandler()');
        $A.get("e.force:closeQuickAction").fire();
    },
})