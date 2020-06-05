public without sharing class LicenseRetrievalController {

    public String licgen                {get;set;}
    public License_Parcel__c parcel     {get;set;}
    public Boolean isSingle             {get;set;}
    public Boolean isTriad              {get;set;}
    public Boolean showTriad            {get;set;}
    public Boolean isCloud              {get;set;}
    public Boolean isNodeLocked         {get;set;}
    public Boolean showNodeLocked       {get;set;}
    public Boolean isDetail             {get;set;}
    public Integer nodesAvailable       {get;set;}
    public Integer nodesRemaining       {get;set;}
    public String currentMachines       {get;set;}
    public List<InnerClassServers> serv {get;set;}
    public String macAddresses          {get;set;}
    public Boolean isError              {get;set;}
    public String triad                 {get;set;}
    public String errorMessage {get; set;}
    public boolean isLicenseGenerated {get; set;}
    public List<ContentVersion> cvList {get; set;}

    public LicenseRetrievalController() {
        this.licgen = ApexPages.currentpage().getparameters().get('licgen');
        this.triad = ApexPages.currentPage().getParameters().get('triad');
        this.isTriad = (String.isNotEmpty(triad) && triad.equals('1'));
        List<License_Parcel__c> record = [
                SELECT Id, of_files_generated__c, of_Nodes__c, Host_ID_MAC_Address_1__c, Host_ID_MAC_Address_2__c, Host_ID_MAC_Address_3__c, Quantity_Used__c, Machine_Name_1__c,
                        Cloud_Host_ID__c, License_Generated__c, Machine_Name_2__c, Machine_Name_3__c, FlexLM_Submethod__c, Quantity__c,
                        FLEXlm_Server_Port__c, Vendor_Port__c, License_Event__r.Account__r.Name, License_Event__r.Release__c,License_Event__r.Release__r.Name
                FROM License_Parcel__c
                WHERE UID__c = :licgen
        ];
        
        this.isError = String.isEmpty(licgen) || record.isEmpty();
        if (isError) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Matching Records found.'));
        } else {
            this.parcel = record[0];
            this.isNodeLocked = parcel.FlexLM_Submethod__c == 'Node-Locked';
            List<License_Machine_Information__c> lmi = [ SELECT Id, Host_Id__c, Machine_Name__c FROM License_Machine_Information__c WHERE License_Parcel__c =: parcel.Id ];
            this.currentMachines = '';
            for ( License_Machine_Information__c m : lmi ) {
                String conc = m.Host_Id__c + ';' + m.Machine_Name__c + ',';
                currentMachines += conc;
            }
            this.resetFields();
            this.showNodeLocked = isNodeLocked;
            this.showTriad = isTriad;
            this.nodesAvailable = 20;
            if (parcel.of_Nodes__c != null) {
                Decimal nodeAv = parcel.of_Nodes__c;
                nodesAvailable = nodeAv.intValue();
            }
            this.nodesRemaining = nodesAvailable - lmi.size();
            this.serv = new List<InnerClassServers>();
            if (!isNodeLocked && !isTriad) {
                isSingle = true;
            }
            isLicenseGenerated = record[0].License_Generated__c;
            if(record[0].License_Generated__c) {
                this.next();
                set<Id> cdLinkIds = new Set<Id>();
                for(ContentDocumentLink cdLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:record[0].Id]) {
                    cdLinkIds.add(cdLink.ContentDocumentId);
                }
                cvList = new List<ContentVersion>();
                for(ContentVersion cv : [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :cdLinkIds AND IsLatest = true]) {
                    if(cv.title.contains('Response')) {
                        cvList.add(cv);
                    }
                }
            }
        }
        
    }

    public void next() {

        serv.clear();
        this.updateValuesSingle();
        this.updateValuesTriad();
        this.updateValuesCloud();
        this.updateValuesNodeLocked();
            
        this.resetFields();
        this.isDetail = true;
    }

    private void updateValuesSingle() {

        if (isSingle) {
            InnerClassServers sv = new InnerClassServers();
            sv.hostId = parcel.Host_ID_MAC_Address_1__c;
            sv.machineName = parcel.Machine_Name_1__c;
            sv.servNum = 'Server 1';
            serv.add(sv);
        }
    }

    private void updateValuesTriad() {

        if (isTriad) {
            InnerClassServers sv = new InnerClassServers();
            sv.hostId = parcel.Host_ID_MAC_Address_1__c;
            sv.machineName = parcel.Machine_Name_1__c;
            sv.servNum = 'Server 1';
            serv.add(sv);

            InnerClassServers sv2 = new InnerClassServers();
            sv2.hostId = parcel.Host_ID_MAC_Address_2__c;
            sv2.machineName = parcel.Machine_Name_2__c;
            sv2.servNum = 'Server 2';
            serv.add(sv2);

            InnerClassServers sv3 = new InnerClassServers();
            sv3.hostId = parcel.Host_ID_MAC_Address_3__c;
            sv3.machineName = parcel.Machine_Name_3__c;
            sv3.servNum = 'Server 3';
            serv.add(sv3);
        }
    }

    private void updateValuesCloud() {

        if (isCloud) {
            InnerClassServers sv = new InnerClassServers();
            sv.hostId = parcel.Cloud_Host_ID__c;
            serv.add(sv);
        }
    }

    private void updateValuesNodeLocked() {

        if (isNodeLocked) {
            loadNewServers();
        }
        
    }

    private void loadNewServers() {
        List<License_Machine_Information__c> currentmis = [ SELECT Id, Host_Id__c, Machine_Name__c FROM License_Machine_Information__c WHERE License_Parcel__c =:this.parcel.Id];
        
        Set<String> hosts = new Set<String>();
        Set<String> machnames = new Set<String>();
        
        Integer i = 1;
        for ( License_Machine_Information__c c : currentmis ) {
            if(!isLicenseGenerated) {
                hosts.add(c.Host_Id__c);
                machnames.add(c.Machine_Name__c);
            }
            else {
                InnerClassServers sv = new InnerClassServers();
                sv.hostId = c.Host_Id__c;
                sv.machineName = c.Machine_Name__c;
                sv.servNum = 'Server ' + i;
                serv.add(sv);
                i++;
            }
        }
        if(!isLicenseGenerated) {
            String[] addr;
            if(macAddresses != null) {
                addr = macAddresses.split('/', 0);
            } 
            
            if(addr != null) {
                for ( String s : addr ) {
                    if (String.isNotEmpty(s)) {
                        InnerClassServers sv = new InnerClassServers();
                        String[] strarr = s.split(';', 0);
                        sv.hostId = strarr[0];
                        sv.machineName = strarr[1];
                        sv.servNum = 'Server ' + i;
                        if (!hosts.contains(sv.hostId) && !machnames.contains(sv.machineName) ) {
                            serv.add(sv);
                            i++;
                        }
                    }
                }
            }
        }
    }

    public void finish() {
        String resultMessage = this.generateFiles();
        if(resultMessage == '') {
            
            this.finishValuesFloating();
            this.finishValuesNodeLocked();
            errorMessage = 'Changes saved.';
            List<License_Parcel__c> record = [
                    SELECT Id, of_Nodes__c, Host_ID_MAC_Address_1__c, Host_ID_MAC_Address_2__c, Host_ID_MAC_Address_3__c, Quantity_Used__c, Machine_Name_1__c,
                            Cloud_Host_ID__c, License_Generated__c, Machine_Name_2__c, Machine_Name_3__c, FlexLM_Submethod__c, Quantity__c,
                            FLEXlm_Server_Port__c, Vendor_Port__c
                    FROM License_Parcel__c
                    WHERE UID__c = :licgen
            ];
            if(record[0].License_Generated__c) {
                sendEmailFiles(record[0].Id);
                isLicenseGenerated = true;
                set<Id> cdLinkIds = new Set<Id>();
                for(ContentDocumentLink cdLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:record[0].Id]) {
                    cdLinkIds.add(cdLink.ContentDocumentId);
                }
                cvList = new List<ContentVersion>();
                for(ContentVersion cv : [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :cdLinkIds AND IsLatest = true]) {
                    if(cv.title.contains('Response')) {
                        cvList.add(cv);
                    }
                }
            }
            isDetail = true;
        }
        else { 
            List<License_Parcel__c> record = [SELECT Id, Status__c FROM License_Parcel__c WHERE UID__c = :licgen];
            if(!record.isEmpty()) {
                record[0].Status__c = 'Retrieval Error';
                update record;
            }
            errorMessage = resultMessage;
        }
        //this.back();
    }

    public string generateFiles() {
        LicenseRequestFileGenerator fileGenerator = new LicenseRequestFileGenerator();
        String errorMessage = fileGenerator.generate(new List<License_Parcel__c> {parcel}, false, serv);  
        return errorMessage;
    }

    public void back() {
        this.resetFields();
        this.reloadState();
    }
    
    @TestVisible
    private void finishValuesFloating() {

        if ( !isNodeLocked ) {
            update parcel;
        }
    }

    @TestVisible
    private void finishValuesNodeLocked() {

        if ( isNodeLocked ) {

            Id parcelId = this.parcel.Id;
            Set<String> hosts = new Set<String>();
            List<License_Machine_Information__c> currentmis = [ SELECT Id, Host_Id__c, Machine_Name__c FROM License_Machine_Information__c WHERE License_Parcel__c =:parcelId ];

            for ( License_Machine_Information__c c : currentmis ) {
                hosts.add(c.Host_Id__c + ' ' + c.Machine_Name__c);
            }

            List<License_Machine_Information__c> newlmis = new List<License_Machine_Information__c>();
            for ( InnerClassServers ics : serv ) {
                License_Machine_Information__c newmi = new License_Machine_Information__c();
                newmi.Host_Id__c = ics.hostId;
                newmi.Machine_Name__c = ics.machineName;
                newmi.Licensed__c = true;
                newmi.License_Parcel__c = parcel.Id;
                String concat = newmi.Host_Id__c + ' ' + newmi.Machine_Name__c;
                if (!hosts.contains(concat)) {
                    newlmis.add(newmi);
                }
            } 

            insert newlmis;
        }
    }


    public void resetFields() {

        this.isSingle = false;
        this.isCloud = false;
        this.isDetail = false;
        this.showNodeLocked = false;
        this.showTriad = false;
    }

    public void reloadState() {
        if (this.isNodeLocked) {
            this.showNodeLocked = true;
        } 
        else if (!isTriad) {
            this.isSingle = true;
        } 
        else {
            this.showTriad = true;
        }
    }

    public void changeSingle() {

        this.resetFields();
        this.isSingle = true;
    }

    public void changeTriad() {

        this.resetFields();
        this.isTriad = true;
    }

    public void changeCloud() {

        this.resetFields();
        this.isCloud = true;
    }
    
    @RemoteAction
    public static string sendEmail(string parcelId) {
        return sendEmailFiles(parcelId);
    }
    
    public static string sendEmailFiles(string parcelId) {
        List<License_Parcel__c> lstRecords = [SELECT Id, License_Contact__c FROM License_Parcel__c WHERE Id = :parcelId];
        if(!lstRecords.isEmpty()) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(lstRecords[0].License_Contact__c);
            email.setSubject(System.Label.License_File_Email_Subject);
            email.setHtmlBody(System.Label.License_File_Email_Body);
            
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for (ContentDocumentLink docLinks : [Select Id, ContentDocumentId  from ContentDocumentLink where LinkedEntityId = :parcelId]) { 
               for (ContentDocument docs : [Select Id, FileType, Title, FileExtension from ContentDocument where Id= :docLinks.ContentDocumentId and Title like '%response%' ]) {
                   for (ContentVersion docVersion : [Select Id, VersionData from ContentVersion where ContentDocumentId =:docLinks.ContentDocumentId ]) {
        
                       Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        
                       string fileName = docs.Title.Trim() + '.' + docs.FileExtension.Trim();
                       efa.setFileName(fileName); 
                       efa.setBody(docVersion.VersionData); 
                       fileAttachments.add(efa);
                   }
               }
            }
            email.setFileAttachments(fileAttachments);
            
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                return System.Label.Email_Sent_Success_Message;
            }
            catch(exception e) {
                return System.Label.License_File_Email_Error_Message;
            }
        }
        return System.Label.License_File_Email_Error_Message;
    }
}