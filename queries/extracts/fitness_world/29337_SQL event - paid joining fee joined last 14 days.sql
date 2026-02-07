-- This is the version from 2026-02-05
--  
SELECT
    s.OWNER_CENTER||'p'||s.OWNER_ID,
    il.TOTAL_AMOUNT      AS "Joining fee",
    decode(r.RELATIVECENTER,null,'no','yes') as Company_Agreement
FROM
    FW.SUBSCRIPTIONS s
JOIN
    FW.INVOICELINES il
ON
    il.center = s.INVOICELINE_CENTER
    AND s.INVOICELINE_ID = il.id
    AND s.INVOICELINE_SUBID = il.SUBID
LEFT JOIN
    FW.PRIVILEGE_USAGES pu
ON
    pu.TARGET_CENTER = il.center
    AND pu.TARGET_ID = il.id
    AND pu.TARGET_SUBID = il.SUBID
    AND pu.TARGET_SERVICE = 'InvoiceLine'
LEFT JOIN
    FW.PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
    left join FW.RELATIVES r on r.center = s.OWNER_CENTER and r.id = s.OWNER_ID and r.RTYPE = 3 and r.STATUS = 1
WHERE
    (
        il.TOTAL_AMOUNT !=0
        OR pg.GRANTER_SERVICE = 'CompanyAgreement')
    AND s.START_DATE BETWEEN exerpsysdate()-14 AND exerpsysdate()
    and s.center in($$scope$$)