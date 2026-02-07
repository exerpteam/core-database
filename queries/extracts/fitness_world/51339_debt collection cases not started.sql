-- This is the version from 2026-02-05
--  
SELECT
        ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS PersonId,
        ccc.CENTER, ccc.ID, ccc.AR_CENTER, ccc.AR_ID, ccc.AMOUNT, 
ccc.CC_AGENCY_AMOUNT, ccc.CC_AGENCY_UPDATE_SOURCE, ccc.CC_AGENCY_UPDATE_TIME, 
ccc.STARTDATE AS CCC_START_DATE, ccc.CURRENTSTEP,
        SUM(art.UNSETTLED_AMOUNT) AS UNSETTLED_AMOUNT
        --art.STATUS,
        --art.MATCH_INFO,
        --art.CENTER || 'ar' || art.ID || 'art' || art.SUBID AS newMatchInfo       
FROM FW.ACCOUNT_RECEIVABLES ar
JOIN FW.CENTERS c ON ar.CENTER = c.ID AND c.COUNTRY = 'DK'
JOIN FW.PERSONS p ON p.CENTER = ar.CUSTOMERCENTER AND p.ID = ar.CUSTOMERID AND 
p.SEX != 'C'
JOIN FW.AR_TRANS art ON ar.CENTER = art.CENTER AND ar.ID = art.ID
LEFT JOIN FW.CASHCOLLECTIONCASES ccc ON ccc.PERSONCENTER = ar.CUSTOMERCENTER AND 
ccc.PERSONID = ar.CUSTOMERID AND ccc.MISSINGPAYMENT = 1 AND ccc.CLOSED = 0
WHERE 
        ar.AR_TYPE = 4
        AND art.UNSETTLED_AMOUNT < 0
        AND art.DUE_DATE < exerpsysdate()
        -- URBAN GYM
        AND (art.CENTER < 400 OR art.CENTER > 499)
        AND art.CENTER != 201
        AND ccc.ID IS NOT NULL
        AND ccc.CC_AGENCY_AMOUNT IS NULL
        AND ccc.STARTDATE > to_date('2018-01-12','YYYY-MM-DD')  -- Update 
        AND ccc.AMOUNT >= 100
        --AND art.MATCH_INFO IS NULL
GROUP BY
        ar.CUSTOMERCENTER,
        ar.CUSTOMERID,
        ccc.CENTER, 
        ccc.ID, 
        ccc.AR_CENTER, 
        ccc.AR_ID, 
        ccc.AMOUNT, 
        ccc.CC_AGENCY_AMOUNT, 
        ccc.CC_AGENCY_UPDATE_SOURCE, 
        ccc.CC_AGENCY_UPDATE_TIME, 
        ccc.STARTDATE, 
        ccc.CURRENTSTEP