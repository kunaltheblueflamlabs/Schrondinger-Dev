/**
 * Created by rohit on 8/22/18.
 */

public with sharing class LicenseAuraController {

    @AuraEnabled
    public static License_Event__c getLicenseRequestDates(String quoteId) {

        if (String.isEmpty(quoteId)) {
            throw new AuraHandledException('Invalid Quote Id');
        }

        LicenseEventController controller = new LicenseEventController(quoteId);
        try{
            License_Event__c licenseEvent = controller.getLicenseRequestDates();
            return licenseEvent;
        } catch (LicenseException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;

    }

    @AuraEnabled
    public static License_Event__c getOrderLicenseRequestDates(String orderId) {
        System.debug('Orderid--'+orderId);
        if (String.isEmpty(orderId)) {
            throw new AuraHandledException('Invalid Order Id');
        }

        LicenseEventOrderController controller = new LicenseEventOrderController(orderId);
        try{
            License_Event__c licenseEvent = controller.getLicenseRequestDates();
            return licenseEvent;
        } catch (LicenseException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;

    }

    @AuraEnabled
    public static String createLicenseRequest(License_Event__c licenseEvent) {
        //System.debug('StartDate = ' + licenseEvent.Start_Date__c);
        //System.debug('EndDate = ' + licenseEvent.End_Date__c);
        if (licenseEvent == null) {
            throw new AuraHandledException('Invalid Input Parameters. Unable to Create License Request');
        }

        LicenseEventController controller = new LicenseEventController(licenseEvent);
        try{
            Id licenseEventId = controller.createLicenseRequest();
            return licenseEventId;
        } catch (LicenseException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createLicenseOrderRequest(License_Event__c licenseEvent) {
        if (licenseEvent == null) {
            throw new AuraHandledException('Invalid Input Parameters. Unable to Create License Request');
        }

        LicenseEventOrderController controller = new LicenseEventOrderController(licenseEvent);
        try{
            Id licenseEventId = controller.createLicenseOrderRequest();
            return licenseEventId;
        } catch (LicenseException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    @AuraEnabled
    public static void addToParcelGroups(String quoteId) {

        if (String.isEmpty(quoteId)) {
            throw new AuraHandledException('Invalid Quote Id');
        }

        LicenseEventController controller = new LicenseEventController(quoteId);
        try{
            controller.createLicenseRequest();
        } catch (LicenseException e) {
            throw new AuraHandledException(e.getMessage());
        }

    }
    
    @AuraEnabled
    public static String callGenerateFileMethod(String recordId){  
        String message = 'File Generated Successfully';
        Boolean error = false;
        try{
            List<License_Parcel__c> licenseParcels = new List<License_Parcel__c>();
            String selectedField = 'Id, Name, of_Nodes__c, FlexLM_Submethod__c, FLEXlm_Server_Port__c, Vendor_Port__c, ' +
                    'of_files_generated__c, Template_Generated__c, License_Event__r.Account__r.Name, ' +
                    'License_Event__r.Release__c,License_Event__r.Release__r.Name,Quantity__c, License_Contact__c';
            String filter = ' WHERE ';
            
            if(recordId.startsWith(Schema.SObjectType.License_Parcel__c.getKeyPrefix())){
                filter += 'Id =: recordId AND License_Method__c = \'FlexLM\'';
            }else{
                filter += 'License_Event__r.Id =: recordId AND License_Method__c = \'FlexLM\'';
            }
            System.debug('SELECT '+ selectedField+ ' FROM License_Parcel__C '+ filter);
            licenseParcels = Database.query('SELECT '+ selectedField+ ' FROM License_Parcel__C '+ filter);

            if(licenseParcels.isEmpty()){
                message = 'Error : License Parcel record not found ' + recordId; 
            }
            else if(recordId.startsWith(Schema.SObjectType.License_Parcel__c.getKeyPrefix()) && licenseParcels[0].Template_Generated__c) {
                message = 'Error : Template file already generated for this License Parcel'; 
            } 
            else{
                List<License_Parcel__c> validLicenseParcels = new List<License_Parcel__c>();
                for(License_Parcel__C lp : licenseParcels) {
                    if (lp.License_Contact__c == null) {
                        message = 'Error : A License Contact is required before generating the file.';
                        error = true;
                        break;

                    }
                    if(!lp.Template_Generated__c) {
                        validLicenseParcels.add(lp);
                    }
                }
                if(!validLicenseParcels.isEmpty() && (!error)) {
                    LicenseRequestFileGenerator fileGenerator = new LicenseRequestFileGenerator();
                    fileGenerator.generate(validLicenseParcels, true, null);      
                }
            }
            
        }catch(Exception excp){
            System.debug(excp.getStackTraceString());
            message = 'Error : '+excp.getMessage();
        }
        return message;
        //generate(licenseParcels);
    }

    @AuraEnabled
    public static List<License_Product__c> getLicenseProducts(String licenseEventId){
        List<License_Product__c> licenseProducts = new List<License_Product__c>();
        if(String.isNotBlank(licenseEventId)){
            licenseProducts = [
                    SELECT Product__r.Name, Product__r.Description,License_Parcel__r.License_Method__c,
                            License_Parcel__r.Parcel_Group__c,
                             Start_Date__c, End_Date__c, Quantity__c, Required_By__c
                    FROM License_Product__c
                    WHERE License_Parcel__r.License_Event__r.Id = :licenseEventId
                    ORDER BY License_Parcel__r.Parcel_Group__c, Required_By__c ASC
                    ];
        }
        return licenseProducts;
    }
}