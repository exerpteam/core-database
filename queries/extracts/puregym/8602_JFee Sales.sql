-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    nvl(c.NAME,' Total') as Center,
    COUNT(DISTINCT inv.center||'inv'||inv.id||'il'||il.SUBID) AS "Jfee count"
FROM
    PUREGYM.subscriptions s
JOIN
    PUREGYM.INVOICELINES il
ON
    s.INVOICELINE_CENTER = il.CENTER
    AND s.INVOICELINE_ID = il.ID
    AND s.INVOICELINE_SUBID = il.SUBID
JOIN
    PUREGYM.INVOICES inv
ON
    inv.CENTER = il.CENTER
    AND inv.id = il.ID
JOIN
    PUREGYM.CENTERS c
ON
    inv.CENTER = c.ID
WHERE
    s.CREATION_TIME BETWEEN $$start_date$$ AND $$end_date$$
    AND s.STATE != 5
and (s.START_DATE<=s.END_DATE or s.END_DATE is null)
    and c.id in ($$scope$$)
  and il.TOTAL_AMOUNT !=0
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.SUBSCRIPTIONS s2
        WHERE
            s2.TRANSFERRED_CENTER =s.center
            AND s2.TRANSFERRED_ID = s.id)
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.CREDIT_NOTE_LINES cnl
        WHERE
            cnl.INVOICELINE_CENTER = il.CENTER
            AND cnl.INVOICELINE_ID = il.id
            AND cnl.INVOICELINE_SUBID = il.SUBID
            AND cnl.TOTAL_AMOUNT = il.TOTAL_AMOUNT)
GROUP BY
    grouping sets ( (C.name), () )