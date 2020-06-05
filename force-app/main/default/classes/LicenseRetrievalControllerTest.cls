@isTest
private class LicenseRetrievalControllerTest {
    
    @testSetup static void setUp() {

        License_Event__c eventObj = TestUtils.createLicenseEvent(true);
        
		License_Parcel__c nodeLocked = TestUtils.createLicenseParcel('Node-Locked', eventObj.Id, false);
        License_Parcel__c floating = TestUtils.createLicenseParcel('Floating', eventObj.Id, false);
        
        insert new List<License_Parcel__c> {floating, nodeLocked};
        
        Product2 floatingProduct = TestUtils.createProduct2(false);
        Product2 nodeLockedProduct = TestUtils.createProduct2(false);
        
        insert New List<Product2> {floatingProduct, nodeLockedProduct};
        
        License_Product__c floatingLicenseProduct = TestUtils.createLicenseProduct(floatingProduct.Id, nodeLocked.Id, false);
        License_Product__c nodeLockedLicenseProduct = TestUtils.createLicenseProduct(floatingProduct.Id, nodeLocked.Id, false);
        
        insert new List<License_Product__c> {floatingLicenseProduct, nodeLockedLicenseProduct};
    }

    @isTest static void saveSingleTest() {
        License_Parcel__c licenseParcelObj = [SELECT Id, UID__c FROM License_Parcel__c WHERE FlexLM_Submethod__c = 'Floating' LIMIT 1 ];
        
        ApexPages.currentPage().getParameters().put('licgen', licenseParcelObj.UID__c);
        LicenseRetrievalController licenseRetrivelControllerObj = new LicenseRetrievalController();
        licenseRetrivelControllerObj.isSingle = true;
        licenseRetrivelControllerObj.parcel.Host_ID_MAC_Address_1__c = '00A0C914C829';
        licenseRetrivelControllerObj.parcel.Machine_Name_1__c = 'Test Machine'; 
        licenseRetrivelControllerObj.next();
        System.assert(licenseRetrivelControllerObj.serv.size() == 1);
        licenseRetrivelControllerObj.back();
    }
    
    @isTest static void saveTriadTest() {
        License_Parcel__c prcsl = [SELECT Id, UID__c FROM License_Parcel__c WHERE FlexLM_Submethod__c = 'Floating' LIMIT 1 ];
        ApexPages.currentPage().getParameters().put('licgen', prcsl.UID__c);
        LicenseRetrievalController lrc = new LicenseRetrievalController();
        lrc.isSingle = false;
        lrc.isTriad = true;
        lrc.parcel.Host_ID_MAC_Address_1__c = '00A0C914C829';
        lrc.parcel.Machine_Name_1__c = 'Test Machine 1'; 
        lrc.parcel.Host_ID_MAC_Address_2__c = '00A0C914C828';
        lrc.parcel.Machine_Name_2__c = 'Test Machine 2'; 
        lrc.parcel.Host_ID_MAC_Address_3__c = '00A0C914C827';
        lrc.parcel.Machine_Name_3__c = 'Test Machine 3'; 
        lrc.next();
        System.assert(lrc.serv.size() == 3);
    }

    @isTest static void saveCloudTest() {
        
        License_Parcel__c prcsl = [SELECT Id, UID__c FROM License_Parcel__c WHERE FlexLM_Submethod__c = 'Floating' LIMIT 1 ];
        System.assert(prcsl != null, 'Parcel exists.');
        ApexPages.currentPage().getParameters().put('licgen', prcsl.UID__c);
        LicenseRetrievalController lrc = new LicenseRetrievalController();

        lrc.isSingle = false;
        lrc.isCloud = true;
        lrc.parcel.Host_ID_MAC_Address_1__c = '00A0C914C829';
        lrc.next();

        System.assert(lrc.serv.size() == 1);
    }

    @isTest static void saveNodeLockedTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.StartTest();
        
        License_Parcel__c prcsl = [SELECT Id, UID__c FROM License_Parcel__c WHERE FlexLM_Submethod__c = 'Node-Locked' LIMIT 1 ];
        ApexPages.currentPage().getParameters().put('licgen', prcsl.UID__c);
        LicenseRetrievalController lrc = new LicenseRetrievalController();

        lrc.macAddresses = '00A0C914C829;name1/00A0C914C822;name2/';
        lrc.next();
        lrc.finish();
        lrc.finishValuesNodeLocked();
        lrc.finishValuesFloating();
        LicenseRetrievalController.sendEmail(prcsl.Id);
        Test.StopTest();
        
        List<License_Machine_Information__c> machines = [ SELECT Id FROM License_Machine_Information__c ];
        System.assert(machines.size() == 2);
    }

    @isTest static void changeSingleTest() {
        License_Parcel__c prcsl = [SELECT Id, UID__c FROM License_Parcel__c WHERE FlexLM_Submethod__c = 'Node-Locked' LIMIT 1 ];
        ApexPages.currentPage().getParameters().put('licgen', prcsl.UID__c);
        LicenseRetrievalController lrc = new LicenseRetrievalController();
        lrc.changeSingle();
        System.assert(lrc.isSingle);
    }

    @isTest static void changeTriadTest() {
        License_Parcel__c prcsl = [SELECT Id, UID__c FROM License_Parcel__c WHERE FlexLM_Submethod__c = 'Node-Locked' LIMIT 1 ];
        ApexPages.currentPage().getParameters().put('licgen', prcsl.UID__c);
        LicenseRetrievalController lrc = new LicenseRetrievalController();
        lrc.changeTriad();
        System.assert(lrc.isTriad);
    }

    @isTest static void changeCloudTest() {
        License_Parcel__c prcsl = [SELECT Id, UID__c FROM License_Parcel__c WHERE FlexLM_Submethod__c = 'Node-Locked' LIMIT 1 ];
        ApexPages.currentPage().getParameters().put('licgen', prcsl.UID__c);
        LicenseRetrievalController lrc = new LicenseRetrievalController();
        lrc.changeCloud();
        System.assert(lrc.isCloud);
    }
}