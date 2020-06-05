/**
 * Created by rohit on 8/29/18.
 */

public with sharing class LicenseConstants {

    public static final String LICENSE_METHOD_NONE = 'None';
    public static final String LICENSE_METHOD_FLEX_LM = 'FlexLM';
    public static final String LICENSE_METHOD_Service = 'Service';
    public static final String LICENSE_METHOD_Physical_Shipment = 'Physical Shipment';

    public static final String DEFAULT_LICENSE_STATUS = 'Awaiting Licensing';

    public static final Map<String, String> LICENSE_METHOD_TO_LICENSE_STATUS = new Map<String, String> {
            LICENSE_METHOD_FLEX_LM => 'Awaiting Licensing',
            LICENSE_METHOD_Physical_Shipment => 'Partially Completed'
    };


}