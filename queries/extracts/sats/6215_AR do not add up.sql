SELECT 
    ACC.CUSTOMERCENTER || 'p' || ACC.CUSTOMERID       as PersonId , 
    DECODE(ACC.AR_TYPE,1,'Cash',4,'Payment',5,'Debt') as AccountType, 
    longtodate(ART.TRANS_TIME)                        as transdate, 
    ART.AMOUNT , 
    ART.TEXT, 
    ART.INFO , 
    CASE 
        WHEN ART.ENTRY_TIME > RP.CLOSE_TIME 
        THEN 1 
        ELSE 0 
    END as afterClose 
FROM 
    REPORT_PERIODS RP 
JOIN 
    AREA_CENTERS AC 
    ON 
    AC.AREA in 
    ( 
    SELECT 
        AR.ID 
    FROM 
        AREAS AR 
    WHERE 
        AR.PARENT = RP.SCOPE_ID 
    ) 
JOIN 
    AR_TRANS ART 
    ON 
    ART.CENTER = AC.CENTER 
JOIN 
    ACCOUNT_RECEIVABLES ACC 
    ON 
    ACC.CENTER = ART.CENTER 
    and ACC.ID = ART.ID 
WHERE 
    -- choose a date in the report period   
    TO_DATE('2009-12-31','yyyy-mm-dd') BETWEEN START_DATE 
    and END_DATE 
    -- choose a center interval (be carefull: heavy extract)   
    and AC.CENTER BETWEEN 701 and 702 and 
    ( 
        ART.ENTRY_TIME    < RP.CLOSE_TIME 
        or ART.ENTRY_TIME < RP.HARD_CLOSE_TIME 
    ) 
    and ART.TRANS_TIME BETWEEN datetolong(to_char(RP.START_DATE,'yyyy-mm-dd
hh24:MI')) and datetolong(to_char(RP.END_DATE,'yyyy-mm-dd hh24:mi'))
