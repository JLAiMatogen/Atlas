create materialized view "XDS_CusomerDetailsLog_MV" as
with XDSJsonData as (
	select 	ap."ApplicationId" , ap."CreateDate" , xds."IdNumber" , xds."Type" 
				, safe_json_parse(xds."JsonText"::TEXT) "Obj"
	from 		prod."Application" ap , prod."XDSCustomerDetailsLog" xds
	where   ap."ApplicationId" = xds."ApplicationId"
	and     xds."Type" = 'PreVet'
)
select   x."ApplicationId" , x."CreateDate" , x."IdNumber" , x."Type" 
			,	 x."Obj"->>'bureau_returned' as "Bureau_Returned"
			,  x."Obj"->>'score' as "Bureau_Score"
from     XDSJsonData x