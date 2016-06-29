public with sharing class RFPRequestEligibilityExtension {
	public Case caseObj{get;set;}
	public boolean showEditMode{get;set;}
	public boolean medicalRecordType{get;set;}
	public string pageBlockTitle{get;set;}
	public RFPRequestEligibilityExtension(ApexPages.StandardController controller){
		try{
			caseObj = (Case)controller.getRecord();
			caseObj = [select Id,COBRA__c,recordType.Name,Waive_on_Initial_Enrollment__c,DHMO_Current_Participation__c,HMO_Current_Participation__c,STD_Current_Participation__c,Life_Current_Participation__c,HCSC_Division__c,Percent_Enrolled__c,
						Total_on_Payroll__c,HMO__c,Non_HMO__c,Retirees__c,Part_Time__c,Waiting_Period__c,Total_Eligible_For_Health__c,Dental_Current_Participation__c,Life_days__c,STD_days__c,Dental_days__c,
						Covered_ElseWhere__c,Total_Eligible__c,Waiving_Not_Covered_ElseWhere__c,Total_Covered__c,Total_Eligible_for_Dental__c,
						Health__c,Claim_Exceeded_Amt_Past__c,Claim_Exceeded_Amt_Future__c,Participants_Disabled__c,
						Participants_Diagonsed_Risk_Condition_Hi__c from Case where Id =: caseObj.Id];
			//get the User access record to check whether edit right present or not
			UserRecordAccess ru = [	SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :caseObj.Id];
			showEditMode = ru.HasEditAccess;
			medicalRecordType = false;
			pageBlockTitle = 'Dental Eligibility';
			if(caseObj.recordType.Name == 'Underwriting'){
				medicalRecordType = true;
				pageBlockTitle = 'Health Eligibility';
			}
		}catch(Exception e){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
		}
	} 
	
	public void saveRecord(){
		try{
			if(medicalRecordType){
				caseObj.Total_Eligible_For_Health__c =((caseObj.Total_on_Payroll__c != null ? caseObj.Total_on_Payroll__c : 0) +  (caseObj.COBRA__c != null ? caseObj.COBRA__c : 0) + (caseObj.Retirees__c != null ? caseObj.Retirees__c : 0) - (caseObj.Part_Time__c != null ? caseObj.Part_Time__c: 0) - (caseObj.Waiting_Period__c != null ? caseObj.Waiting_Period__c : 0));
				if(caseObj.Total_Eligible_For_Health__c <0)
					caseObj.Total_Eligible_For_Health__c = 0;
				
				caseObj.Total_Eligible__c = caseObj.Total_Eligible_For_Health__c - (caseObj.Covered_ElseWhere__c != null ?caseObj.Covered_ElseWhere__c : 0);
			}
			else{
				caseObj.Total_Eligible_for_Dental__c =((caseObj.Total_on_Payroll__c != null ? caseObj.Total_on_Payroll__c : 0) +  (caseObj.COBRA__c != null ? caseObj.COBRA__c : 0) + (caseObj.Retirees__c != null ? caseObj.Retirees__c : 0) - (caseObj.Part_Time__c != null ? caseObj.Part_Time__c: 0) - (caseObj.Waiting_Period__c != null ? caseObj.Waiting_Period__c : 0));
				if(caseObj.Total_Eligible_for_Dental__c <0)
					caseObj.Total_Eligible_for_Dental__c = 0;
				
				caseObj.Total_Eligible__c = caseObj.Total_Eligible_for_Dental__c - (caseObj.Covered_ElseWhere__c != null ?caseObj.Covered_ElseWhere__c : 0);
			
			}
			if(caseObj.Total_Eligible__c <0)
				caseObj.Total_Eligible__c = 0;
			caseObj.Total_Covered__c = caseObj.Total_Eligible__c - (caseObj.Waiving_Not_Covered_ElseWhere__c != null ? caseObj.Waiving_Not_Covered_ElseWhere__c : 0);
			if(caseObj.Total_Covered__c < 0)
				caseObj.Total_Covered__c = 0;
			if(caseObj.Total_Eligible__c != 0)
				caseObj.Percent_Enrolled__c = caseObj.Total_Covered__c/caseObj.Total_Eligible__c*100;
			/*if(caseObj.Percent_Enrolled__c < 75){
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Percent Enrolled cannot be less than 75%');
            	ApexPages.addMessage(myMsg);
			}
			else*/
				update caseObj;
		}catch(Exception e){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
		}
	}
	public void CancelRecord(){
		try{
			caseObj = [select Id,COBRA__c,Waive_on_Initial_Enrollment__c,HMO_Current_Participation__c,STD_Current_Participation__c,Life_Current_Participation__c,HCSC_Division__c,Percent_Enrolled__c,
						Total_on_Payroll__c,HMO__c,Non_HMO__c,Retirees__c,Part_Time__c,Waiting_Period__c,Total_Eligible_For_Health__c,Dental_Current_Participation__c,Life_days__c,STD_days__c,Dental_days__c,
						Covered_ElseWhere__c,Total_Eligible__c,Waiving_Not_Covered_ElseWhere__c,Total_Covered__c,
						Health__c,Claim_Exceeded_Amt_Past__c,Claim_Exceeded_Amt_Future__c,Participants_Disabled__c,
						Participants_Diagonsed_Risk_Condition_Hi__c from Case where Id =: caseObj.Id];
		}catch(Exception e){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
		}
	}
}