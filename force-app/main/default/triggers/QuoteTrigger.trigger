trigger QuoteTrigger on SBQQ__Quote__c (after update) {
    QuoteTriggerHandler.process(Trigger.newMap, Trigger.oldMap);
}