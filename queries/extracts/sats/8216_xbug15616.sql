SELECT 
    P.CENTER || 'p' || P.ID as PersonId , 
    max (CCR.REQ_DATE) as LatestCCRequestUnsent, 
    count(*) as NBCCRequestUnsent, 
    sum(CCR.REQ_AMOUNT) as TotalCCRequestUnsent
FROM 
    CASHCOLLECTION_REQUESTS CCR 
JOIN 
    CASHCOLLECTIONCASES CCC 
    ON 
    CCR.CENTER = CCC.CENTER 
    and CCR.ID = CCC.ID 
JOIN 
    PERSONS P 
    ON 
    CCC.PERSONCENTER = P.CENTER 
    and CCC.PERSONID = P.ID 
WHERE 
    CCR.state = 0 
    and P.LASTNAME IS NULL 
GROUP BY 
    P.CENTER, 
    P.ID
