({
    getLicenseProducts : function(cmp) {
        var action = cmp.get("c.getLicenseProducts");
        action.setParams({ licenseEventId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                cmp.set("v.LicenseProducts",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})