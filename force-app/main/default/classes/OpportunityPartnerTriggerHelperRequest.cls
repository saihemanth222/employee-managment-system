public class OpportunityPartnerTriggerHelperRequest {
    
    @future(callout=true)
    public static void callSiteApi(String jsonData, Id partnerId) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Site_API_Endpoint');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(jsonData);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                // Update the opportunity partner record
                Opportunity_Partner__c partner = new Opportunity_Partner__c(
                    Id = partnerId,
                    ActivatedforPCApp__c = true
                );
                update partner;
            }
        } catch (Exception e) {
            // Log error
            ErrorLog__c log = new ErrorLog__c(
                RecordReference__c = partnerId,
                ErrorMessage__c = e.getMessage()
            );
            insert log;
        }
    }
    
    public static void callSingle(Id partnerId) {
        // Get the partner record and validate required fields
        Opportunity_Partner__c partner = [
            SELECT Id, Opportunity__c, Dealer__c, Contractor__c,
                   Opportunity__r.AssignedDealer__r.ShipToBpId__c,
                   Opportunity__r.AssignedDealer__r.DistributionChannelNumber__c,
                   Opportunity__r.AssignedDealer__r.BillingPostalCode,
                   Opportunity__r.AssignedDealer__r.Name
            FROM Opportunity_Partner__c 
            WHERE Id = :partnerId
        ];
        
        // Validate required fields
        if (String.isBlank(partner.Opportunity__r.AssignedDealer__r.ShipToBpId__c) ||
            String.isBlank(partner.Opportunity__r.AssignedDealer__r.DistributionChannelNumber__c) ||
            String.isBlank(partner.Opportunity__r.AssignedDealer__r.BillingPostalCode)) {
            
            // Log skip due to missing fields
            ErrorLog__c log = new ErrorLog__c(
                RecordReference__c = partnerId,
                ErrorMessage__c = 'Skipping API call due to missing required fields'
            );
            insert log;
            return;
        }
        
        // Prepare JSON data
        String jsonData = '{"site_id":"' + partner.Opportunity__r.AssignedDealer__r.ShipToBpId__c + 
                         '","site_name":"' + partner.Opportunity__r.AssignedDealer__r.Name + '"}';
        
        // Call the API asynchronously
        callSiteApi(jsonData, partnerId);
    }
}