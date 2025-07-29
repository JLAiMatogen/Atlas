drop Materialized view prod."ACC_PaymentStatusHistory_Latest";

create Materialized view prod."ACC_PaymentStatusHistory_Latest" as
select 	d.* from (
	select 	psh.*
				,	rank() over (partition by psh."AccountId" order by psh."RunDate" desc, "PaymentStatusHistoryId" desc) "IsLatest"
				, ps."PaymentStatusDescription"
	from 		prod."ACC_PaymentStatusHistory" psh , prod."ACC_PaymentStatus" ps
	where   psh."AccountPaymentStatus" = ps."PaymentStatusId"
) d
where d."IsLatest" = 1;