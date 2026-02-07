-- This is the version from 2026-02-05
--  
SELECT
    p.center||'p'||p.id AS "Member ID",
    p.ZIPCODE           AS "Postal number",
    inv.CASHREGISTER_CENTER,
    p.FIRST_ACTIVE_START_DATE,
    s.END_DATE,
    CASE
        WHEN staff.fullname='Online Salg'
        THEN 'Api'
        ELSE 'club'
    END AS "Sale Source",
    CASE
        WHEN s.start_date BETWEEN exerpro.longtodate($$from_date$$) AND exerpro.longtodate($$to_date$$)
        THEN 1
        ELSE 0
    END             AS "New Member",
    pr.NAME         AS "Subscription name",
    il.TOTAL_AMOUNT AS "Joining fee paid",
    s.SUBSCRIPTION_PRICE,
    DECODE(st.ST_TYPE,1,'EFT',0,'Cash') AS "Subscription Type",
    pg.NAME                             AS "Primary Product Group"
FROM
    PERSONS p
JOIN
    PERSONS p1
ON
    p.CURRENT_PERSON_CENTER = p1.CENTER
    AND p.CURRENT_PERSON_ID = p1.ID
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.center
    AND s.OWNER_ID = p.id
    AND (s.END_DATE >= s.START_DATE or s.END_DATE is null)
    AND s.SUB_STATE != 6
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.center = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCT_GROUP pg
ON
    pg.id = pr.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN
    INVOICELINES il
ON
    il.CENTER = s.INVOICELINE_CENTER
    AND il.ID = s.INVOICELINE_ID
    AND s.INVOICELINE_SUBID = il.SUBID
LEFT JOIN
    INVOICES inv
ON
    inv.CENTER = il.CENTER
    AND inv.id = il.ID
LEFT JOIN
    CASHREGISTERS cr
ON
    cr.CENTER = inv.CASHREGISTER_CENTER
    AND cr.id = inv.CASHREGISTER_ID
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = inv.EMPLOYEE_CENTER
    AND emp.id = inv.EMPLOYEE_ID
LEFT JOIN
    PERSONS staff
ON
    staff.CENTER = emp.PERSONCENTER
    AND staff.id = emp.PERSONID
WHERE
    ( (
            s.END_DATE BETWEEN exerpro.longtodate($$from_date$$) AND exerpro.longtodate($$to_date$$) --ended now
/*            AND NOT EXISTS --leaver
            (
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS s2
                JOIN
                    PERSONS p12
                ON
                    s2.OWNER_CENTER = p12.center
                    AND s2.OWNER_ID = p12.id
                WHERE
                    p12.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
                    AND p12.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
                    AND s2.OWNER_CENTER = s.OWNER_CENTER
                    AND s2.OWNER_ID = s.OWNER_ID
                    AND (
                        (s2.END_DATE > s.END_DATE  OR s2.END_DATE IS NULL)
                        AND s2.END_DATE >=s2.START_DATE
                        ))*/
                        )
        OR (
            s.CREATION_TIME BETWEEN $$from_date$$ AND $$to_date$$ --started now
            /*AND NOT EXISTS --joiner
            (
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS s3
                JOIN
                    PERSONS p11
                ON
                    s3.OWNER_CENTER = p11.center
                    AND s3.OWNER_ID = p11.id
                WHERE
                    p11.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
                    AND p11.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
                    AND s3.START_DATE < s.START_DATE
                    AND (
                        (s3.START_DATE <= s3.END_DATE)
                        OR s3.END_DATE IS NULL))*/
                        ))
ORDER BY
    st.ST_TYPE