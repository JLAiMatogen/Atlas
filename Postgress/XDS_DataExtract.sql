--element->>'codex_rule_type' AS codex_rule_fired,
--element->>'codex_rule_description' AS value

select * from backoffice.public."XDSCustomerDetailsLog";


with ACC_Account as materialized (
	select 	aa.*
		,   ap."IdNum"
		,	aam."ApplicationId"
		,   pc."Firstname"||' '||pc."Lastname" "Consultant"
		,	TO_CHAR(aa."OpenDate", 'YYYYMM') "ApplicationMonth"
		, 	apf."Description" as "PaymentFrequency"
		,   case 
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 30  then '1'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 31  and 60  then '2'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 61  and 90  then '3'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 120 then '4'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 121 and 150 then '5'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 151 and 180 then '6'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 210 then '7'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 211 and 240 then '8'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 241 and 270 then '9'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 271 and 300 then '10'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 301 and 330 then '11'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 331 and 360 then '12'
			else	'12+' 
			end  "Loan_Term"
		,   case 
			when ( aa."LoanAmount"  between 0    and 1000  ) then '   0 - 1000'
			when ( aa."LoanAmount"  between 1001 and 2000  ) then '1001 - 2000'
			when ( aa."LoanAmount"  between 2001 and 3000  ) then '2001 - 3000'
			when ( aa."LoanAmount"  between 3001 and 4000  ) then '3001 - 4000'
			when ( aa."LoanAmount"  between 4001 and 5000  ) then '4001 - 5000'
			when ( aa."LoanAmount"  between 5001 and 6000  ) then '5001 - 6000'
			when ( aa."LoanAmount"  between 6001 and 7000  ) then '6001 - 7000'
			when ( aa."LoanAmount"  between 7001 and 8000  ) then '7001 - 8000'
			when ( aa."LoanAmount"  between 8001 and 9000  ) then '8001 - 9000'
			when ( aa."LoanAmount"  between 9001 and 10000 ) then '9001 - 10000'
			else	'10000 +' 
			end  "Loan_Size"
		,   case when ( aa."LoanStateReasonCode"  in ('H') ) then 1 else 0 end "HandedOver"
		,   xds."ApplicationId" 	
		, 	xds."Type"
		,   ( ((xpath('//string/text()', xds."Response"::xml))[1])::TEXT::jsonb )::jsonb "Obj"
	from   	backoffice.public."ACC_Account" aa, backoffice.public."Application_AccountMapping" aam
		, 	backoffice.public."PER_Person" pc, backoffice.public."ACC_PeriodFrequency" apf , backoffice.public."ACC_LoanStateReason" lsr
		,   backoffice.public."PER_Person" ap
		,   backoffice.public."XDSCustomerDetailsLog" xds
	where  	--TO_CHAR(aa."OpenDate", 'YYYYMM')  = '202412'
		aa."OpenDate" between 
		Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '00 months') and
		Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '-1 months')
	and    	aa."LoanType" = 'L'
	and     aa."AccountId" = aam."AccountId"
	and     aa."CreatedBy" = pc."PersonId" 
	and     aa."PersonId"  = ap."PersonId"
	and     aa."PeriodFrequencyId"  = apf."PeriodFrequencyId"
	and     aa."LoanStateReasonCode" = lsr."Code"
	and     aam."ApplicationId"::varchar(128) = xds."ApplicationId"
	and     xds."Response" LIKE '%rule_selected_bureau%'
	order by TO_CHAR(aa."OpenDate", 'YYYYMM')
)
select 	aa.* 
	,	aa."Obj"->>'bureau_returned' as "bureauReturned"
	,	aa."Obj"->>'score' as "Score"	
from	ACC_Account aa;

--select 	xds."ApplicationId" 	
--		, 	xds."Type" 
--		, 	xds."Response"
--		,   ((xpath('//string/text()', xds."Response"::xml))[1])::TEXT::jsonb "JsonData"
--from 	backoffice.public."XDSCustomerDetailsLog" xds
--where   xds."ApplicationId" in ( select cast ("ApplicationId" as varchar(128)) from ACC_Account);
with JsonObj as materialized (
	select  xds."ApplicationId" 	
		, 	xds."Type" 
		--, 	xds."Response"
		,   ( ((xpath('//string/text()', xds."Response"::xml))[1])::TEXT::jsonb )::jsonb "Obj"
	from 	backoffice.public."XDSCustomerDetailsLog" xds
	where   xds."ApplicationId" in ( '3547405' )
	--where   xds."InsertTime" >= '2024-01-01'::timestamp
	--and     xds."InsertTime" < '2024-01-31'::timestamp
	AND 	(	--xds."Response" LIKE '%product_matrix%'
         		--OR 
         		xds."Response" LIKE '%rule_selected_bureau%'
         	)
	)
select 	o."ApplicationId" 	
	, 	o."Type" 
	,	o."Obj"->>'bureau_returned' as "bureauReturned"
	,	o."Obj"->>'score' as "Score"
from 	JsonObj o;





