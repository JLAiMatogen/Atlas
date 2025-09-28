drop materialized view "Account_Detail_MV";

create materialized view "Account_Detail_MV" as
select  * 
from    "Account_Detail";

Create UNIQUE index Account_Detail_MV_uq 
on "Account_Detail_MV" ("AccountId");


Create  index Account_Detail_MV_OpenMonth_idx
on "Account_Detail_MV" ("OpenMonth");
