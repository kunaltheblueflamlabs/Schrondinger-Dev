/*
 * Description : This class is use as test class of LicenseRequestFileGenerator
*/
@isTest
public class LicenseRequestFileGeneratorTest {
    @testSetup static void setUp() {
        Release__c release =  TestUtils.createRelease('test Release', true);
        
        License_Event__c licenseEvent = TestUtils.createLicenseEvent(false);
        licenseEvent.Release__c = release.ID;
        insert licenseEvent;

        License_Parcel__c floating = TestUtils.createLicenseParcel('', licenseEvent.Id, false);
        floating.License_Method__c = 'FlexLM';
        insert floating;
        
        Product2 product2Obj = TestUtils.createProduct2(true);
        
        License_Product__c licenseProduct1 = TestUtils.createLicenseProduct(false);
        licenseProduct1.License_Parcel__C = floating.Id;
        insert licenseProduct1;
        
        License_Product__c licenseProduct2 = TestUtils.createLicenseProduct(false);
        licenseProduct2.Product__c = product2Obj.Id;
        licenseProduct2.License_Parcel__C = floating.Id;
        licenseProduct2.Required_By__c = licenseProduct1.Id;
        insert licenseProduct2;
        
        Token_Set__c tokenSet = TestUtils.createTokenSet(false);
        tokenSet.Product__c = product2Obj.Id;
        tokenSet.Release__c = release.Id;
        insert tokenSet;
        
        License_Token__c license = TestUtils.createLicenseToken(true);
        
        Token_Set_Line_Item__c tsLineItem = TestUtils.createTokenSetLineItem(false);
        tsLineItem.License_Token__c = license.Id;
        tsLineItem.Token_Set__c = tokenSet.Id;
        insert tsLineItem;
        
    }

    public testMethod static void generateTextTestForTemplate(){
        List<License_Parcel__c> prcsl = [SELECT Id, Name, of_Nodes__c, FlexLM_Submethod__c, FLEXlm_Server_Port__c, Vendor_Port__c, 
                    						Of_Files_Generated__c, Template_Generated__c, License_Event__r.Account__r.Name,
                    						License_Event__r.Release__c, License_Event__r.Release__r.Name, Quantity__c FROM License_Parcel__c ];
        
        new LicenseRequestFileGenerator().generate(prcsl, true, null);
    }

    public testMethod static void generateTextTestForFile(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.StartTest();
        List<License_Parcel__c> prcsl = [SELECT Id, Name, of_Nodes__c, FlexLM_Submethod__c, FLEXlm_Server_Port__c, Vendor_Port__c, 
                    						Of_files_generated__c, Template_Generated__c, License_Event__r.Account__r.Name,
                    						License_Event__r.Release__c,License_Event__r.Release__r.Name,Quantity__c FROM License_Parcel__c ];
        
        prcsl[0].FlexLM_Submethod__c = 'Node-Locked';
        List<InnerClassServers> serv = new List<InnerClassServers>();
       	serv.add(TestUtils.createInnerClassServers('host1', 'machine1', 'Server 1'));
        serv.add(TestUtils.createInnerClassServers('host2', 'machine2', 'Server 2'));
        serv.add(TestUtils.createInnerClassServers('host3', 'machine3', 'Server 3'));
            
        new LicenseRequestFileGenerator().generate(prcsl, false, serv);
        Test.StopTest();
    }

}