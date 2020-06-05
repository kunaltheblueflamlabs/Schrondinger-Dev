/**
 * Created by rohit on 10/1/18.
 */

public with sharing class LicenseGenerationController {


    public LicenseGenerationResponse generateLicense(LicenseGenerationRequest licenseGenerationRequest) {
        LicenseGenerationService service = new LicenseGenerationService();
        LicenseGenerationResponse licenseGenerationResponse = service.getResponse(licenseGenerationRequest);
        return licenseGenerationResponse;
    }

    public static string main(string requestContent) {
        LicenseGenerationController controller = new LicenseGenerationController();
        LicenseGenerationRequest request = new LicenseGenerationRequest();
        //test
        request.request_type = 'encryption';
        request.token = 'f6Ee5ikU7MHYjBLhyDJzEzfU8fz85EQa53d06b6f74f86228b3580ef6f'; //'2d911ede57f11779b13882962f8fe82765aa73f6';
        request.sign_only = 'false';
        request.signature = 'true';
        //request.file_contents = requestContent;
        request.file_contents = '#License Request Code: #95769-E-8854\n#Customer Name: Kortrey Test Company\n[SetLevelSpecs]\n\tStartDate = 28-Sep-2018\n\tExpirationDate = 28-Oct-2018\n\tRelease = 2018-3\n\tScope = 0050569f39d2\n#FlexLM Product:\n[AutoQSAR]\n\tVersion = 999\n#FlexLM Product:\n[Canvas]\n\tVersion = 999\n#FlexLM Product:\n[ConfGen]\n\tVersion = 999\n#FlexLM Product:\n[Core_Hopping]\n\tVersion = 999\n#FlexLM Product:\n[Desmond]\n\tVersion = 999\n#FlexLM Product:\n[Epik]\n\tVersion = 999\n#FlexLM Product:\n[Field-based_QSAR]\n\tVersion = 999\n#FlexLM Product:\n[Glide]\n\tVersion = 999\n#FlexLM Product:\n[Jaguar]\n\tVersion = 999\n#FlexLM Product:\n[Jaguar_pKa]\n\tVersion = 999\n#FlexLM Product:\n[KNIME]\n\tVersion = 999\n#FlexLM Product:\n[LigPrep]\n\tVersion = 999\n#FlexLM Product:\n[MacroModel]\n\tVersion = 999\n#FlexLM Product:\n[Membrane_Permeability]\n\tVersion = 999\n#FlexLM Product:\n[Minta]\n\tVersion = 999\n#FlexLM Product:\n[OPLS3_Force_Field]\n\tVersion = 999\n#FlexLM Product:\n[P450_SOM_Prediction]\n\tVersion = 999\n#FlexLM Product:\n[Phase]\n\tVersion = 999\n#FlexLM Product:\n[Prime]\n\tVersion = 999\n#FlexLM Product:\n[PrimeX]\n\tVersion = 999\n#FlexLM Product:\n[QikProp]\n\tVersion = 999\n#FlexLM Product:\n[QSite]\n\tVersion = 999\n#FlexLM Product:\n[Shape_Screening]\n\tVersion = 999\n#FlexLM Product:\n[SiteMap]\n\tVersion = 999\n#FlexLM Product:\n[Strike]\n\tVersion = 999\n#FlexLM Product:\n[XP_Visualizer]\n\tVersion = 999\n#FlexLM Product:\n[Maestro-Access]\n\tVersion = 999\n';
        LicenseGenerationResponse licenseGenerationResponse = controller.generateLicense(request);
        System.debug('response = ' + licenseGenerationResponse.file_contents);
        return licenseGenerationResponse.file_contents;
    }
}