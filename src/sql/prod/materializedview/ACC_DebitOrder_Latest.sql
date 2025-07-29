drop Materialized view prod."ACC_DebitOrder_Latest" CASCADE;

create Materialized view prod."ACC_DebitOrder_Latest" as
select d.* from (
	select 	ado.*
				,	rank() over (partition by ado."AccountId" order by ado."CreateDate" , ado."DebitOrderId" desc) "IsLatest"
	from 		prod."ACC_DebitOrder" ado 
) d
where d."IsLatest" = 1;