-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    p.fullname                                                                                                                                              AS PayerName,
    p.center ||'p'|| p.id                                                                                                                                   AS "Payer ID" ,
    P.EXTERNAL_ID                                                                                                                                           AS "Payer Old ID",
    pe.TXTVALUE                                                                                                                                             AS "_eClub_OldSystemPersonId",
    DECODE (p.persontype, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS "Payer Person Type" ,
    ART.AMOUNT                                                                                                                                              AS "Amount",
    LONGTODATE(art.ENTRY_TIME)                                                                                                                      AS "Transaction Entry",
    ART.DUE_DATE                                                                                                                                            AS "Payment Due",
    ART.TEXT      "Text",
    ART.COLLECTED "Collected",
    clh.NAME AS "Clearing House",
    pa.CREDITOR_ID,
    longtodate(pa.CREATION_TIME) AS "Agreement Created",
    pr.REF,
    pr.REQ_AMOUNT,
    pr.REQ_DATE,
    pr.XFR_AMOUNT,
    pr.XFR_DATE,
    pr.REQ_DELIVERY AS "File ID"
FROM
    PERSONS p
JOIN
    VA.AREA_CENTERS ac
ON
    ac.CENTER = p.CENTER
LEFT JOIN
    PERSON_EXT_ATTRS pe
ON
    pe.PERSONCENTER = p.CENTER
    AND pe.PERSONID = p.id
    AND pe.NAME = '_eClub_OldSystemPersonId'
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
    AND ar.CUSTOMERID = p.id
    AND ar.AR_TYPE = 4
JOIN
    PAYMENT_ACCOUNTS pm
ON
    pm.center = ar.center
    AND pm.id = ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pa
ON
    pm.ACTIVE_AGR_CENTER = pa.center
    AND pm.ACTIVE_AGR_ID = pa.id
    AND pm.ACTIVE_AGR_SUBID = pa.subid
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
    pr.CENTER = ar.CENTER
    AND pr.ID = ar.ID
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
JOIN
    AR_TRANS art
ON
    art.center = ar.center
    AND art.id = ar.id
JOIN
    (
        SELECT
            p.CURRENT_PERSON_CENTER,
            p.CURRENT_PERSON_ID,
            MAX(ces.LASTUPDATED) AS conv_dt
        FROM
            CONVERTER_ENTITY_STATE ces
        JOIN
            PERSONS p
        ON
            p.center = ces.NEWENTITYCENTER
            AND p.id = ces.NEWENTITYID
        WHERE
            ces.ENTITYTYPE = 'person'
            AND ces.LASTUPDATED IS NOT NULL
        GROUP BY
            p.CURRENT_PERSON_CENTER,
            p.CURRENT_PERSON_ID) conv
ON
    conv.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
    AND conv.CURRENT_PERSON_ID=p.CURRENT_PERSON_ID
JOIN
    VA.CLEARINGHOUSES clh
ON
    pa.CLEARINGHOUSE = clh.ID
WHERE
    ac.AREA = 24 -- Only in Italy
    AND conv.conv_dt >= TO_TIMESTAMP('2016-03-07 00:00', 'YYYY-MM-DD HH24:MI')
    AND ART.TEXT LIKE '%01/03/2016 - 31/03/2016 (Auto Renewal)%'
    AND ART.DUE_DATE > to_date('2016-03-01', 'YYYY-MM-DD')
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            VA.AR_TRANS art3
        WHERE
            art3.center = ar.center
            AND art3.id = ar.id
            AND ART3.TEXT LIKE '%01/02/2016 - 29/02/2016 (Auto Renewal)%')
ORDER BY
    pr.REQ_DELIVERY