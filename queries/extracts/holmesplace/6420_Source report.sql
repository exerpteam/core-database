SELECT DISTINCT
    DECODE(pea.TXTVALUE,NULL,' Total',pea.TXTVALUE)                       source,
pea.MIMETYPE,
    SUM(DECODE(p.STATUS,0,1,6,1,9,1,0))                                           "Leads and Prospects",
    decode(totals.l,0,'0.00%',DECODE(TO_CHAR(SUM(DECODE(p.STATUS,0,1,6,1,0))*100/totals.l,'FM990.00')||'%','%','100%',TO_CHAR(SUM(DECODE(p.STATUS,0,1,6,1,0))*100/totals.l,'FM990.00')||'%'))     AS "Leads and Prospects Precentage",
    SUM(DECODE(p.STATUS,1,1,3,1,0))                                          Members,
   decode(totals.m,0,'0.00%', DECODE(TO_CHAR(SUM(DECODE(p.STATUS,1,1,3,1,0)) *100/totals.m,'FM990.00')||'%','%','100%',TO_CHAR(SUM(DECODE(p.STATUS,1,1,3,1,0)) *100/totals.m,'FM990.00')||'%')) AS Members_Precentage,
    COUNT(*)                                                              AS Total
    /*,
    DECODE(TO_CHAR(COUNT(*)*100/totals.a,'FM990.00')||'%','%','100%',TO_CHAR(COUNT(*)*100/totals.a,'FM990.00')||'%') AS Precentage*/
FROM
    persons p
JOIN
    PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.center
    AND pea.PERSONID = p.id
    AND pea.name = 'SOURCE'
    and pea.TXTVALUE is not null
LEFT JOIN
    PERSON_EXT_ATTRS pea2
ON
    pea2.PERSONCENTER = p.center
    AND pea2.PERSONID = p.id
    AND pea2.name = 'CREATION_DATE'
CROSS JOIN
    (
        SELECT
            SUM(DECODE(p.STATUS,0,1,6,1,0)) L,
            SUM(DECODE(p.STATUS,1,1,3,1,0))m
        FROM
            persons p
        JOIN
            PERSON_EXT_ATTRS pea
        ON
            pea.PERSONCENTER = p.center
            AND pea.PERSONID = p.id
            AND pea.name = 'SOURCE'
            and pea.TXTVALUE is not null
        LEFT JOIN
            PERSON_EXT_ATTRS pea2
        ON
            pea2.PERSONCENTER = p.center
            AND pea2.PERSONID = p.id
            AND pea2.name = 'CREATION_DATE'
        WHERE
            to_date(pea2.TXTVALUE,'yyyy-MM-dd') BETWEEN $$from_date$$ AND $$to_date$$
            AND p.center IN ($$scope$$)) totals
WHERE
    to_date(pea2.TXTVALUE,'yyyy-MM-dd') BETWEEN $$from_date$$ AND $$to_date$$
    AND p.center IN ($$scope$$)
GROUP BY
    grouping sets ( (pea.TXTVALUE,pea.MIMETYPE,totals.l,totals.m), ()) order by 1 desc