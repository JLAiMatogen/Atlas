create or replace procedure staging."Bureau_Add_Static_Data"()
language plpgsql
as $$
begin
	with StaticBureauData as (
		select 	TO_CHAR(aa."OpenDate", 'YYYYMMDD') "ApplicationDate"
				,		aa."AccountId"
				,		aam."ApplicationId"
				,   'PreVet' "Type"
				,		b.*
		from 		staging."ACC_Account" aa 	left outer join staging."Application_AccountMapping" aam 
																				on aa."AccountId" = aam."AccountId"
																			left outer join staging."Application" ap
																				on aam."ApplicationId" = ap."ApplicationId" 
																			left outer join staging."BureauSelectionAndOffers" b
																				on ap."ApplicationId"::text = b.application_reference
		where   b.application_reference  is not null
		)
	merge into "STG_BureauResponse" t
	using ( select * from StaticBureauData ) s
	on    ( t."ApplicationId" = S."ApplicationId"::text)
	when  not matched then 
		insert ("ApplicationDate" , "AccountId", "ApplicationId", "IdNumber", "Type", "bureau_returned")
		values (S."ApplicationDate" , S."AccountId" , S."ApplicationId", S."id_or_passport" , S."Type" , s."bureau_returned");
end;
$$;