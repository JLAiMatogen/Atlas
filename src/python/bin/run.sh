#!/bin/bash
cd ../
python  Staging_ReferenceTables.py
python  Staging_AccountInfo.py
python  Staging_BureauResponse.py
python  Staging_ACC_Schedules.py
python  Staging_Application_AccountMapping.py
python  Staging_Application.py
python  Staging_Affordability.py
python  Staging_CreditScore.py
python  Staging_BankDetail.py
python  Staging_Quotation.py
python  Staging_ACC_Repayment.py
python  Staging_ACC_Account.py