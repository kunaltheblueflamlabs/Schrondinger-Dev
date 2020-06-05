/**
 * Created by rohit on 9/7/18.
 */
({
    doInit : function(component) {
        var action = component.get("c.getOrderLicenseRequestDates");
        
        action.setParams({
            "orderId" : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Success');
                component.set("v.licenseEvent", response.getReturnValue());
            } else if (state === "ERROR") {
                console.log('Error');
                
                this.handleError(component, response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    createRequest : function(component) {
        console.log('createRequest()');
        var action = component.get("c.createLicenseOrderRequest");
        action.setParams({
            "licenseEvent" : component.get("v.licenseEvent")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Success');
                this.handleSuccess(component, response.getReturnValue());
            } else if (state === "ERROR") {
                console.log('Error');
                this.handleError(component, response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    handleSuccess : function(component, licenseEventId) {
        console.log('licenseEventId = ' + licenseEventId);
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'License_Event__c',
                recordId: licenseEventId,
                actionName : "view"
            }
        };
        navService.navigate(pageReference);
    },

    handleError : function(component, errors) {
        console.log('handleError() errors = ' + errors[0].message);
        //component.set("v.showSpinner", false);
        if (errors && Array.isArray(errors) && errors.length > 0) {
            component.set("v.errorMessage", 'Error: ' + errors[0].message);
        } else {
            component.set("v.errorMessage", 'Error: Unknown error has occured.');
        }
        //$A.get("e.force:closeQuickAction").fire();

/*
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
*/


    }
})