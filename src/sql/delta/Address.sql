--This query returns all Address Records for the related to the Client and the Employer  
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
Select distinct a.* from (
  select 	adr.*
  from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."Address" adr, parameters p
  where   a."CreateDate" between p."SevenDaysPriorStart" and p."EndDate"
  and     a."ResidentialAddressId" = adr."AddressId"
  union all
  select 	adr.*
  from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."Employer" e
        , backoffice.sqlmig."Address" adr, parameters p
  where   a."CreateDate" between p."SevenDaysPriorStart" and p."EndDate"
  and     a."EmployerId" = e."EmployerId"
  and     e."AddressId" = adr."AddressId"
) a;