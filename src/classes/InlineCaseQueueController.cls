public with sharing class InlineCaseQueueController {

    Private Final Case c;
    public String caseID { get; Set; }
    public String selectedQueue { get; Set; }
    Public List<SelectOption> projectOptions { get; set; }

    public InlineCaseQueueController(ApexPages.StandardController standardController) {
        this.c = (Case) standardController.getRecord();
    }

    public List<SelectOption> getOptions() {
        if (c.RecordTypeID == '01233000000QMOx') {
            List<SelectOption> options = new List<SelectOption> ();
            for (QueueSobject q :[Select Id, q.Queue.Name, q.Queue.ID from QueueSobject q
                 WHERE q.Queue.Name LIKE '%LGNA%']) {
                options.add(new SelectOption(q.Queue.ID, q.Queue.Name));
                selectedQueue = q.Queue.ID;
            }
            return options;
        }
        return null;
    }
   public List<SelectOption> getCaseQueue() {
        if (c.RecordType.Name == 'LGNA - General Case') {
            List<SelectOption> options = new List<SelectOption> ();
            List<CaseQueue__c> tempList = new List<CaseQueue__c> ();
            CaseQueue__c cq = CaseQueue__c.getInstance('Underwriting');

            System.debug(templist);
            return options;
        }
        return null;
    }

    public PageReference assignQueue() {
        c.OwnerID = selectedQueue;
        update c;

        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;

    }

}