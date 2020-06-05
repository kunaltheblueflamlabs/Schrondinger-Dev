({
    doInit : function(component, event, helper) {
        console.log('License_CreateOrderLicenseParcels.doInit()');
        helper.doInit(component);
    },

    submitClickHandler : function(component, event, helper) {
        console.log('License_CreateOrderLicenseParcels.submitClickHandler()');
        helper.createRequest(component);
    },

    cancelClickHandler : function(component, event, helper) {
        console.log('License_CreateOrderLicenseParcels.cancelClickHandler()');
        $A.get("e.force:closeQuickAction").fire();
    },
})