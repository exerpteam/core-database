SELECT ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID personid, 
    artMain.center || 'ar' || artMain.id account, 
to_char(longtodatetz(artMain.ENTRY_TIME, 'Europe/Copenhagen'), 'yyyy-MM-dd hh:MI') time, 
    artMain.TEXT, 
    CASE 
        WHEN artMain.AMOUNT > 0 
        THEN artMain.AMOUNT 
        ELSE null 
    END as Paid, 
    CASE 
        WHEN artMain.AMOUNT <= 0 
        THEN artMain.AMOUNT 
        ELSE null 
    END as withdrawn, 
    sum(artSum.AMOUNT) balance 
FROM 
    sats.AR_TRANS artMain 
JOIN 
    sats.AR_TRANS artSum 
    ON 
    artMain.CENTER         = artSum.CENTER 
    and artMain.ID         = artSum.ID 
    and artSum.ENTRY_TIME <= artMain.ENTRY_TIME 
JOIN 
    sats.ACCOUNT_RECEIVABLES ar 
    ON 
    artMain.center = ar.center 
    and artmain.id = ar.id 
WHERE 
	ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID =:MemberId
	and ar.AR_TYPE    = 4 
GROUP BY 
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID, 
    artMain.CENTER, 
    artMain.ID, 
    artMain.ENTRY_TIME, 
    artMain.TEXT, 
    artMain.AMOUNT, 
    artMain.AMOUNT 
ORDER BY 
    artMain.CENTER, 
    artMain.ID, 
    artMain.ENTRY_TIME desc 