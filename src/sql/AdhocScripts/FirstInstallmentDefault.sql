with ACC_Schedules as (
	select 	ac."AccountId",as1."Installment_SrNo", as1."Duedate", as1."PaidDate",as1."Paid_Installment"
			,   TO_CHAR(ac."OpenDate", 'YYYYMM')::int "OpenMonth"
			,		extract(year from age(now(), ac."OpenDate" )) * 12  + extract(month from age(now(), ac."OpenDate") ) "AgeInMonths"
			,   case when ( as1."Duedate" <= date_trunc('DAY',now()) ) then 1 else 0 end "IsDue"
			,   case when ( coalesce( date_trunc('DAY',as1."PaidDate"),date_trunc('DAY',now())) >  as1."Duedate" ) then 1 else 0 end "IsLate"
			,   case when ( coalesce( date_trunc('DAY',as1."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  as1."Duedate" ) then 1 else 0 end "IsLate7Days"
			--,		round(as1."Paid_Installment" / as1."Totalinstallment" * 100) "Installment_Paid_Perc"
			,		ROUND(
					CASE 
					WHEN as1."Totalinstallment" = 0 THEN 0
					ELSE as1."Paid_Installment"::numeric / as1."Totalinstallment" * 100
					END) "Installment_Paid_Perc"
	from 	"ACC_Account" ac, "ACC_Schedules" as1
	where ac."AccountId" = as1."AccountId"
	and   ac."LoanType" = 'L'
	and   ac."OpenDate" between '2025-01-01' and '2025-08-20'
	--and   ac."AccountId" = 4956687
	and   as1."Installment_SrNo" = 1
	)
select  "OpenMonth"::text , count(*) 
from 		ACC_Schedules
where  	( "IsLate7Days" = 1 and "IsDue" = 1 )
	or 		("IsDue" = 1 and "Installment_Paid_Perc" < 85 )
group by "OpenMonth"
;


set search_path to dev;

with Parameters as (
    SELECT  '202501'::int AS "StartMonth"
       		, '202512'::int AS "EndMonth"
)
select    "OpenMonth"::text 
		,		"BranchName" 
		, 	"Consultant" 
		,   "PaymentFrequency" 
		,		"Loan_Term" 
		,		"Debtors_Bank" 
		,   "Loan_Size" 
		,   "ROLLd_Loan" 
		,   "Product" 
		,		"ClientCategory" 
		,   "ServiceProvider" 
		, 	"CDE_Override" 
		--,   "BureauScore"
		, 	case 
       	when "BureauScore" < 560 then '  0 - 560'
        when "BureauScore" >= 750 then '750 +'
        else (TRUNC("BureauScore" / 5) * 5 + 1)::text ||' - '||(TRUNC("BureauScore" / 5) * 5 + 5)::text 
        end  "BureauScoreBand"
    --,   "ApplicationScore"
    , 	case 
        when "ApplicationScore" < 560 then '  0 - 560'
        when "ApplicationScore" >= 750 then '750 +'
        else (("ApplicationScore" / 5) * 5 + 1)::text||' - '||(("ApplicationScore" / 5) * 5 + 5)::text
        end  "ApplicationScoreBand"
    ,   "Bureau_Returned" 
    ,		1   "Total"
    ,   "HandedOver" 										
    ,		"FirstDueDate_Missed_Flag" 			
    , 	"FirstInstalment_Default_Flag"	
    , 	"One_ever_3_Flag"          			
    , 	"Two_ever_6_Flag"          			
    ,   "OverDue_Segment"          		 
from   "Account_Detail_MV" , parameters p
WHERE  "OpenMonth" BETWEEN p."StartMonth" and p."EndMonth"


set search_path to prod;

select "OpenMonth"::text , count(*) TotalAccounts 
		, sum("FirstInstalment_Default_Flag") FirstInstalment_Default
from   "Account_Detail_MV" 
where  "OpenMonth" between 202407 and 202509
group by "OpenMonth"::text
order by 1;



"OpenMonth"::text 
		,		"BranchName" 
		, 	"Consultant" 

 
    ,		1   "Total"
    ,		"FirstDueDate_Missed_Flag" 			
    , 	"FirstInstalment_Default_Flag"	
    , 	"One_ever_3_Flag"          			
    , 	"Two_ever_6_Flag"          			
 
    


WITH SampleData AS (
	SELECT
	    *,
	    ROW_NUMBER() OVER (PARTITION BY "OpenMonth" ORDER BY RANDOM()) as rn
	FROM dev."Account_Detail_MV"
)
select * from SampleData
WHERE rn <= 10000; -- Get 50 random rows for each month

select "OpenMonth"
		,		count(*) Record_Count
from 		dev."Cumulative_Bad_Rates_MV"
where  	"OpenMonth" between 202401 and 202512
group by "OpenMonth";


select count(*) from dev."Cumulative_Bad_Rates_MV"
where  "OpenMonth" between 202101 and 202112;








