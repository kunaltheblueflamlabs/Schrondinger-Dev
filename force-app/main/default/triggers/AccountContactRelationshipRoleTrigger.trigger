trigger AccountContactRelationshipRoleTrigger on AccountContactRelation (before insert,before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){

            AccountConRelTriggerHandler.validate(Trigger.new, Trigger.oldmap);
       
    }
   
}