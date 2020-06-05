({
    doInit : function(component, event, helper) {
        var recordUi = event.getParam('recordUi');
        var f = recordUi.record;
        component.set('v.data', f.fields['Payment_Table__c'].value);
    }
})