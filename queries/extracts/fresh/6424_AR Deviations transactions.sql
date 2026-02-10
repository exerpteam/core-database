-- The extract is extracted from Exerp on 2026-02-08
--  
 select longtodate(act.TRANS_TIME) as BookTime, longtodate(act.ENTRY_TIME) as EntryTime, credit_acc.CENTER as CreditCenter, credit_acc.GLOBALID as CreditGlobalId, credit_acc.EXTERNAL_ID as CreditExternalId, debit_acc.CENTER as
 DebitCenter, debit_acc.GLOBALID as DebitGlobalId, debit_acc.EXTERNAL_ID as DebitExternalId, act.AMOUNT, act.text, act.info
 from ACCOUNT_TRANS act
 join ACCOUNTS credit_acc on act.CREDIT_ACCOUNTCENTER = credit_acc.center and credit_acc.id = act.CREDIT_ACCOUNTID
 join ACCOUNTS debit_acc on act.debit_ACCOUNTCENTER = debit_acc.center and debit_acc.id = act.debit_ACCOUNTID
 where (
 (credit_acc.GLOBALID in ('AR_CASH','AR_EXTERNALDEBT','AR_PAYMENT_COMPANIES','AR_PAYMENT_PERSONS'))
 and
 (debit_acc.GLOBALID in ('AR_CASH','AR_EXTERNALDEBT','AR_PAYMENT_COMPANIES','AR_PAYMENT_PERSONS'))
 )
 and act.TRANS_TYPE = 2
 and act.TRANS_TIME >= :date_from
 and act.TRANS_TIME < (:date_to + 86400000)
 and act.INFO_TYPE = 11
 and act.center in (:scope)
