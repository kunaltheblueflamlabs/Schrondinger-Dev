@isTest
public class LicenseEventOrderController_Test {
    public static testMethod void  createLicenseRequestTestCopy(){
        Account accVar = TestUtils.createAccount(true);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        order orderVar = TestUtils.createOrder(false);
        orderVar.Pricebook2Id = pricebookId;
        insert orderVar;
        
        Product2 prod = TestUtils.createProduct2(true);
        
        PricebookEntry priceEntryVar = TestUtils.createPricebookEntry(false);
        priceEntryVar.Pricebook2Id = pricebookId;
        priceEntryVar.Product2Id = prod.Id;
        insert priceEntryVar;
        
        
        OrderItem ordrItmVar = TestUtils.createOrderItem(false);
        ordrItmVar.OrderId = orderVar.Id;
        ordrItmVar.Product2id = prod.Id;
        ordrItmVar.PricebookEntryId = priceEntryVar.id;
        insert ordrItmVar;
        
        
        License_Event__c eventLicenseVar = TestUtils.createLicenseEvent(false);
        //eventLicenseVar.Order__c = orderVar.Id;
        
        LicenseEventOrderController licenseEventCtrl = new LicenseEventOrderController(orderVar.id);

        eventLicenseVar = licenseEventCtrl.getLicenseRequestDates();
        licenseEventCtrl.createLicenseOrderRequest();
        
        LicenseParcelOrderBean lb = new LicenseParcelOrderBean(eventLicenseVar,'2','PyMOL');
    }
}