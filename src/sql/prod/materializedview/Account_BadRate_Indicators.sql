create materialized view "Account_BadRate_Indicators" as
with ACC_Schedules as (
	select 	ac."AccountId",as1."Installment_SrNo", as1."Duedate", as1."PaidDate"
			,		extract(year from age(now(), ac."OpenDate" )) * 12  + extract(month from age(now(), ac."OpenDate") ) "AgeInMonths"
			,   case when ( as1."Duedate" <= date_trunc('DAY',now()) ) then 1 else 0 end "IsDue"
			,   case when ( coalesce( date_trunc('DAY',as1."PaidDate"),date_trunc('DAY',now())) >  as1."Duedate" ) then 1 else 0 end "IsLate"
			,   case when ( coalesce( date_trunc('DAY',as1."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  as1."Duedate" ) then 1 else 0 end "IsLate7Days"
			--,		round(as1."Paid_Installment" / as1."Totalinstallment" * 100) "Installment_Paid_Perc"
			,		ROUND(
					CASE 
					WHEN as1."Totalinstallment" = 0 THEN 0
					ELSE as1."Paid_Installment"::numeric / as1."Totalinstallment" * 100
					END) "Installment_Paid_Perc"
	from 	prod."ACC_Account" ac, prod."ACC_Schedules" as1
	where ac."AccountId" = as1."AccountId"),
ACC_Schedules_Detail as (
	select 	as2.*
			,	case when ( as2."Installment_SrNo" = 1 ) then
					case
					when ( as2."IsDue" = 1 and as2."IsLate" = 1 ) then 1
					when ( as2."IsDue" = 1 and as2."Installment_Paid_Perc" < 85) then 1
					else 0
					end
				else 0 
				end "FirstDueDate_Missed_Ind"
			,	case when ( as2."Installment_SrNo" = 1 ) then
					case
					when ( as2."IsDue" = 1 and as2."IsLate7Days" = 1 ) then 1
					when ( as2."IsDue" = 1 and as2."Installment_Paid_Perc" < 85) then 1
					else 0
					end 
				else 0 
				end "FirstInstalment_Default_Ind"
			,	case 
				when ( as2."AgeInMonths" < 3  ) then null 
				when ( as2."Installment_SrNo" <= 3 ) then
					case
					when ( as2."IsDue" = 1 and as2."IsLate7Days" = 1 ) then 1
					when ( as2."IsDue" = 1 and as2."Installment_Paid_Perc" < 85) then 1
					else 0
					end 
				else 0
				end "InstallmentMissed_First3Months_Ind"
			,	case 
				when ( as2."AgeInMonths" < 6  ) then null 
				when ( as2."Installment_SrNo" <= 6 ) then
					case
					when ( as2."IsDue" = 1 and as2."IsLate7Days" = 1 ) then 1
					when ( as2."IsDue" = 1 and as2."Installment_Paid_Perc" < 85) then 1
					else 0
					end 
				else 0
				end "InstallmentMissed_First6Months_Ind"
			, case 
				when ( as2."IsDue" = 1 and as2."IsLate7Days" = 1 ) then as2."Duedate" 
				when ( as2."IsDue" = 1 and as2."Installment_Paid_Perc" < 85 ) then as2."Duedate"
				else null
				end  "ArrearDate"
	from 		ACC_Schedules as2 )
select 	asd."AccountId" 
			,	asd."AgeInMonths"
			, min(asd."ArrearDate") "FirstArrearDate"
			,	max(asd."FirstDueDate_Missed_Ind")	"FirstDueDate_Missed_Flag"
			,	max(asd."FirstInstalment_Default_Ind") "FirstInstalment_Default_Flag"
			, case when 
					sum( asd."InstallmentMissed_First3Months_Ind" ) >= 1 then 1
				else 0 
				end "One_ever_3_Flag"
			, case when 
					sum( asd."InstallmentMissed_First6Months_Ind" ) >= 2	then 1
				else 0 
				end "Two_ever_6_Flag"
from 		ACC_Schedules_Detail asd
group by asd."AccountId" , asd."AgeInMonths"
order by "AccountId";