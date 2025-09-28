with Application as materialized (
  select  aa."AccountId" 
      , 	TO_CHAR(aa."OpenDate", 'YYYYMMDD') "ApplicationDate"
		  ,  	aam."ApplicationId"::TEXT "ApplicationId" 
  from    backoffice.public."ACC_Account" aa  , backoffice.public."Application_AccountMapping" aam
	where   aa."LoanType" = 'L'
	and     aa."OpenDate" is not null
	and     aa."OpenDate" between '2024-01-26' and '2024-01-27'
	and     aa."AccountId" = aam."AccountId"
),
Response as (
    Select  a."ApplicationDate"
    	    ,	a."AccountId" 
		      ,	a."ApplicationId"  
		      , xds."IdNumber"
		      ,	xds."Type" 
					, xds."Response"
    from    Application a , backoffice.public."XDSCustomerDetailsLog" xds
    where   a."ApplicationId" = xds."ApplicationId"
    and     xds."Type" = 'PreVet'
    and     xds."Response" LIKE '%rule_selected_bureau%'
    and     xds."Response" like '<?xml%'
)
select 	r.* 
from 		Response r;