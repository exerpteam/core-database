

SELECT
    c.name AS center,
    (
        CASE il.PERSON_CENTER||'p'||il.PERSON_ID
            WHEN 'p'
            THEN ' No Member'
            ELSE il.PERSON_CENTER||'p'||il.PERSON_ID
        END) AS MemberID,
    p.FULLNAME,
    SUM(il.TOTAL_AMOUNT - COALESCE(cnl.TOTAL_AMOUNT,0)) AS revenue,
    TO_CHAR(longtodate(inv.TRANS_TIME),'MM')            AS "Month"
FROM
    HP.INVOICELINES il
LEFT JOIN
    HP.CREDIT_NOTE_LINES cnl
ON
    cnl.INVOICELINE_CENTER = il.CENTER
    AND cnl.INVOICELINE_ID = il.ID
    AND cnl.INVOICELINE_SUBID = il.SUBID
JOIN
    HP.INVOICES inv
ON
    inv.CENTER = il.CENTER
    AND inv.id = il.ID
LEFT JOIN
    HP.PERSONS p
ON
    p.center = il.PERSON_CENTER
    AND p.id = il.PERSON_ID
JOIN
    HP.CENTERS c
ON
    c.id = il.PERSON_CENTER
WHERE
    inv.TRANS_TIME BETWEEN $$from_date$$ AND $$to_date$$
    AND il.CENTER IN ($$scope$$)
    --and il.PERSON_CENTER IS NULL
GROUP BY
    c.name,
    il.PERSON_CENTER,
    il.PERSON_ID,
    p.FULLNAME,
    TO_CHAR(longtodate(inv.TRANS_TIME),'MM')
ORDER BY
    1

