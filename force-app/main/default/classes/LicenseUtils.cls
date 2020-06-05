/**
 * Created by rohit on 10/9/18.
 */

public with sharing class LicenseUtils {


    public static String formatDate(Date d, String format) {
        Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
        return dt.format(format);
    }
}