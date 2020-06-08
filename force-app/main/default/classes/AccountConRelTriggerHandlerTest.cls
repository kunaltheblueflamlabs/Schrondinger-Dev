/**
 * , RA, 09/17/2018
 * 
 * 09/17/2018 - Created Test coverage for the AccountConRelTriggerHandler class.
 */
 
@isTest
public class AccountConRelTriggerHandlerTest{
      static testMethod void  testValidateMethod(){
   
        //This is a test ACCOUNT Insert
      Account acc = new Account();
      acc.Name = 'bundle'; 
      acc.Active__c=true;
      insert acc;
      
      Account acc1 = new Account();
      acc1.Name = 'bundle11'; 
      acc1.Active__c=true;
      insert acc1;

      Account acc3 = new Account();
      acc3.Name = 'bundle2'; 
      acc3.Active__c=true;
      insert acc3;
      
      Contact con = new Contact();
      con.AccountId = acc1.Id;
      con.LastName = 'test123';
      insert con;
      
      Contact con2 = new Contact();
      con2.AccountId = acc3.Id;
      con2.LastName = 'test123456';
      insert con2;
      
      Contact con3 = new Contact();
      con3.AccountId = acc3.Id;
      con3.LastName = 'test123006';
      insert con3;
   
      List<AccountContactRelation> lstAccConRel=new List<AccountContactRelation>();    
          
          AccountContactRelation acr = new AccountContactRelation();
          acr.AccountId = acc.Id;
          acr.ContactId = con.Id;
          acr.Relationship_Strength__c = 'Strong';
          acr.IsActive=true;
          lstAccConRel.add(acr);
          insert acr;
          
          acr.Roles = 'Board Member';
          update acr;
          
          AccountContactRelation acr1 = new AccountContactRelation();
          acr1.AccountId = acc.Id;
          acr1.ContactId = con2.Id;
          acr1.Roles = 'Additional License Generator';
          acr1.Relationship_Strength__c = 'Strong';
          acr1.IsActive=true;
          lstAccConRel.add(acr1);
          insert acr1;
          
          AccountContactRelation acr2 = new AccountContactRelation();
          acr2.AccountId = acc.Id;
          acr2.ContactId = con3.Id;
          acr2.Roles = 'Additional License Generator';
          acr2.Relationship_Strength__c = 'Strong';
          acr2.IsActive=true;
          lstAccConRel.add(acr2);
          insert acr2;

      Map<id,AccountContactRelation> mapofAccCon=new Map<id,AccountContactRelation>();
      mapofAccCon.put(acr1.id,acr1);
      mapofAccCon.put(acr.id,acr);
      
      AccountConRelTriggerHandler.validate(lstAccConRel,mapofAccCon);
      
      List<AccountContactRelation> lstresult=[Select id from AccountContactRelation where roles='Additional License Generator'];
      
      System.assertEquals(2,lstresult.size());
    }
}