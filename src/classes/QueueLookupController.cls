/**
* @developer: Alec Klein, Al-Que Quiachon/Slalom LLC
* @description: A controller that manages a lookup-imitating page for assigning owners to a case
*               This controller applies to both Queues and Users, despite its name
*
*/

public with sharing class QueueLookupController {

    //Values passed in through the URL using param get methods
    public String searchString {get; set;}
    public String recordType {get; set;}
    public String lookupType {get; set;}
    public String caseId {get; set;}

    //Lists used to store user/group values and display them on the page
    public List<Group> groupResults {get; set;}
    public List<User> userResults {get; set;}

    //Values used for pagination
    //pageSize: The number of results displayed on the page at one time
    //pageNumber: Current page number
    //totalNumberOfRecords: The total number of records from the current query
    //numberOfPages: Number of pages based on totalNumberOfRecords/pageSize
    //currentQuery: Current query used, used for measuring the offset
    public Integer pageSize {get; set;}
    public Integer pageNumber {get; set;}
    public Integer totalNumberOfRecords {get; set;}
    public Integer numberOfPages {get; set;}
	public Boolean isGroup {get;set;}
    public String currentQuery;

    //Messages displayed at the top of the lookup page to let the user know
    //what they're looking at
    public String groupMessage {get; set;}
    public String userPageMessage {get; set;}

    /**
    * @developer: Alec Klein, Al-Que Quiachon/Slalom LLC
    * @description: Controller constructor, initializes parameter variables, messages, and lookup type
    *
    */
    public QueueLookupController() {
        //Assign the param variables, set page size, and set messages
        searchString    = getLookupSearch();
        recordType      = getRecordType();
        lookupType      = getLookupType();
        pageSize = 20;
        groupMessage = 'Available Queues';
        userPageMessage = 'Available Users';
        caseId = ApexPages.CurrentPage().getparameters().get('id');
        //queueOwner = True if the user selected Queue from the dropdown
        //otherwise queueOwner = False, meaning the user selected User
        Boolean queueOwner = (lookupType == 'Queue');
        if (queueOwner) {
            //Populates groupResults, empty userResults
            groupResults = getGroupsByRecordType(recordType);
            userResults = new List<User>();
			isGroup = true;
			if(groupResults.size() == 0)
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 'There are no queues available for this case'));
        } else {
            //Populates userResults with recentlyViewedUsers, empty groupResults
            userResults = getRecentlyViewedUsers();
            groupResults = new List<Group>();
			isGroup = false;
        }
    }

    /**
    * @developer: Alec Klein, Al-Que Quiachon/Slalom LLC
    * @description: Search button connected to visualforce page (QueueLookupPage)
    *
    */
    public PageReference search() {
        runSearch();
        return null;
    }

    /**
    * @developer: Alec Klein, Al-Que Quiachon/Slalom LLC
    * @description: Sets userResults to the user's search results based on their input
    *
    */
    private void runSearch() {
        userResults = performUserSearch(searchString);
    }

    /**
    * @developer: Alec Klein, Al-Que Quiachon/Slalom LLC
    * @description: Performs a user search based on the searchString param
    *
    */
    private List<User> performUserSearch(String searchString) {
        userPageMessage = 'Search Results';
        searchString = '%' + searchString + '%';
        pageNumber = 0;
        //Calculate totalNumberOfRecords and numberOfPages
        totalNumberOfRecords = [SELECT count() FROM User WHERE NAME LIKE :searchString];
        numberOfPages = totalNumberOfRecords / pageSize;
        if (Math.mod(totalNumberOfRecords, pageSize) > 0) {
            numberOfPages++;
        }
        currentQuery = 'SELECT Name, Title, Phone, Email, Id FROM User WHERE Name LIKE \'' + searchString + '\' LIMIT ' + pageSize;
        List<User> userSearch = [SELECT Name, Title, Phone, Email, Id FROM User WHERE
                                 Name LIKE :searchString LIMIT :pageSize];

        if (!(userSearch.size() > 0)) {
            return new List<User>();
        }

        return userSearch;
    }

    /**
    * @developer: Alec Klein, Al-Que Quiachon/Slalom LLC
    * @description: Queries for recentlyViewedUsers for the current logged in User
    *               If the user types something into the lookup field before clicking the lookup button,
    *               the string will be searched instead of displaying recently viewed users
    *
    */
    //Queries for recentlyViewedUsers for the current logged in User
    //If the user types something into the lookup field before clicking the lookup button,
    //It will be searched instead of displaying recently viewed users
    public List<User> getRecentlyViewedUsers() {
        if (searchString == '') {
            userPageMessage = 'Recently Viewed Users';
            pageNumber = 0;
            //Calculate totalNumberOfRecords and numberOfPages
            totalNumberOfRecords = [SELECT count() FROM User WHERE LastViewedDate != NULL];
            numberOfPages = totalNumberOfRecords / pageSize;
            if (Math.mod(totalNumberOfRecords, pageSize) > 0) {
                numberOfPages++;
            }
            currentQuery = 'SELECT Name, Title, Phone, Email, Id FROM User WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT ' + pageSize;
            return (List<User>) [SELECT Name, Title, Phone, Email, Id FROM User
                                 WHERE LastViewedDate != NULL
                                 ORDER BY LastViewedDate DESC LIMIT :pageSize];
        } else {
            return performUserSearch(searchString);
        }
    }

    /**
    * @developer: Alec Klein, Al-Que Quiachon/Slalom LLC
    * @description: Sets the paginated results based on the previous query, increasing offset each time
    *
    */
    public void setPaginatedResults() {
        Integer offset = pageNumber * pageSize;
        String query = currentQuery + ' OFFSET ' + offset;
        try {
            userResults = Database.query(query);
        } catch (Exception e) {
            System.debug('Error Message: ' + e.getMessage());
        }
    }

    /**
    * @developer: Alec Klein, Al-Que Quiachon/Slalom LLC
    * @description: Get groups/queues based on the current case's record type
    *               For valid record type/group mappings, see the Custom Setting 'CaseQueues'
    *
    */
    public List<Group> getGroupsByRecordType(String recordTypeName) {
        List<Group> filteredGroups = new List<Group>();
        List<Case> c = new List<Case>();
        c = [SELECT Group_Exchange_Platform__c FROM Case WHERE Id = :caseId LIMIT 1];
        CaseQueues__c a = CaseQueues__c.getvalues('43');
        CaseQueues__c b = CaseQueues__c.getvalues('44');
        if(recordTypeName == 'Private Exchange'){
 
                if(c[0].Group_Exchange_Platform__c == 'Blue Directions for Large Business'){
                        filteredGroups.add(new Group(Id = a.GroupId__c, Name = a.CaseQueueName__c));
                } else {
                        filteredGroups.add(new Group(Id = b.GroupId__c, Name = b.CaseQueueName__c));
                }              
            } else {
                for (CaseQueues__c cq : CaseQueues__c.getall().values()) {
                    if (cq.RecordTypeName__c == recordTypeName) {
                        filteredGroups.add(new Group(Id = cq.GroupId__c, Name = cq.CaseQueueName__c));              
                    }
                }
            }
        return filteredGroups;
    }

    /**
    * @developer: Alec Klein, Al-Que Quiachon/Slalom LLC
    * @description:
        URL Param getter methods
        ------------------------
        getFormTag - gets form tag, the id of the form on the visualforce page
        getTextBox - gets the name of the form on the visualforce page
        getLookupType - gets the type of the lookup
        getRecordType - gets the record type of the current case
        getLookupSearch - gets the value of the lookup field
    */
    public String getFormTag() {
        return System.currentPageReference().getParameters().get('lkfm');
    }

    public String getTextBox() {
        return System.currentPageReference().getParameters().get('lknm');
    }

    public String getLookupType() {
        String lktp = System.currentPageReference().getParameters().get('lktp');
        if (lktp == 'StandardUserLookup')
            return 'User';
        else if (lktp == 'case_queue')
            return 'Queue';
        else
            return null;
    }

    public String getRecordType() {
        return System.currentPageReference().getParameters().get('rctp');
    }

    public String getLookupSearch() {
        return System.currentPageReference().getParameters().get('lksrch');
    }

    /**
    * @developer: Alec Klein, Al-Que Quiachon/Slalom LLC
    * @description: Increases page number and sets paginated results
    *
    */
    public PageReference next() {
        pageNumber++;
        setPaginatedResults();
        return null;
    }

    /**
    * @developer: Alec Klein, Al-Que Quiachon/Slalom LLC
    * @description: Descreases page number and sets paginated results
    *
    */
    public PageReference previous() {
        pageNumber--;
        setPaginatedResults();
        return null;
    }
}