public with sharing class Utility {
	
 public static  Map<Integer, String> ConstantMap =getConstantValues();
 
 private static Map<Integer, String> getConstantValues(){
 	
 	// Return Value
    Map<Integer, String> tempMap = new Map<Integer, String>(); 
    
    // Fetch values from Custom Setting - SG_Constants__c
    for (SG_Constants__c consObj : SG_Constants__c.getAll().values()) {
      tempMap.put(Integer.valueOf(consObj.Name), consObj.Constant_Values__c);
    }
  
    // return tempMap
    return tempMap;
 }
  
}