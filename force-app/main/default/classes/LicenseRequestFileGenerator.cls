public without sharing class LicenseRequestFileGenerator extends LicenseRequestFileConstants {
    
    public string generate(List<License_Parcel__c> licenseParcels, boolean isTemplate, List<InnerClassServers> serv) {
        Map<Id, List<License_Product__c> > parcelToProducts = new Map<Id, List<License_Product__c> >();
        Map<String, List<Token_Set_Line_Item__c>> releaseProductToTLI = new Map<String, List<Token_Set_Line_Item__c> >();        
        Map<Id, List<ContentVersion>> parcelToContentVersions = new Map<Id, List<ContentVersion>>();
        Set<Id> releaseIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();        
        Set<Id> licenseParcelIds = new Set<Id>();
        
        for (License_Parcel__c licenseParcel : licenseParcels) {        
            releaseIds.add(licenseParcel.License_Event__r.Release__c);
            licenseParcelIds.add(licenseParcel.Id);
        }

        for (License_Product__c licenseParcelProduct : LicenseDB.getLicenseProducts(licenseParcelIds))
        {
            
            productIds.add(licenseParcelProduct.Product__c); 
            for (License_Product__c pr : licenseParcelProduct.License_Products__r) {                
                    productIds.add(pr.Product__c);                
            }   
            if (!parcelToProducts.containsKey(licenseParcelProduct.License_Parcel__c)) {
                parcelToProducts.put(licenseParcelProduct.License_Parcel__c, new List<License_Product__c>{licenseParcelProduct});            
                //parcelToProducts.get(licenseParcelProduct.License_Parcel__c).adD(licenseParcelProduct);
            } else {
                parcelToProducts.get(licenseParcelProduct.License_Parcel__c).add(licenseParcelProduct);
            } 
        }
        
        for (Token_Set_Line_Item__c tokenSetLineItem : [SELECT Id, Name, Include_In_Library__c,License_Token__c,Quantity__c,
                License_Token__r.Name,Token_Set__r.Release__c,Token_Set__r.Product__c
                FROM Token_Set_Line_Item__c
                WHERE Token_Set__r.Release__c in: releaseIds and Token_Set__r.Product__c in: productIds])
        {
    
            if (!releaseProductToTLI.containsKey(tokenSetLineItem.Token_Set__r.Release__c + '-'+ tokenSetLineItem.Token_Set__r.Product__c)) {
                releaseProductToTLI.put(tokenSetLineItem.Token_Set__r.Release__c + '-'+tokenSetLineItem.Token_Set__r.Product__c, new List<Token_Set_Line_Item__c>{tokenSetLineItem});
                
            } else {
                releaseProductToTLI.get(tokenSetLineItem.Token_Set__r.Release__c + '-' + tokenSetLineItem.Token_Set__r.Product__c).add(tokenSetLineItem);
            } 
        }

        for (License_Parcel__c licenseParcel : licenseParcels) {
            String fileContent = writeFileContent(licenseParcel,parcelToProducts.get(licenseParcel.id),releaseProductToTLI, isTemplate, serv);
            
            List<ContentVersion> fileList = new List<ContentVersion>();
            if(isTemplate) {
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.VersionData = Blob.valueOf(fileContent);
                contentVersion.Title = 'License_Request_' + licenseParcel.Id + '_Template.txt';
                contentVersion.PathOnClient = 'License_Request_' + licenseParcel.Id + '.txt';
                fileList.add(contentVersion);
                licenseParcel.Template_Generated__c = true;
                licenseParcel.Status__c = 'Licensing in Progress';
            }
            else {
                if(licenseParcel.of_files_generated__c == null) {
                    licenseParcel.of_files_generated__c = 0;
                }
                licenseParcel.of_files_generated__c++;
                //system.assert(false, licenseParcel.FlexLM_Submethod__c );
                if(licenseParcel.FlexLM_Submethod__c == 'Node-Locked') {
                    List<License_Machine_Information__c> currentmis = [SELECT Id FROM License_Machine_Information__c WHERE License_Parcel__c =:licenseParcel.Id];
                    Integer currentNodes = currentmis.size();
                    Integer newNodes = serv.size();
                    if((licenseParcel.of_Nodes__c - (currentNodes + newNodes)) == 0) {
                        licenseParcel.License_Generated__c = true;
                    }
                    
                }
                else {
                    licenseParcel.License_Generated__c = true;
                }
                
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.VersionData = Blob.valueOf(fileContent);
                contentVersion.Title = 'License_Request_' + licenseParcel.Id + '_' + licenseParcel.of_files_generated__c +'.txt';
                contentVersion.PathOnClient = 'License_Request_' + licenseParcel.Id + '_' + licenseParcel.of_files_generated__c +'.txt';
                fileList.add(contentVersion);
                    
                List<Generate_File_API_Parameters__mdt> apiParameters = [SELECT Request_Type__c, Signature__c, Sign_Only__c, Token__c,API_URL__c FROM Generate_File_API_Parameters__mdt];
                
                if(apiParameters.size() > 0) {
                    LicenseGenerationRequest request = new LicenseGenerationRequest();
                    request.request_type = apiParameters[0].Request_Type__c; //'encryption';
                    request.token = apiParameters[0].Token__c; // 'f6Ee5ikU7MHYjBLhyDJzEzfU8fz85EQa53d06b6f74f86228b3580ef6f'; //'2d911ede57f11779b13882962f8fe82765aa73f6';
                    request.sign_only = apiParameters[0].Sign_Only__c; //'false';
                    request.signature = apiParameters[0].Signature__c; //'true';
                    request.file_contents = fileContent;
                    request.api_url = apiParameters[0].API_URL__c;
                    
                    LicenseGenerationController controller = new LicenseGenerationController();
                    LicenseGenerationResponse licenseGenerationResponse = controller.generateLicense(request);
                        
                    if(licenseGenerationResponse.status == 'error') {
                        return licenseGenerationResponse.message;
                    }
                        
                    System.debug('response = ' + licenseGenerationResponse);
                    System.debug('response = ' + licenseGenerationResponse.file_contents);
                        
                    String responseContent =licenseGenerationResponse.file_contents;
                    if(responseContent != null && responseContent != '') {    
                        ContentVersion contentVersionResponse = new ContentVersion();
                        contentVersionResponse.VersionData = Blob.valueOf(responseContent);
                        contentVersionResponse.Title = 'License_Response_' + licenseParcel.Id + '_' + licenseParcel.of_files_generated__c +'.txt';
                        contentVersionResponse.PathOnClient = 'License_Response_' + licenseParcel.Id + '_' + licenseParcel.of_files_generated__c +'.txt';
                        fileList.add(contentVersionResponse);
                    }
                    else {
                        return System.Label.File_Generate_Error;
                    }
                }
                else {
                    return System.Label.File_Generate_Error;
                }
            }
            parcelToContentVersions.put(licenseParcel.Id, fileList);
        }
        
        if(!parcelToContentVersions.isEmpty()) {
            List<ContentVersion> insertCVList = new List<ContentVersion>();
            for(List<ContentVersion> cvList : parcelToContentVersions.values()) {
                insertCVList.addAll(cvList);
            }
            insert insertCVList;
        
            set<Id> contentVersionIds = new set<Id>();
            for(ContentVersion cv : insertCVList) {
                contentVersionIds.add(cv.Id);
            }
        
            Map<Id, ContentVersion> contentVersions = new Map<Id, ContentVersion>(
                [SELECT Id, ContentDocumentId, Origin, Title
                FROM ContentVersion
                WHERE Id = :contentVersionIds ORDER By Title DESC]);
        
            if(!contentVersions.isEmpty()) {
                List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
                for (License_Parcel__c licenseParcel : licenseParcels) {
                    for(ContentVersion contentVersion : parcelToContentVersions.get(licenseParcel.Id)) {
                        Id contentDocumentId = contentVersions.get(contentVersion.Id).ContentDocumentId;
                        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                        contentDocumentLink.ContentDocumentId = contentDocumentId;
                        contentDocumentLink.LinkedEntityId = licenseParcel.Id;
                        contentDocumentLink.ShareType = 'I';
                        
                        contentDocumentLinks.add(contentDocumentLink);
                    }
                    
                    //update the status of the parcels
                    licenseParcel.Status__c = 'Licensing in Progress';
                    if(isTemplate) {
                        licenseParcel.Template_Generated__c = true;
                        
                    }
                }
                insert contentDocumentLinks;
            }
            update licenseParcels;
            
        }
        return '';
    }

    public String writeFileContent(License_Parcel__c licenseParcel, List<License_Product__c> licenseParcelProducts,
            Map<String, List<Token_Set_Line_Item__c>> productTokens, boolean isTemplate, List<InnerClassServers> serv)
    {
        String fileContent = '';
        fileContent += COMMENT + 'License Request Code: ' + LICENSE_REQUEST_CODE + NEW_LINE;
        fileContent += COMMENT + 'Customer Name: ' + licenseParcel.License_Event__r.Account__r.Name + NEW_LINE;
        if(isTemplate || licenseParcel.FlexLM_Submethod__c != 'Node-Locked') {
            fileContent += getServerInfo(isTemplate, licenseParcel, serv);
        }
        fileContent += getLevelSpecs(isTemplate, licenseParcel, serv);
        if(licenseParcelProducts != null) {
            fileContent += getProductInfo(licenseParcel,licenseParcelProducts,productTokens, isTemplate);
        }
        return fileContent;
    }

    public String getServerInfo(boolean isTemplate, License_Parcel__c licenseParcel, List<InnerClassServers> serv) {
        String serverInfo = '[Server]' + NEW_LINE;
        if(isTemplate) {
            for (String key : SERVER_INFO.keySet()) {
                serverInfo += INDENT + key + ' = ' + SERVER_INFO.get(key) + NEW_LINE;
            }
        }
        else {
            if(serv.size() > 0) {
                serverInfo += INDENT + 'ServerName' + ' = ' + serv[0].machineName + NEW_LINE;
                serverInfo += INDENT + 'ServerHostID' + ' = ' + serv[0].hostId + NEW_LINE;
                serverInfo += INDENT + 'ServerPort' + ' = ' + licenseParcel.FLEXlm_Server_Port__c + NEW_LINE;
            }
            if(serv.size() == 3) {
                serverInfo += INDENT + 'RedundantServer2Name' + ' = ' + serv[1].machineName + NEW_LINE;
                serverInfo += INDENT + 'RedundantServer2HostID' + ' = ' + serv[1].hostId + NEW_LINE;
                serverInfo += INDENT + 'RedundantServer2Port' + ' = ' + licenseParcel.FLEXlm_Server_Port__c + NEW_LINE;
                serverInfo += INDENT + 'RedundantServer3Name' + ' = ' + serv[2].machineName + NEW_LINE;
                serverInfo += INDENT + 'RedundantServer3HostID' + ' = ' + serv[2].hostId + NEW_LINE;
                serverInfo += INDENT + 'RedundantServer3Port' + ' = ' + licenseParcel.FLEXlm_Server_Port__c + NEW_LINE;
            }
            serverInfo += INDENT + 'SCHRODPort' + ' = ' + licenseParcel.Vendor_Port__c + NEW_LINE;
        }
        return serverInfo;
    }

    public String getLevelSpecs(boolean isTemplate, License_Parcel__c licenseParcel, List<InnerClassServers> serv) {
        String serverInfo = '[SetLevelSpecs]' + NEW_LINE;
        for (String key : LEVEL_SPECS.keySet()) {
            if (key=='Release') {
                serverInfo += INDENT + key + ' = ' + licenseParcel.License_Event__r.Release__r.Name + NEW_LINE;
            }
            else if(key=='Scope' && licenseParcel.FlexLM_Submethod__c == 'Node-Locked') {
                if(isTemplate) {
                    serverInfo += INDENT + key + ' = {OPEN_NODELOCKED}' + NEW_LINE;
                }
                else {
                    serverInfo += INDENT + key + ' = ';
                    integer i = 0;
                    for(InnerClassServers serverDetail : serv) {
                        if(i > 0) {
                            serverInfo += ',';
                        }
                        serverInfo += serverDetail.hostId;
                        i++;
                    }
                    serverInfo += NEW_LINE;
                }
            }
            else {            
                serverInfo += INDENT + key + ' = ' + LEVEL_SPECS.get(key) + NEW_LINE;
            }
        }
        return serverInfo;
    }

    public String getProductInfo(License_Parcel__c licenseParcel,List<License_Product__c> licenseParcelProducts,Map<String, List<Token_Set_Line_Item__c>> productTokens, boolean isTemplate) {
        String productInfo = '';
        for (License_Product__c parcelProduct : licenseParcelProducts) {
            string tokenSetName = licenseParcel.License_Event__r.Release__c + '-' + parcelProduct.Product__c;

            if (parcelProduct.License_Products__r.size()>0) //library
            {
                productInfo += COMMENT + 'Start of Custom Suite' + NEW_LINE;
                productInfo += COMMENT + 'FlexLM Product' + NEW_LINE;
                productInfo += COMMENT + 'Token Library:' + NEW_LINE;
                for (License_Product__c pr : parcelProduct.License_Products__r) {
                    productInfo += INDENT + COMMENT + pr.Product__r.Name + NEW_LINE;
                }
                productInfo += '[SUITE_' + Datetime.now().getTime() + ']' + NEW_LINE;
                productInfo += INDENT + 'Number = ' + parcelProduct.Quantity__c + NEW_LINE;
                
                productInfo += INDENT + 'Components = ';
                string components='';                
                
                if (productTokens.containsKey(tokenSetName))
                {
                    for (Token_Set_Line_Item__c tokenLineItem : productTokens.get(tokenSetName)) {
                        if (tokenLineItem.Include_In_Library__c)
                            components += tokenLineItem.License_Token__r.Name + ',';
                    }
                }
                for (License_Product__c pr : parcelProduct.License_Products__r) {
                    System.debug('Sub Product = ' + pr.Product__r.Name);
                    System.debug('Sub Product = ' + pr.Id);
                    tokenSetName = licenseParcel.License_Event__r.Release__c + '-' + pr.Product__c;
                    for (Token_Set_Line_Item__c tokenLineItem : productTokens.get(tokenSetName)) {
                        if (tokenLineItem.Include_In_Library__c)
                            components += tokenLineItem.License_Token__r.Name + ',';
                    }
                }
                
                if (components!='')
                {
                    components = components.subString(0,components.length()-1) + NEW_LINE;
                    productInfo += components;
                }
                productInfo += INDENT + 'SortValue = 200'+ NEW_LINE;
                productInfo += INDENT + 'StartDate = ' + LicenseUtils.formatDate(parcelProduct.Start_Date__c, DATE_FORMAT) + NEW_LINE;
                productInfo += INDENT + 'ExpirationDate = ' + LicenseUtils.formatDate(parcelProduct.End_Date__c, DATE_FORMAT) + NEW_LINE;

                //for tokens not in library
                for (License_Product__c pr : parcelProduct.License_Products__r) {
                    tokenSetName = licenseParcel.License_Event__r.Release__c + '-' + pr.Product__c;

                    for (Token_Set_Line_Item__c tokenLineItem : productTokens.get(tokenSetName)) {
                        System.debug('$$Not in lib' + tokenLineItem);
                        if (!tokenLineItem.Include_In_Library__c) {
                            productInfo += '[' + tokenLineItem.License_Token__r.Name + ']' + NEW_LINE;
                            if (licenseParcel.FlexLM_Submethod__c != 'Node-Locked') { //isTemplate ||
                                productInfo += INDENT + 'Number = ' + (tokenLineItem.Quantity__c == null ? 0 : tokenLineItem.Quantity__c) * (parcelProduct.Quantity__c == null ? 0 : parcelProduct.Quantity__c) + NEW_LINE;
                            }
                            productInfo += INDENT + 'StartDate = ' + LicenseUtils.formatDate(parcelProduct.Start_Date__c, DATE_FORMAT) + NEW_LINE;
                            productInfo += INDENT + 'ExpirationDate = ' + LicenseUtils.formatDate(parcelProduct.End_Date__c, DATE_FORMAT) + NEW_LINE;
                        }
                    }
                }
            }
            else if (parcelProduct.Required_By__c == null) //not in library
            {
                if(productTokens.containsKey(tokenSetName)){
                    productInfo += '#'+ parcelProduct.Product__r.Name + NEW_LINE;
                    for (Token_Set_Line_Item__c tokenLineItem : productTokens.get(tokenSetName)) {
                        productInfo += '[' + tokenLineItem.License_Token__r.Name + ']' + NEW_LINE;
                        if(licenseParcel.FlexLM_Submethod__c != 'Node-Locked') {//isTemplate ||
                            productInfo += INDENT + 'Number = ' + (tokenLineItem.Quantity__c==null?0:tokenLineItem.Quantity__c) * (parcelProduct.Quantity__c==null?0:parcelProduct.Quantity__c) + NEW_LINE;
                        }
                        productInfo += INDENT + 'StartDate = ' + LicenseUtils.formatDate(parcelProduct.Start_Date__c, DATE_FORMAT) + NEW_LINE;
                        productInfo += INDENT + 'ExpirationDate = ' + LicenseUtils.formatDate(parcelProduct.End_Date__c, DATE_FORMAT) + NEW_LINE;
                    }
                }
                
            }
        }
        return productInfo;
    }
    /*
    //test method
    public static void main() {
        
        List<License_Parcel__c> licenseParcels = [
                SELECT Id, Name, License_Event__r.Account__r.Name,License_Event__r.Release__c,
                        License_Event__r.Release__r.Name,Quantity__c
                FROM License_Parcel__c
                WHERE Id = 'a1M1b000000dXc0' AND License_Method__c = 'FlexLM'
        ];
        LicenseRequestFileGenerator fileGenerator = new LicenseRequestFileGenerator();
        fileGenerator.generate(licenseParcels, true, null);
    }
    */
}