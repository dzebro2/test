@isTest public class MockDAOs {

    public class ProductDAOMock implements ProductDAO.IProductDAO {
        private fflib_ApexMocks mocks;

        public ProductDAOMock(fflib_ApexMocks mocks) {
            this.mocks = mocks;
        }

        public List<Product2> getSimpleProducts(String HCSCDivison, List<String> prodNames) {

            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getSimpleProducts', new List<Object> {HCSCDivison, prodNames});
            } else {
                mocks.recordMethod(this, 'getSimpleProducts', new List<Object> {HCSCDivison, prodNames});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'getSimpleProducts', new List<Object> {HCSCDivison, prodNames});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (List<Product2>) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }
    }

    public class UserDAOMock implements UserDAO.IUserDAO {
        private fflib_ApexMocks mocks;

        public UserDAOMock(fflib_ApexMocks mocks) {
            this.mocks = mocks;
        }

        public UserRecordAccess getUserEditAccess(Id userId, Id recordId) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getUserEditAccess', new List<Object> {userId, recordId});
                return null;
            } else {
                mocks.recordMethod(this, 'getUserEditAccess', new List<Object> {userId, recordId});
                fflib_MethodReturnValue methodReturnValue = mocks.getMethodReturnValue(this, 'getUserEditAccess', new List<Object> {userId, recordId});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceOf Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (UserRecordAccess) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }

        public User createUser(Id profileId, String username, String lastName, String email) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'createUser', new List<Object> {profileId, username, lastname, email});
                return null;
            } else {
                mocks.recordMethod(this, 'createUser', new List<Object> {profileId, username, lastname, email});
                fflib_MethodReturnValue methodReturnValue = mocks.getMethodReturnValue(this, 'createUser', new List<Object> {profileId, username, lastname, email});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceOf Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (User) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }

        public Id getUserIdByProfileName(String name) {

            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getUserIdByProfileName', new List<Object> {name});
                return null;
            } else {
                mocks.recordMethod(this, 'getUserIdByProfileName', new List<Object> {name});
                fflib_MethodReturnValue methodReturnValue = mocks.getMethodReturnValue(this, 'getUserIdByProfileName', new List<Object> {name});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceOf Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (Id) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }

        public List<User> getUsersWithEmployeeNumber(Set<String> userIds) {

            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getUsersWithEmployeeNumber', new List<Object> {userIds});
                return null;
            } else {
                mocks.recordMethod(this, 'getUsersWithEmployeeNumber', new List<Object> {userIds});
                fflib_MethodReturnValue methodReturnValue = mocks.getMethodReturnValue(this, 'getUsersWithEmployeeNumber', new List<Object> {userIds});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceOf Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (List<User>) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }
    }

    public class BenefitAgreementDAOMock implements BenefitAgreementDAO.IBenefitAgreementDAO {

        private fflib_ApexMocks mocks;

        public BenefitAgreementDAOMock (fflib_ApexMocks mocks) {
            this.mocks = mocks;
        }

        public List<Benefit_Agreement__c> getBatchBenefitAgreements(Set<Id> accountIds) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getBatchBenefitAgreements', new List<Object> {accountIds});
            } else {
                mocks.recordMethod(this, 'getBatchBenefitAgreements', new List<Object> {accountIds});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'getBatchBenefitAgreements', new List<Object> {accountIds});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (List<Benefit_Agreement__c>) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }

        public List<Benefit_Agreement__c> getGroupAccountBenefitAgreements(List<Account> groupAccounts) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getGroupAccountBenefitAgreements', new List<Object> {groupAccounts});
            } else {
                mocks.recordMethod(this, 'getGroupAccountBenefitAgreements', new List<Object> {groupAccounts});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'getGroupAccountBenefitAgreements', new List<Object> {groupAccounts});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (List<Benefit_Agreement__c>) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }

        public List<Benefit_Agreement__c> getBenefitAgreementsForAddOpProds(Id accountId) {

            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getBenefitAgreementsForAddOpProds', new List<Object> {accountId});
            } else {
                mocks.recordMethod(this, 'getBenefitAgreementsForAddOpProds', new List<Object> {accountId});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'getBenefitAgreementsForAddOpProds', new List<Object> {accountId});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (List<Benefit_Agreement__c>) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }
    }

    public class OpportunityDAOMock implements OpportunityDAO.IOpportunityDAO {
        private fflib_ApexMocks mocks;

        public OpportunityDAOMock (fflib_ApexMocks mocks) {
            this.mocks = mocks;
        }

        public Opportunity getOpportunityById(Id opportunityId) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getOpportunityById', new List<Object> {opportunityId});
                return null;
            } else {
                mocks.recordMethod(this, 'getOpportunityById', new List<Object> {opportunityId});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'getOpportunityById', new List<Object> {opportunityId});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (Opportunity) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }

        public void updateOpportunity(Opportunity opportunityObj) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'updateOpportunity', new List<Object> {opportunityObj});
            } else {
                mocks.recordMethod(this, 'updateOpportunity', new List<Object> {opportunityObj});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'updateOpportunity', new List<Object> {opportunityObj});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                }
            }
        }

        public void updateOpportunities(List<Opportunity> opportunityObjs) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'updateOpportunities', new List<Object> {opportunityObjs});
            } else {
                mocks.recordMethod(this, 'updateOpportunities', new List<Object> {opportunityObjs});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'updateOpportunities', new List<Object> {opportunityObjs});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                }
            }
        }

        public List<Opportunity> getOpportunitiesForProduct360(Set<Id> opportunityIds) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getOpportunitiesForProduct360', new List<Object> {opportunityIds});
            } else {
                mocks.recordMethod(this, 'getOpportunitiesForProduct360', new List<Object> {opportunityIds});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'getOpportunitiesForProduct360', new List<Object> {opportunityIds});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (List<Opportunity>) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }

    }

    public class OpportunityProductDAOMock implements OpportunityProductDAO.IOpportunityProductDAO {
        private fflib_ApexMocks mocks;

        public OpportunityProductDAOMock (fflib_ApexMocks mocks) {
            this.mocks = mocks;
        }

        public List<Opportunity_Product__c> getLostProducts(List<String> lostProductIds) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getLostProducts', new List<Object> {lostProductIds});
                return null;
            } else {
                mocks.recordMethod(this, 'getLostProducts', new List<Object> {lostProductIds});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'getLostProducts', new List<Object> {lostProductIds});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (List<Opportunity_Product__c>) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }

        public List<Opportunity_Product__c> getSelectedProducts(List<String> selectedProductIds) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getSelectedProducts', new List<Object> {selectedProductIds});
                return null;
            } else {
                mocks.recordMethod(this, 'getSelectedProducts', new List<Object> {selectedProductIds});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'getSelectedProducts', new List<Object> {selectedProductIds});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (List<Opportunity_Product__c>) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }

        public void updateOpportunityProducts(List<Opportunity_Product__c> opProducts) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'updateOpportunityProducts', new List<Object> {opProducts});
            } else {
                mocks.recordMethod(this, 'updateOpportunityProducts', new List<Object> {opProducts});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'updateOpportunityProducts', new List<Object> {opProducts});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                }
            }
        }

        public Opportunity_Product__c getOpportunityProductById(Id opProduct) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getOpportunityProductById', new List<Object> {opProduct});
            } else {
                mocks.recordMethod(this, 'getOpportunityProductById', new List<Object> {opProduct});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'getOpportunityProductById', new List<Object> {opProduct});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (Opportunity_Product__c) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }

        public void deleteOpportunityProduct(Opportunity_Product__c opProduct) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'deleteOpportunityProduct', new List<Object> {opProduct});
            } else {
                mocks.recordMethod(this, 'deleteOpportunityProduct', new List<Object> {opProduct});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'deleteOpportunityProduct', new List<Object> {opProduct});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                }
            }
        }

        public void upsertOpportunityProducts(List<Opportunity_Product__c> opProducts) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'upsertOpportunityProducts', new List<Object> {opProducts});
            } else {
                mocks.recordMethod(this, 'upsertOpportunityProducts', new List<Object> {opProducts});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'upsertOpportunityProducts', new List<Object> {opProducts});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                }
            }
        }

        public List<Opportunity_Product__c> getLostProductsForAddOpProds(List<Opportunity_Product__c> lostProductIds) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getLostProductsForAddOpProds', new List<Object> {lostProductIds});
                return null;
            } else {
                mocks.recordMethod(this, 'getLostProductsForAddOpProds', new List<Object> {lostProductIds});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'getLostProductsForAddOpProds', new List<Object> {lostProductIds});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (List<Opportunity_Product__c>) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }

        public List<Opportunity_Product__c> getExistingOpProducts(List<Schema.FieldSetMember> fields) {
            if (mocks.Stubbing) {
                mocks.prepareMethodReturnValue(this, 'getExistingOpProducts', new List<Object> {fields});
                return null;
            } else {
                mocks.recordMethod(this, 'getExistingOpProducts', new List<Object> {fields});
                fflib_MethodReturnValue methodReturnValue =
                    mocks.getMethodReturnValue(this, 'getExistingOpProducts', new List<Object> {fields});
                if (methodReturnValue != null) {
                    if (methodReturnValue.ReturnValue instanceof Exception) {
                        throw ((Exception) methodReturnValue.ReturnValue);
                    }
                    return (List<Opportunity_Product__c>) methodReturnValue.ReturnValue;
                }
            }
            return null;
        }
    }
}