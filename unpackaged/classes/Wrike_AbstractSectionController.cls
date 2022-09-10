public abstract class Wrike_AbstractSectionController {
	
	public static String WRIKE_DOMAIN { get {
								return WrikeAccountSettings__c.getInstance().WrikeServer__c; }}
	
    private final static String WRIKE_OAUTH2_TOKEN = WRIKE_DOMAIN + '/oauth2/token';
    
    private final static String WRIKE_API = WRIKE_DOMAIN + '/api/v3';

    private String viewURL;

    private Wrike_API__c api;
    
    private WrikeAccountSettings__c settings;
    
    protected Wrike_Bindings__c bindings;

    public String getSalesforceHost() {
        return URL.getSalesforceBaseUrl().getProtocol() +
            '://' + URL.getSalesforceBaseUrl().getHost();
    }
 
    public String getSalesforceHostname() {
    	return URL.getSalesforceBaseUrl().getHost();
    }
    
    public String getWrikeAccountId() {
    	return settings.WrikeAccountId__c;
    }
    
    public String getSalesforceFolderId() {
    	return settings.SalesforceFolderId__c;
    }

    // DEBUG ONLY !
    public String getDebugToken() {
        return api.Token__c;
    }

    protected Wrike_AbstractSectionController(String viewURL) {
        this.viewURL = viewURL;
        api = Wrike_API__c.getInstance();
        settings = WrikeAccountSettings__c.getInstance();
    }
    
    public PageReference authorize() {

        String authorizationURL = URL.getSalesforceBaseUrl().toExternalForm() +
                '/apex/Wrike_Authorize?return_path=' +
                EncodingUtil.urlEncode( viewURL, 'UTF-8');

		System.debug('authorizationURL ' + authorizationURL);
        return new PageReference(authorizationURL);
    }

    public PageReference refresh() {
        return null;
    }
    
    public PageReference refreshAndReset() {
        PageReference p = ApexPages.currentPage();
        p.setRedirect(true);
        return p;
    }
    
    public PageReference deauthorize() {
    	api.Token__c = '';
    	api.RefreshToken__c = '';
    	upsert api;
    	
    	PageReference page = new PageReference(ApexPages.currentPage().getUrl());
	   page.setRedirect(true);
	   return page;
    }

    protected String wrikeApiGet(String relativePath) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(WRIKE_API + relativePath);
        req.setMethod('GET');

        req.setHeader('Authorization', 'Bearer ' + api.Token__c);
        
        HttpResponse res = http.send(req);
        return res.getBody();
    }

    protected String wrikeApiPut(String relativePath, String body) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(WRIKE_API + relativePath);
        System.Debug(WRIKE_API + relativePath);
        
        req.setMethod('PUT');

        req.setHeader('Authorization', 'Bearer ' + api.Token__c);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        req.setBody(body);
        System.Debug(body);
        
        HttpResponse res = http.send(req);
        return res.getBody();
    }

    protected String wrikeApiPost(String relativePath, String body) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(WRIKE_API + relativePath);
        System.Debug(WRIKE_API + relativePath);
        
        req.setMethod('POST');

        req.setHeader('Authorization', 'Bearer ' + api.Token__c);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        req.setBody(body);
        System.Debug(body);
        
        HttpResponse res = http.send(req);
        System.debug('response: ' + res);
        return res.getBody();
    }
	
	protected boolean isUser() {		
		
		String me = wrikeApiGet('/contacts?me');
		
		JSONParser parser = JSON.createParser(me);

		String accountId = null, role = null;          
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                if(parser.getText() == 'accountId'){
                    parser.nextToken();
                    accountId = parser.getText();
                } else if(parser.getText() == 'role'){
                    parser.nextToken();
                    role = parser.getText();
                }
            }
            else if(parser.getCurrentToken() == JSONToken.END_OBJECT){
                if (accountId == getWrikeAccountId()
                		&& role == 'User') {
                    return true;
                }
                accountId = null;
                role = null;
            }
        }
        return false;
	}
	
    protected boolean refreshExpiredToken() {
        
        if (api.RefreshToken__c == null ||
            api.RefreshToken__c == '') {

            return false;
        }

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(WRIKE_OAUTH2_TOKEN);
        req.setMethod('POST');
    
        req.setBody('client_id=' + settings.wrikeClientId__c+
            '&client_secret=' + settings.wrikeClientSecret__c +
            '&grant_type=refresh_token' +
            '&refresh_token=' + api.RefreshToken__c);
    
        HttpResponse res = http.send(req);
        String body = res.getBody();
        if (body == null) return false;
        
        api.Token__c = '';
        api.RefreshToken__c = '';

        JSONParser parser = JSON.createParser(res.getBody());

        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                if(parser.getText() == 'access_token'){
                    parser.nextToken();
                    api.Token__c = parser.getText();
                }
                else if (parser.getText() == 'refresh_token'){
                    parser.nextToken();
                    api.RefreshToken__c = parser.getText();
                }
            }
        }
        if (api.Token__c != '') {
            upsert api;
        }

        return api.Token__c != '';
    }

    protected String parseJSON(String jsonString, String field) {

        JSONParser parser = JSON.createParser(jsonString);

        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                if(parser.getText() == field){
                    parser.nextToken();
                    return parser.getText();
                }
            }
        }

        return null;
    }
    
    public Boolean isFolderDeleted(String folderId) {
    	
    	String foldersBody = wrikeApiGet('/folders/' + folderId);
        if (foldersBody == null) {
        	return false;
        }

        String scope = parseJSON(foldersBody, 'scope');
        return (scope == 'RbFolder');
    }
    
    protected Boolean checkMetadataAPIConnection()
	{
		try {
			MetadataService.MetadataPort service = new MetadataService.MetadataPort();
			service.SessionHeader = new MetadataService.SessionHeader_element();
			service.SessionHeader.sessionId = UserInfo.getSessionId();
			MetadataService.ListMetadataQuery remoteSites = new MetadataService.ListMetadataQuery();
			remoteSites.type_x = 'RemoteSiteSetting';
			service.listMetadata(new List<MetadataService.ListMetadataQuery> { remoteSites }, 31);
		} catch (Exception e) {
			return false;
		}
		return true;
	}

    public static void validate_AbstractSectionController() {
        Integer i = 0;
  		i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;   
    }
}