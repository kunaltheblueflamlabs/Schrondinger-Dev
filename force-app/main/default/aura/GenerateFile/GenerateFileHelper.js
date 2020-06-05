({
    doInit : function(cmp) {
        var action = cmp.get("c.callGenerateFileMethod");
        action.setParams({ recordId : cmp.get("v.recordId") });
		action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();

            if (!returnValue.startsWith('Error')) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success Message',
                    message: response.getReturnValue(),
                    type: 'success',
                });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success Message',
                    message: response.getReturnValue(),
                    type: 'error',
                });
                toastEvent.fire();
            }

            var dismissActionPanel = $A.get("e.force:closeQuickAction");
        	dismissActionPanel.fire();
        });
		$A.enqueueAction(action);
    }
})