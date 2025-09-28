create or replace procedure prod."Loan_Detail_From_Staging"()
language plpgsql
as $$
begin
	merge into prod."Loan_Detail" t
	using ( Select 	ld.* 
						,			ld."OpenMonth"::int "OpenMonth_INT"
						,			ld."ApplicationId"::int "ApplicationId_INT"
						,			extract(year from age(now(), ld."OpenDate" )) * 12  + extract(month from age(now(), ld."OpenDate") ) "AgeInMonths"
						,     extract(year from age(ld."FirstArrearDate", ld."OpenDate" )) * 12  + extract(month from age(ld."FirstArrearDate", ld."OpenDate") ) "MonthsFirstArrear"
					from 		staging."Loan_Detail_vw" ld 
				) s
	on    ( t."AccountId"     = S."AccountId"
			and	t."ApplicationId" = S."ApplicationId_INT")
	when  not matched then 
		insert (
				"OpenMonth"                   
			,	"AccountId"                   
			,	"ApplicationId"               
			,	"OpenDate"                    
			,	"IdNum"                       
			,	"Consultant"                  
			,	"AgeInMonths"                 
			,	"NumOfInstalments"            
			,	"AccountType"                 
			,	"PaymentFrequency"            
			,	"Loan_Size"                   
			,	"Loan_Term"                   
			,	"HandedOver"                  
			,	"FirstArrearDate"   
			, "MonthsFirstArrear"          
			,	"FirstDueDate_Missed_Flag"    
			,	"FirstInstalment_Default_Flag"
			,	"One_ever_3_Flag"             
			,	"Two_ever_6_Flag"             
			,	"BureauScore"                 
			,	"ApplicationScore"            
			,	"BranchName"                  
			,	"Debtors_Bank"                
			,	"Product"                     
			,	"ROLLd_Loan"                  
			,	"CDE_Override"                
			,	"Bureau"     
			,	"ClientCategory" 
			,	"ServiceProvider" 
			,	"OverdueStatus"
		)
		values (
				S."OpenMonth_INT"              
			,	S."AccountId"                   
			,	S."ApplicationId"               
			,	S."OpenDate"                    
			,	S."IdNum"                       
			,	S."Consultant"                  
			,	S."AgeInMonths"                 
			,	S."NumOfInstalments"            
			,	S."AccountType"                 
			,	S."PaymentFrequency"            
			,	S."Loan_Size"                   
			,	S."Loan_Term"                   
			,	S."HandedOver"                  
			,	S."FirstArrearDate" 
			,	S."MonthsFirstArrear"            
			,	S."FirstDueDate_Missed_Flag"    
			,	S."FirstInstalment_Default_Flag"
			,	S."One_ever_3_Flag"             
			,	S."Two_ever_6_Flag"             
			,	S."BureauScore"                 
			,	S."ApplicationScore"            
			,	S."BranchName"                  
			,	S."Debtors_Bank"                
			,	S."Product"                     
			,	S."ROLLd_Loan"                  
			,	S."CDE_Override"                
			,	S."Bureau" 
			,	S."ClientCategory" 
			,	S."ServiceProvider" 
			,	S."OverdueStatus"   
		)
	when matched then update set
		 	"IdNum"  											=	S."IdNum"  
		,	"AgeInMonths" 								=	S."AgeInMonths"
		, "HandedOver"									= S."HandedOver"
		, "MonthsFirstArrear"						= S."MonthsFirstArrear"
		,	"FirstArrearDate"							=	S."FirstArrearDate"             
		,	"FirstDueDate_Missed_Flag"		=	S."FirstDueDate_Missed_Flag"    
		,	"FirstInstalment_Default_Flag"= S."FirstInstalment_Default_Flag"
		,	"One_ever_3_Flag"							=	S."One_ever_3_Flag"             
		,	"Two_ever_6_Flag"							=	S."Two_ever_6_Flag"             
		,	"BureauScore"									= S."BureauScore"                 
		,	"ApplicationScore"						= S."ApplicationScore"
		,	"BranchName"                  = S."BranchName"                  
		,	"Debtors_Bank"                = S."Debtors_Bank"                
		,	"Product"                     = S."Product"                     
		,	"ROLLd_Loan"                  = S."ROLLd_Loan"                  
		,	"CDE_Override"                = S."CDE_Override"                
		,	"Bureau"                			= coalesce(S."Bureau",'Experian') 
		,	"ClientCategory" 							= coalesce(S."ClientCategory" , T."ClientCategory")
		,	"ServiceProvider" 						= S."ServiceProvider"
		,	"OverdueStatus"               = S."OverdueStatus";
end;
$$;



select count(*) from prod."Loan_Detail"