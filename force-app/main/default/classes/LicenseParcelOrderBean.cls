/**
 * Created by rohit on 8/22/18.
 */

public with sharing class LicenseParcelOrderBean {

    public License_Event__c licenseEvent {get; private set;}
    public String parcelGroup {get; private set;}
    public String licenseMethod {get; private set;}
    public String licenseSubType {get; private set;}
    public String hostingType {get; private set;}

    public List<OrderItem> orderLines {get; private set;}

    public LicenseParcelOrderBean(License_Event__c licenseEvent, String parcelGroup, String licenseMethod) {
        this.licenseEvent = licenseEvent;
        this.parcelGroup = parcelGroup;
        this.licenseMethod = licenseMethod;

        orderLines = new List<OrderItem>();
    }

    public void addOrderLine(OrderItem orderLine) {
        if (orderLine.LicenseMethod__c != this.licenseMethod) {
            throw new LicenseException('Quote Line cannot be added to this Parcel');
        }
        //validate dates
        if (orderLine.EndDate > licenseEvent.Start_Date__c) {
            this.orderLines.add(orderLine);
            if (String.isEmpty(licenseSubType)) {
                this.licenseSubType = orderLine.LicenseSubType__c;
                this.hostingType = orderLine.HostingType__c;
            }
        }
    }

}