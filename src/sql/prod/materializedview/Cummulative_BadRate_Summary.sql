Create or replace view Cumulative_Bad_rate as
With RollingMonths as(
  select level AgeInMonths
  from dual 
  CONNECT BY LEVEL<= 12
  ),
VintageIndicators as (
  Select  OpenMonth 
        , Loan_Term
        , OpenDate 
        , AccountId
        , FirstArrearDate
        , MONTHSFIRSTARREAR
        , rm.AgeInMonths
        , Branch
        , Consultant 
        , PaymentFrequency
        , Debtors_Bank
        , Loan_Size
        , ROLLd_loan
        , Product
        --, Credit_Score_OR_CAT
        , CDE_Override
        , case 
          when BureauScore < 560 then '  0 - 560'
          when BureauScore >= 750 then '750 +'
          else to_char(TRUNC(BureauScore / 5) * 5 + 1)||' - '||to_char(TRUNC(BureauScore / 5) * 5 + 5) 
          end  BureauScore_Band
        , case 
          when ApplicationScore < 560 then '  0 - 560'
          when ApplicationScore >= 750 then '750 +'
          else to_char(TRUNC(ApplicationScore / 5) * 5 + 1)||' - '||to_char(TRUNC(ApplicationScore / 5) * 5 + 5) 
          end  ApplicationScore_Band
        , case when ( bureau is null ) then 'Experian' else bureau end bureau_returned
        , case when (rm.AgeInmonths >= ld.MONTHSFIRSTARREAR ) then 1 else 0 end Vintage_Indicator
  from   RollingMonths rm, loan_detail2 ld
  --where  openMonth =202401 --AccountId = 3341967
  ),
VintageSummary as (
  Select  to_char(OpenMonth) OpenMonth
        --, Bureau_Returned
        --, BureauScore_Band
        --, Branch
        --, Consultant
        --, PaymentFrequency
        , Loan_Term
        --, Debtors_Bank
        , Loan_Size
        --, ROLLd_loan
        --, Product
        --, CDE_Override
        , AgeInMonths
        , count(*) Total_Accounts
        , sum(Vintage_Indicator) Total_In_Arrears
        --, round(sum(Vintage_Indicator)/count(*),2) Vintage_Perc
  from    VintageIndicators
  group by OpenMonth 
        --, Bureau_Returned
        --, BureauScore_Band
        --, Branch
        --, Consultant
        --, PaymentFrequency
        , Loan_Term
        --, Debtors_Bank
        , Loan_Size
        --, ROLLd_loan
        --, Product
        --, CDE_Override
        , AgeInMonths
  union all
  Select  'General' OpenMonth
        --, Bureau_Returned
        --, BureauScore_Band
        --, Branch
        --, Consultant
        --, PaymentFrequency
        , Loan_Term
        --, Debtors_Bank
        , Loan_Size
        --, ROLLd_loan
        --, Product
        --, CDE_Override
        , AgeInMonths
        , count(*) Total_Accounts
        , sum(Vintage_Indicator) Total_In_Arrears
        --, round(sum(Vintage_Indicator)/count(*),2) Vintage_Perc
  from    VintageIndicators
  group by 'General' 
        --, Bureau_Returned
        --, BureauScore_Band
        --, Branch
        --, Consultant
        --, PaymentFrequency
        , Loan_Term
        --, Debtors_Bank
        , Loan_Size
        --, ROLLd_loan
        --, Product
        --, CDE_Override
        , AgeInMonths
)
Select * from VintageSummary;