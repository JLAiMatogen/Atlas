./Load_Sql.sh prod/materializedview/Account_BadRate_Indicators.sql

./Load_Sql.sh prod/view/Account_Detail.sql

./Load_Sql.sh prod/materializedview/Account_Detail_MV.sql dev

./Load_Sql.sh prod/view/Account_Vintage_Indicators.sql dev 

./Load_Sql.sh prod/materializedview/Cumulative_Bad_Rates_MV..sql


./Load_Sql.sh prod/procedure/Refresh_All_MViews.sql

