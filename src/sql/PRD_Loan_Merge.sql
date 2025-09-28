merge into prod."Loan" as target
using staging."Loan_Detail_vw" as source
	on    target."AccountId"     = source."AccountId"
	--and		target."ApplicationId" = source."ApplicationId"
when not matched then 
	insert ("OpenMonth"                     
				,"AccountId"                     
				,"ApplicationId"                 
				,"OpenDate"                      
				,"IdNum"                         
				,"Consultant"                    
				,"AgeInMonths"                   
				,"NumOfInstalments"              
				,"AccountType"                   
				,"PaymentFrequency"              
				,"Loan_Size"                     
				,"Loan_Term"                     
				,"HandedOver"                    
				,"FirstDueDate_Missed_Flag"      
				,"FirstInstalment_Default_Flag"  
				,"One_ever_3_Flag"               
				,"Two_ever_6_Flag"               
				,"BureauScore"                   
				,"ApplicationScore"              
				,"BranchName"                    
				,"Debtors_Bank"                  
				,"Product"                       
				,"ROLLd_Loan"                    
				,"CDE_Override"                  
				,"Bureau")
values (	source."OpenMonth"                     
			,source."AccountId"                     
			,source."ApplicationId"                 
			,source."OpenDate"                      
			,source."IdNum"                         
			,source."Consultant"                    
			,source."AgeInMonths"                   
			,source."NumOfInstalments"              
			,source."AccountType"                   
			,source."PaymentFrequency"              
			,source."Loan_Size"                     
			,source."Loan_Term"                     
			,source."HandedOver"                    
			,source."FirstDueDate_Missed_Flag"      
			,source."FirstInstalment_Default_Flag"  
			,source."One_ever_3_Flag"               
			,source."Two_ever_6_Flag"               
			,source."BureauScore"                   
			,source."ApplicationScore"              
			,source."BranchName"                    
			,source."Debtors_Bank"                  
			,source."Product"                       
			,source."ROLLd_Loan"                    
			,source."CDE_Override"                  
			,source."Bureau")
when matched then update set
		 		"OpenMonth"                     = source."OpenMonth"                    
			, "AccountId"                     = source."AccountId"                    
			, "ApplicationId"                 = source."ApplicationId"                
			, "OpenDate"                      = source."OpenDate"                     
			, "IdNum"                         = source."IdNum"                        
			, "Consultant"                    = source."Consultant"                   
			, "AgeInMonths"                   = source."AgeInMonths"                  
			, "NumOfInstalments"              = source."NumOfInstalments"             
			, "AccountType"                   = source."AccountType"                  
			, "PaymentFrequency"              = source."PaymentFrequency"             
			, "Loan_Size"                     = source."Loan_Size"                    
			, "Loan_Term"                     = source."Loan_Term"                    
			, "HandedOver"                    = source."HandedOver"                   
			, "FirstDueDate_Missed_Flag"      = source."FirstDueDate_Missed_Flag"     
			, "FirstInstalment_Default_Flag"  = source."FirstInstalment_Default_Flag" 
			, "One_ever_3_Flag"               = source."One_ever_3_Flag"              
			, "Two_ever_6_Flag"               = source."Two_ever_6_Flag"              
			, "BureauScore"                   = source."BureauScore"                  
			, "ApplicationScore"              = source."ApplicationScore"             
			, "BranchName"                    = source."BranchName"                   /Users/johan/Workspace/Matogen/Atlas/src/python/Staging_ACC_Account.py
			, "Debtors_Bank"                  = source."Debtors_Bank"                 
			, "Product"                       = source."Product"                      
			, "ROLLd_Loan"                    = source."ROLLd_Loan"                   
			, "CDE_Override"                  = source."CDE_Override"                 
			, "Bureau"                        = source."Bureau"                      
			;


select * from pg_tables
where schemaname = 'staging';

CREATE OR REPLACE PROCEDURE staging.truncate_stg_tables()
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT  tablename
        FROM    pg_tables
        WHERE   schemaname = 'staging'
    LOOP
				RAISE NOTICE 'Truncating table: %', r.tablename;
        EXECUTE 'TRUNCATE TABLE staging.' || quote_ident(r.tablename) || ' CASCADE;';
    END LOOP;
END;
$$;

CALL truncate_stg_tables();



