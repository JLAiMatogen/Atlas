
drop materialized view "XDS_CusomerDetailsLog_MV";

create materialized view "XDS_CusomerDetailsLog_MV" as
with XDSJsonData as (
	select 	ap."ApplicationId" , ap."CreateDate" , xds."IdNumber" , xds."Type" 
				, safe_json_parse(xds."JsonText"::TEXT) "Obj"
	from 		"Application" ap , "XDSCustomerDetailsLog" xds
	where   ap."ApplicationId" = xds."ApplicationId"
	and     xds."Type" = 'PreVet'
)
select   x."ApplicationId" , x."CreateDate" , x."IdNumber" , x."Type" 
			,	 x."Obj"->>'bureau_returned' as "Bureau_Returned"
			,  x."Obj"->>'score' as "Bureau_Score"
from     XDSJsonData x;


CREATE UNIQUE INDEX XDS_CusomerDetailsLog_MV_uq
ON "XDS_CusomerDetailsLog_MV" ("ApplicationId");
