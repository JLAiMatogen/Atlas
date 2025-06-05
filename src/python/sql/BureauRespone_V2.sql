with Application as materialized (
  select  aa."AccountId" 
      , 	TO_CHAR(aa."OpenDate", 'YYYYMMDD') "ApplicationDate"
		  ,  	aam."ApplicationId"::TEXT
  from    backoffice.public."ACC_Account" aa  , backoffice.public."Application_AccountMapping" aam
  where   aa."LoanType" = 'L'
	and     aa."OpenDate" is not null
	and     aa."OpenDate" >= CURRENT_DATE - INTERVAL '10 days' 
  and     aa."AccountId" = aam."AccountId"
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
          , dense_rank() over ( partition by xds."ApplicationId" order by "InsertTime" desc ) ranking
    from    Application a , backoffice.public."XDSCustomerDetailsLog" xds
    where   a."ApplicationId" = xds."ApplicationId"
    and     xds."Type" = 'PreVet'
    and     xds."Response" LIKE '%rule_selected_bureau%'
)
select  r."ApplicationDate"	
		  , r."AccountId" 			
		  , r."ApplicationId" 	
		  , r."IdNumber" 				
		  , r."Type" 						
      , r."Obj"->>'bureau_returned' as "bureau_returned"
      , r."Obj"->>'score' as "bureau_score"
from    Response r
where   ranking = 1
;