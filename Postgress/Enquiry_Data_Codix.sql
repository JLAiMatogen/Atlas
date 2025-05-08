--I have just replied to your email about the bureau enquiries, 
--not sure if that is related to this message. 
--Otherwise anyone trying to get a loan that doesn't qualify or is rejected for any reason would also appear in our Applications table. 
--They would either not even have an ACC_Account record yet (didn't get to the loan selection option yet), 
--or the ACC_Account will exist but will be Status=0 (Inactive). 
--The Application has a cancellation reason code on it, but most of the time it's "auto-expired by the system"



select 	TO_CHAR(coalesce(af."EnqDate",a."CreateDate"), 'YYYYMM') "EnquiryMonth"
	,	a."ApplicationId" , a."AccountId" ,  a."AccountNo"
	,	a."AccountId" , a."QuotationId"
	,   b."BranchName" 
	,   ppp2."Description"  "Product"
	,	b2."Description" Debtors_Bank 
	,   coalesce(q."LoanAmount",af."LoanAmount") "LoanAmount"
	,   case 
			when ( coalesce(q."LoanAmount",af."LoanAmount")  between 0    and 1000  ) then '   0 - 1000'
			when ( coalesce(q."LoanAmount",af."LoanAmount")  between 1001 and 2000  ) then '1001 - 2000'
			when ( coalesce(q."LoanAmount",af."LoanAmount")  between 2001 and 3000  ) then '2001 - 3000'
			when ( coalesce(q."LoanAmount",af."LoanAmount")  between 3001 and 4000  ) then '3001 - 4000'
			when ( coalesce(q."LoanAmount",af."LoanAmount")  between 4001 and 5000  ) then '4001 - 5000'
			when ( coalesce(q."LoanAmount",af."LoanAmount")  between 5001 and 6000  ) then '5001 - 6000'
			when ( coalesce(q."LoanAmount",af."LoanAmount")  between 6001 and 7000  ) then '6001 - 7000'
			when ( coalesce(q."LoanAmount",af."LoanAmount")  between 7001 and 8000  ) then '7001 - 8000'
			when ( coalesce(q."LoanAmount",af."LoanAmount")  between 8001 and 9000  ) then '8001 - 9000'
			when ( coalesce(q."LoanAmount",af."LoanAmount")  between 9001 and 10000 ) then '9001 - 10000'
			else	'10000 +' 
			end  "Loan_Size"
	,   q."LoanDate"   , q."RepaymentDate" 
	,   DATE_PART('year', AGE(q."RepaymentDate"   , coalesce(q."LoanDate",a."CreateDate") )) * 12 +
    	DATE_PART('month', AGE(q."RepaymentDate", coalesce(q."LoanDate",a."CreateDate") )) + 1 AS Loan_Term
	,	case when ( q."IsRollOver") then 'Yes' else 'No' end "ROLLd_Loan"
	,   case when ( a."IsGetOfferOverride") then 'Yes' ELSE 'No' end "CDE_Override"
	, 	af."Accepted", af."NLRScore" "BureauScore"
	, 	af."EnqDate"
	,   cs."ApplicationScore" , cs."BehaviourScore", cs."RiskType"
from 	backoffice.sqlmig."Application" a	
				left outer join backoffice.sqlmig."Branch" b
						on	a."BranchId" = b."BranchId" 
				left outer join backoffice.sqlmig."BankDetail" bd 
						on  a."BankDetailId"   = bd."BankDetailId"
				left outer join backoffice.sqlmig."Bank" b2 
						on  bd."BankId"  		 = b2."BankId"
				left outer join backoffice.sqlmig."Quotation" q 
						on	a."QuotationId"    = q."QuotationId"
				left outer join backoffice.public."PRD_Products" ppp2 
						on	a."ProductId"      = ppp2."ProductId"
				left outer join backoffice.sqlmig."Affordability" af
					on a."ApplicationId" = af."ApplicationId" 
				left outer join backoffice.sqlmig."CreditScore" cs 
					on a."ApplicationId"  = cs."ApplicationId"
				left outer join backoffice.public."ACC_Account" aa 
					on a."AccountId"  = aa."AccountId"
where   af."EnqDate"  between	
			Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months') and
			Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '-1 months')
--and		( a."AccountId"  is null or aa."StatusId"  = 0)
order by 1;
Monthly