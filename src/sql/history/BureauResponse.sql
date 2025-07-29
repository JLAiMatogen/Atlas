with Application as materialized (
  select  aa."AccountId" 
      , 	TO_CHAR(aa."OpenDate", 'YYYYMMDD') "ApplicationDate"
		  ,  	aam."ApplicationId"::TEXT
  from    backoffice.public."ACC_Account" aa  , backoffice.public."Application_AccountMapping" aam
	where   aa."LoanType" = 'L'
	and     aa."OpenDate" is not null
	and     aa."OpenDate" between '{STARTDATE}' and '{ENDDATE}'
	and     aa."AccountId" = aam."AccountId"
),
XmlResponse as (
	select  a.*
			, 	xds."IdNumber"
		  ,		xds."Type"
			,		regexp_replace (
		      	regexp_replace(
			         xds."Response",
			         ',?"(bureau_response|encoded_xds_bureau_string|Base64StringJpeg2000Image)": "[^"]*",?',
			         '',
			         'g'
			       )
			      ,	'&#x[0-9A-Fa-f]+;|&#\d+;',  -- matches &#xHEX; and &#DECIMAL;
		         '',
		         'g'
		        )::xml "XmlResponse"
		    , dense_rank() over ( partition by xds."ApplicationId" order by "InsertTime" desc ) ranking
	from    Application a, backoffice.public."XDSCustomerDetailsLog" xds
	where   a."ApplicationId" = xds."ApplicationId"
  and     xds."Type" = 'PreVet'
  and     xds."Response" LIKE '%rule_selected_bureau%'
  --and     xds."Response"::text like '%0x09%'
  ),
JsonResponse as (
	select x."AccountId"
			,	 x."ApplicationId"::int
			,	 x."ApplicationDate"
			,  x."IdNumber"
		  ,	 x."Type"
			,	 (xpath('//string/text()', x."XmlResponse"::xml))[1]::text "JsonResponse"
	from   XmlResponse x
	where  ranking = 1
)
select 	j.* 
from 		JsonResponse j;