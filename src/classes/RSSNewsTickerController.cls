global with sharing class RSSNewsTickerController {

    public Id accountId;
    public String query;
    public String profileName;
    public String accountName {get; set;}
    public String industry {get; set;}
    public boolean useFeedAPI{get;set;}
    public String hcscState {get; set;}
    public String selectedExternalFilters 
    {
        get
        {
            if(selectedExternalFilters == null)
                selectedExternalFilters = 'Account';
                
            return selectedExternalFilters;
        }
        set;
    }
    
    public List<SelectOption> getExternalFilters() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Account','Account'));
        options.add(new SelectOption('Industry','Industry'));
        //options.add(new SelectOption('HCSC State','HCSC State'));
        options.add(new SelectOption('All','All'));
        return options;
    }
    @RemoteAction
    global static string getRSSData(string feedURL,String isMobile) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(feedURL);
        req.setMethod('GET');
         String category = '';
         String innerHTML = '';
        Dom.Document doc = new Dom.Document();
        Http h = new Http();
         
        if (!Test.isRunningTest()){ 
            HttpResponse res = h.send(req);
            doc = res.getBodyDocument();
        } else {
            String xmlString = '<?xml version="1.0" encoding="utf-8" ?><rss version="2.0" xmlns:os="http://a9.com/-/spec/opensearch/1.1/"><channel><title>salesforce.com - Bing News</title><link>http://www.bing.com/news</link><description>Search Results for salesforce.com at Bing.com</description><category>News</category><os:totalResults>3370</os:totalResults><os:startIndex>0</os:startIndex><os:itemsPerPage>10</os:itemsPerPage><os:Query role="request" searchTerms="salesforce.com" /><copyright>These XML results may not be used, reproduced or transmitted in any manner or for any purpose other than rendering Bing results within an RSS aggregator for your personal, non-commercial use. Any other use requires written permission from Microsoft Corporation. By using these results in any manner whatsoever, you agree to be bound by the foregoing restrictions.</copyright><image><url>http://www.bing.com/s/a/rsslogo.gif</url><title>Bing</title><link>http://www.bing.com/news</link></image><docs>http://www.rssboard.org/rss-specification</docs><item><title>Salesforce.com Makes Friends With CIOs - Information Week</title><guid>http://informationweek.com/news/cloud-computing/software/232602782</guid><link>http://informationweek.com/news/cloud-computing/software/232602782</link><description>Parade of CIOs at CloudForce shows how social networking inroads are making Salesforce.com a larger part of the IT infrastructure. Salesforce.com isn&apos;t just for sales forces anymore. Its Chatter app has opened a social networking avenue into the enterprise ...</description><pubDate>Wed, 12 Jan 2015 11:11:11 GMT</pubDate><source>Information Week</source></item></channel></rss>';
            doc.load(xmlString);
        }
         
        Dom.XMLNode rss = doc.getRootElement();
        //first child element of rss feed is always channel
        Dom.XMLNode channel = rss.getChildElements()[0];
         
        RSSReader.channel result = new RSSReader.channel();
         
        list<RSSReader.item> rssItems = new list<RSSReader.item>();
         
        //for each node inside channel
        for(Dom.XMLNode elements : channel.getChildElements()) {
            
            
            if('title' == elements.getName()) {
                result.title = elements.getText();
                
            }
            if('link' == elements.getName()) {
                result.link = elements.getText();
            }
            if('description' == elements.getName()) {
                result.description = elements.getText();
                
            }
            if('category' == elements.getName()) {
                result.category = elements.getText();
            }
            if('copyright' == elements.getName()) {
                result.copyright = elements.getText();
            }
            if('docs' == elements.getName()) {
                result.docs = elements.getText();
            }
            if('image' == elements.getName()) {
                RSSReader.image img = new RSSReader.image();
                //for each node inside image
                for(Dom.XMLNode xmlImage : elements.getChildElements()) {
                    if('url' == xmlImage.getName()) {
                        img.url = xmlImage.getText();
                    }
                    if('title' == xmlImage.getName()) {
                        img.title = xmlImage.getText();
                    }
                    if('link' == xmlImage.getName()) {
                        img.link = xmlImage.getText();
                    }
                    
                }
                result.image = img;
            }
             
            if('item' == elements.getName()) {
                RSSReader.item rssItem = new RSSReader.item();
                //for each node inside item
                
                for(Dom.XMLNode xmlItem : elements.getChildElements()) {
                    if('title' == xmlItem.getName()) {
                        rssItem.title = xmlItem.getText();
                    }
                    if('guid' == xmlItem.getName()) {
                        rssItem.guid = xmlItem.getText();
                    }
                    if('link' == xmlItem.getName()) {
                        rssItem.link = xmlItem.getText();
                    }
                    if('description' == xmlItem.getName()) {
                        rssItem.description = xmlItem.getText();
                    }
                    if('pubDate' == xmlItem.getName()) {
                        rssItem.pubDate = xmlItem.getText();
                    }
                    if('source' == xmlItem.getName()) {
                        rssItem.source = xmlItem.getText();
                    }
                }
                if(isMobile == 'false'){
                    String publishedDate = getThePubilshedDate(rssItem.pubDate);
                    innerHTMl += '<li><div class="itemTitle"><a href="'+rssItem.link+'" target="_blank" >'+rssItem.title+'</a></div><div class="itemDate">'+publishedDate+'</div></li>';
                }else if(isMobile == 'true'){
                    //Integer numberOfDays = system.now - 
                    //system.assert(false,'===='+rssItem.pubDate);  
                    String publishedDate = getThePubilshedDate(rssItem.pubDate);
                    string sourceNewstitle = string.valueOf(rssItem.title).substring(rssItem.title.indexOf('-')+1,rssItem.title.length());
                    innerHTMl +='<li class="slds-list__item makeWhite"> <div class="slds-tile slds-tile--board"> <p class="slds-tile__title"><a href="'+rssItem.link+'">'+rssItem.title+'</a></p><div class="slds-tile__detail"> <p class="slds-text-heading--medium"></p><br/><p class="slds-wrap">'+ rssItem.title+'</p> <div class="slds-tile__detail slds-text-body--small"><p class="slds-truncate">'+ sourceNewstitle+ ' ' +publishedDate +'</p></div></div></div></li>-----';
                    innerHTMl +='<news category="red" url="'+ rssItem.link+'"" date="'+publishedDate+'"><headline>'+rssItem.title+'</headline><detail>'+ rssItem.title+'</detail></news>-----';
                }
                //for each item, add to rssItem list
                rssItems.add(rssItem);
            }
            
             
        }
        String jsonRSSString = JSON.serialize(rssItems);
        //finish RSS.channel object by adding the list of all rss items
        result.items = rssItems;
         system.debug('========='+jsonRSSString+'========='+rssItems);
        return innerHTMl;
         
    }
    private Static String getThePubilshedDate(String tempDate){
        String pubDate = '';
        map<String,Integer> monthMap = new map<String,Integer>{'Jan' => 1,'Feb'=>2,'Mar'=>3,'Apr'=>4,'May'=>5,'Jun'=>6,'Jul'=>7,'Aug'=>8,'Sep'=>9,'Oct'=>10,'Nov'=>11,'Dec'=>12};
        String tempvar = tempDate.split(',')[1];
        //Datetime myDate = Datetime.newInstance(2008, 12, 1, 12, 30, 2);
        
        Date myDate = Date.newInstance(integer.valueOf(tempvar.split(' ')[3]),monthMap.get(tempvar.split(' ')[2]),integer.valueOf(tempvar.split(' ')[1]));    
        //system.assert(false,'======='+myDate);
        Integer numberOfDays = myDate.daysBetween(date.today());
        if(numberOfDays == 0)
            return 'Today';
        else 
            return numberOfDays+' days ago';
    }
    public RSSNewsTickerController(ApexPages.standardController stController) {
        try{
            useFeedAPI = false;
            for(LGNA_Constants__c cons : LGNA_Constants__c.getAll().values()){
                if(cons.name == 'Default')
                    useFeedAPI = cons.Use_Feed_Api__c;
            }
            accountId = ApexPages.currentPage().getParameters().get('id');
            Account accountObj = [SELECT Name, Industry, HCSC_Division__c FROM Account WHERE Id=:accountId];
            accountName = accountObj.Name;
            industry = accountObj.Industry;
            hcscState = accountObj.HCSC_Division__c;
        }catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'An error occured while loading. Please contact your administrator with this error:' + e.getMessage() + '  ' + e.getStackTraceString() ) );
        }
    }
    
}