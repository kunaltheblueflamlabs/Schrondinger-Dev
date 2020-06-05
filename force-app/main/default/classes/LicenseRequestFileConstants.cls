public abstract class LicenseRequestFileConstants {

    public static final String COMMENT = '#';
    public static final String NEW_LINE = '\n';
    public static final String INDENT =  '\t';  //'        ';
    public static final String LICENSE_REQUEST_CODE = 'Test Code';

    public static final String DATE_FORMAT = 'dd-MMM-YYYY';

    public static final Map<String, String> SERVER_INFO = new Map<String, String>{
            'ServerName' => '{SERVERNAME_0}',
            'ServerHostID' => '{SERVERHOSTID_0}',
            'ServerPort' => '{SERVERPORT_0}',
            'RedundantServer2Name' => '{SERVERNAME_1}',
            'RedundantServer2HostID' => '{SERVERHOSTID_1}',
            'RedundantServer2Port' => '{SERVERPORT_1}',
            'RedundantServer3Name' => '{SERVERNAME_2}',
            'RedundantServer3HostID' => '{SERVERHOSTID_2}',
            'RedundantServer3Port' => '{SERVERPORT_2}',
            'SCHRODPort' => '{VENDORPORT}'
    };

    public static final Map<String, String> MERGE_FIELD_VALUES = new Map<String, String>{
            'SERVERNAME_0' => 'Host_ID_MAC_Address_1__c',
            'SERVERHOSTID_0' => 'Machine_Name_1__c',
            'SERVERPORT_0' => 'FLEXlm_Server_Port__c',
            'SERVERNAME_1' => 'Host_ID_MAC_Address_2__c',
            'SERVERHOSTID_1' => 'Machine_Name_2__c',
            'SERVERPORT_1' => 'FLEXlm_Server_Port__c',
            'SERVERNAME_2' => 'Host_ID_MAC_Address_3__c',
            'SERVERHOSTID_2' => 'Machine_Name_1__c',
            'SERVERPORT_2' => 'FLEXlm_Server_Port__c'
    };

    public static final Map<String, String> LEVEL_SPECS = new Map<String, String>{
            'Version' => '999',
            'Release' => '{}',
            'Scope' => 'Open'
    };

}