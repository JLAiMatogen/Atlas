with Application as materialized (
    select  aa."AccountId" 
    	, 	TO_CHAR(aa."OpenDate", 'YYYYMMDD') "ApplicationDate"
		,  	aam."ApplicationId"::TEXT
    from    backoffice.public."ACC_Account" aa  , backoffice.public."Application_AccountMapping" aam
    where   aa."OpenDate" between '{STARTDATE}' and '{ENDDATE}'
		--where   aa."OpenDate" between '2025-01-01' and '2025-01-07'
    and     aa."AccountId" = aam."AccountId"
    and     aa."LoanType" = 'L'
),
Response as (
    Select  a."ApplicationDate"
    	,	a."AccountId" 
		,	a."ApplicationId"  
		, 	xds."IdNumber"
		,	xds."Type" 
		, 	CASE
				WHEN xds."Response" IS NOT NULL AND xds."Response" ~ '<.+>' THEN
						((xpath('//string/text()', xds."Response"::xml))[1])::TEXT::jsonb
				ELSE NULL
			END AS "Obj"
    from    Application a , backoffice.public."XDSCustomerDetailsLog" xds
    where   a."ApplicationId" = xds."ApplicationId"
    and     xds."Response" LIKE '%rule_selected_bureau%'
)
select    r."ApplicationDate"	
		, r."AccountId" 			
		, r."ApplicationId" 	
		, r."IdNumber" 				
		, r."Type" 						
    , r."Obj"->>'bureau_returned' as "bureau_returned"
    , r."Obj"->>'score' as "bureau_score"
from    Response r;