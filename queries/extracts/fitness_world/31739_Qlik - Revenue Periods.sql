-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            DECODE($$offset$$,0,0,dateToLongC(TO_CHAR(TRUNC(exerpsysdate()-$$offset$$), 'YYYY-MM-dd HH24:MI'),100)) AS from_time,
            dateToLongC(TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-dd HH24:MI'),100)                                   AS to_time
        FROM
            dual
    )
SELECT
    sppl.INVOICELINE_CENTER || 'inv' || sppl.INVOICELINE_ID || 'ln' || sppl.INVOICELINE_SUBID    SALES_LINE_ID,
    TO_CHAR(spp.FROM_DATE,'yyyy-MM-dd')                                                          FROM_DATE,
    TO_CHAR(spp.TO_DATE,'yyyy-MM-dd')                                                            TO_DATE,
    ROUND(il.TOTAL_AMOUNT, 2)                                                                    TOTAL_AMOUNT,
    il.RATE                                                                                      VAT_RATE,
    spp.TO_DATE-spp.FROM_DATE +1                                                                 PERIOD_DAYS,
    'SUBSCRIPTION_PERIOD'                                                                        SOURCE_TYPE,
    spp.center||'ss'||spp.id||'id'||spp.SUBID                                                    SOURCE_ID,
    DECODE (spp.SPP_STATE, 1,'ACTIVE', 2,'CANCELLED','UNKNOWN')                                  as STATE,
    longtodate(inv.TRANS_TIME)                                                                AS BOOK_DATE
FROM
    params,SUBSCRIPTIONPERIODPARTS spp
JOIN
    SUBSCRIPTIONS s
ON
    s.center = spp.CENTER
    AND s.id = spp.id
JOIN
    SPP_INVOICELINES_LINK sppl
ON
    sppl.PERIOD_CENTER = spp.CENTER
    AND sppl.PERIOD_ID = spp.id
    AND sppl.PERIOD_SUBID = spp.SUBID
JOIN
    PERSONS p
ON
    p.center = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
JOIN
    PERSONS cp
ON
    cp.center = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
JOIN
    INVOICELINES il
ON
    il.center = sppl.INVOICELINE_CENTER
    AND il.ID = sppl.INVOICELINE_ID
    AND il.SUBID =sppl.INVOICELINE_SUBID
JOIN
    INVOICES inv
ON
    inv.CENTER = il.center
    AND inv.id = il.id
LEFT JOIN
    CONVERTER_ENTITY_STATE ces
ON
    ces.ENTITYTYPE = 'person'
    AND ces.NEWENTITYCENTER = p.center
    AND ces.NEWENTITYID = p.ID
    AND ces.LASTUPDATED >longtodate(spp.ENTRY_TIME- (1000*60))
    and ces.WRITERNAME = 'ClubLeadJournalWriter'
WHERE
    ces.LASTUPDATED IS NULL
    AND spp.ENTRY_TIME between params.from_time and params.to_time
and cp.center in ($$scope$$)