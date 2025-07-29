drop materialized view prod."Account_Detail_MV";

create materialized view prod."Account_Detail_MV" as
select  * 
from    prod."Account_Detail";
