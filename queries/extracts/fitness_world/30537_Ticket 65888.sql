-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct 
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID pid,
    act.CENTER || 'acc' || act.ID || 'tr' || act.SUBID act_id,
    DECODE(ar.AR_TYPE,1,'Cash',4,'Payment',5,'Debt') account_type,
    exerpro.longToDate(art.TRANS_TIME) trans_time,
    art.AMOUNT,
    art.TEXT,
    cred_acc.GLOBALID,
    cred_acc.NAME,
    cred_acc.EXTERNAL_ID,
    cred_acc.CENTER,
    cred_acc.ID,
    deb_acc.GLOBALID,
    deb_acc.NAME,
    deb_acc.EXTERNAL_ID,
    deb_acc.CENTER,
    deb_acc.ID

FROM
    AR_TRANS art
join ACCOUNT_RECEIVABLES ar on ar.CENTER = art.CENTER and ar.ID = art.ID    
JOIN
    ACCOUNT_TRANS act
ON
    act.CENTER = art.CENTER
    AND act.ID = art.ID
left join ACCOUNTS cred_acc on cred_acc.CENTER = act.CREDIT_ACCOUNTCENTER    and cred_acc.ID = act.CREDIT_ACCOUNTID and cred_acc.GLOBALID in ('DEFERRED_REVENUE_LIABILITY', 'DEFERRED_REVENUE_SALES')
left join ACCOUNTS deb_acc on deb_acc.CENTER = act.DEBIT_ACCOUNTCENTER    and deb_acc.ID = act.DEBIT_ACCOUNTID and deb_acc.GLOBALID in ('DEFERRED_REVENUE_LIABILITY', 'DEFERRED_REVENUE_SALES')
WHERE
    art.REF_TYPE = 'ACCOUNT_TRANS'
    and (cred_acc.CENTER is not null or deb_acc.CENTER is not null)
    and act.DEBIT_ACCOUNTCENTER || 'act' || act.DEBIT_ACCOUNTID !=  act.CREDIT_ACCOUNTCENTER || 'act' || act.CREDIT_ACCOUNTID
	and act.center in ($$scope$$)