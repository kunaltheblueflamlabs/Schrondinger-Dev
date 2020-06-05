/**
* RA, 09/13/2018
* Handler class for validating the Account Contact relationship
* to be unique for mostly all relationships except a few where 2 relationships are allowed.
*/
public class AccountConRelTriggerHandler{
    
    /**
* validate the account contact relationship records, the method will raise an 
* error if rules are not followed 
* @param list of relationship records
* @return NA
*/
    public static void validate(List<AccountContactRelation> newList , Map<Id, AccountContactRelation>oldMap){
        
        system.debug('@@@ trigger.new values '+newList );
        system.debug('@@@ trigger.oldvalues '+oldMap);
        
        List<AccountContactRelation> lstaccConRel = newList; //newMap.values();
        if(lstaccConRel.size()>0){
            system.debug('@@@ trigger.new values '+lstaccConRel);
        }
        
        Set<id> setAccids= new Set<id>();
        List<String> lstRolesStr=new List<String>();
        
        // exception of roles that allow more than one person on the same role
        Set<String> setTwiceAllowedRoles=new Set<String>{
            'Additional Invoice Receiver',
                'Additional License Generator',
                'Additional License Receiver'
                };
                    
                    for(AccountContactRelation accon : lstaccConRel){
                        if(accon.AccountId!=null){
                            setAccids.add(accon.AccountId);
                        }
                    }
        
        // query the account contact relationships
        Map<Id, Set<String>> mapOfAccConRel= new Map<Id, Set<String>>();
        
        for(AccountContactRelation rel: [select id, AccountId, Roles from AccountContactRelation where Accountid in :setAccids]){
                                             
                                             Set<String> roles = mapOfAccConRel.get(rel.AccountId);
                                             if(rel.Roles!=null){
                                                lstRolesStr.addAll(rel.Roles.split(';'));
                                             }
                                             if(roles == null) roles = new Set<String>();
                                             
                                             // add roles and put into Map
                                             if(rel.Roles != null) {
                                                 roles.addAll(rel.Roles.split(';'));
                                             }
                                             mapOfAccConRel.put(rel.AccountId, roles);
                                         }
        
        // introspect the relationships being upserted and throw error if it breaks the rules
        for(AccountContactRelation accon : lstaccConRel){
            if(accon.Roles!=null){
                //String[] str = accon.Roles.split(';');
                
                if(mapOfAccConRel.size()>0){
                    Set<String> setOfRoles = mapOfAccConRel.get(accon.AccountId);
                    
                    String oldVal, newVal,message;
                    if(oldMap != null && oldMap.get(accon.Id) != null) oldVal = oldMap.get(accon.Id).Roles;
                    newVal = accon.Roles;     //newMap.get(accon.Id).Roles;
                    
                    Set<String> str = getDifferentialRoles(oldVal, newVal);
                
                    for(String st:str){
                        
                        if(setOfRoles.contains(st) && !setTwiceAllowedRoles.contains(st) ){ 
                            
                            System.debug('>>> Raise Error 1 :' + setOfRoles + ', st: '+ st);
                            accon.addError(Label.Account_Contact_Relation_Error+' \''+st+'\' relationship');
                        }
                        
                        if(setOfRoles.contains(st) && setTwiceAllowedRoles.contains(st)){
                         
                            Integer cnt=countOfRoles(st,lstRolesStr);
                            
                            // for certain roles we allow more than one relationship
                            if(cnt==2){
                                System.debug('>>> Raise Error 2 ');
                                accon.addError(Label.Account_Contact_Relation_Trigger_multiple_roles+' \''+st+'\' relationship');
                            }
                        }
                    }  
                
                               
                }
                
             
            }
        }
    }
    
    private static Integer countOfRoles(String str,List<String> lstRolesStr){
        
        Integer count=0;
        for(Integer i=0;i<lstRolesStr.size();i++){
            if(lstRolesStr[i]==str){
                count++;
            }    
        }
        return count;
    }
    
    /**
* function to get the differential role being updated to a relationship record
* @param - oldVal represents the old value of the role field
* @param - newVal represents the new value of the role field
* @return - set of string representing the differential role values in a set
*/
    private static Set<String> getDifferentialRoles(String oldVal, String newVal) {
        Set<String> result = new Set<String>();
        if(oldVal == null || oldVal == '') {
            result.addAll(newVal.split(';'));
            return result;
        }
        Set<String> oldSet = new Set<String>();
        oldSet.addAll(oldVal.split(';'));
        
        Set<String> newSet = new Set<String>();
        newSet.addAll(newVal.split(';'));
        
        // find the net new values being added
        for(String val: newSet) {
            if(!oldSet.contains(val)) result.add(val);
        }
        return result;
    }
    
}