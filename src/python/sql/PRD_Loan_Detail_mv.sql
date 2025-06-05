drop materialized view loan_detail_mv;
Create materialized view loan_detail_mv as
Select  "OpenMonth" 
      , "BranchName" "Branch"
      , "Consultant" 
      , "PaymentFrequency"
			, "Loan_Term" 
			, "Debtors_Bank"
      , "Loan_Size"
			, "ROLLd_Loan"
			, "Product"
			--, "Credit_Score_OR_CAT"
			, "CDE_Override"
			, case 
        when "BureauScore" < 560 then '  0 - 560'
        when "BureauScore" >= 750 then '750 +'
        else (TRUNC("BureauScore" / 5) * 5 + 1)::text||' - '||(TRUNC("BureauScore" / 5) * 5 + 5)::text
        end  "BureauScore_Band"
      , case 
        when "ApplicationScore" < 560 then '  0 - 560'
        when "ApplicationScore" >= 750 then '750 +'
        else (TRUNC("ApplicationScore" / 5) * 5 + 1)::text||' - '||(TRUNC("ApplicationScore" / 5) * 5 + 5) ::text
        end  "ApplicationScore_Band"
      , "Bureau" "Bureau_returned"
      , sum(1)                       								"Total"
      , sum(coalesce("HandedOver",0))      							"IsHandedOver"
      , sum(coalesce("FirstDueDate_Missed_Flag",0)) 			"FirstDueDate_Missed"
      , sum(coalesce("FirstInstalment_Default_Flag",0)) 	"FirstInstalment_Default"
      , sum(coalesce("One_ever_3_Flag",0))          			"One_ever_3"
      , sum(coalesce("Two_ever_6_Flag",0))          			"Two_ever_6"
from   	"Loan" 
--where   "OpenMonth"::int >= 202301
group by  "OpenMonth" 
      , "Branch"
      , "Consultant" 
      , "PaymentFrequency"
			, "Loan_Term" 
			, "Debtors_Bank"
      , "Loan_Size"
			, "ROLLd_Loan"
			, "Product"
			--, "Credit_Score_OR_CAT"
			, "CDE_Override"
      , case 
        when "BureauScore" < 560 then '  0 - 560'
        when "BureauScore" >= 750 then '750 +'
        else (TRUNC("BureauScore" / 5) * 5 + 1)::text||' - '||(TRUNC("BureauScore" / 5) * 5 + 5)::text
        end  
      , case 
        when "ApplicationScore" < 560 then '  0 - 560'
        when "ApplicationScore" >= 750 then '750 +'
        else (TRUNC("ApplicationScore" / 5) * 5 + 1)::text||' - '||(TRUNC("ApplicationScore" / 5) * 5 + 5) ::text
        end  
      , "Bureau" 
order by 1;

select count(*) from loan_detail_mv;