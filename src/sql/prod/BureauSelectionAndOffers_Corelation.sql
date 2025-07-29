
select 	a."ApplicationId" , bso.*
from 		prod."Application" a , staging."BureauSelectionAndOffers" bso
where   a."ApplicationId"::text = bso."application_reference";

with RefData as materialized (
	select 	d.prevet_date "CreateDate"
				,	d."application_reference"::bigint "ApplicationId"
				, d.id_or_passport "IdNumber"
				, 'PreVet' "Type"
				, d."bureau_returned" "Bureau_Returned"  
	from 		staging."BureauSelectionAndOffers" d 
	where  "application_reference"  in ( 
				select bso."application_reference" as "application_reference"
				from   staging."BureauSelectionAndOffers" bso
				WHERE  "application_reference" ~ '^\d+$'
				except  
				select xds."ApplicationId"::text
				from   "XDS_CusomerDetailsLog_MV" xds
				where  "CreateDate" > '01-Jan-2024'
			) 
	) 
select 	count(*)
from 		RefData r, prod."Application" a
where   r."ApplicationId" = a."ApplicationId";
order by r."ApplicationId" desc;