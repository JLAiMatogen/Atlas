drop Materialized view "ACC_PaymentStatusHistory_Latest";

create Materialized view "ACC_PaymentStatusHistory_Latest" as
select 	d.* from (
	select 	psh.*
				,	rank() over (partition by psh."AccountId" order by psh."RunDate" desc, "PaymentStatusHistoryId" desc) "IsLatest"
				, ps."PaymentStatusDescription"
	from 		"ACC_PaymentStatusHistory" psh , "ACC_PaymentStatus" ps
	where   psh."AccountPaymentStatus" = ps."PaymentStatusId"
) d
where d."IsLatest" = 1;

Create UNIQUE INDEX ACC_PaymentStatusHistory_Latest_uq
on "ACC_PaymentStatusHistory_Latest" ("AccountId");