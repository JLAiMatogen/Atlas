drop Materialized view "ACC_DebitOrder_Latest" CASCADE;

create Materialized view "ACC_DebitOrder_Latest" as
select d.* from (
	select 	ado.*
				,	rank() over (partition by ado."AccountId" order by ado."CreateDate" , ado."DebitOrderId" desc) "IsLatest"
	from 		"ACC_DebitOrder" ado 
) d
where d."IsLatest" = 1;

CREATE UNIQUE INDEX ACC_DebitOrder_Latest_uq
ON "ACC_DebitOrder_Latest" ("DebitOrderId");