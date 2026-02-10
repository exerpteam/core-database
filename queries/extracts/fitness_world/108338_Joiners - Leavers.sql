-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center || 'p' || p.id AS "Member ID",
    p.ZIPCODE AS "Postal number",
    inv.CASHREGISTER_CENTER,
    p.FIRST_ACTIVE_START_DATE,
    s.END_DATE,
    CASE
        WHEN staff.fullname = 'Online Salg' THEN 'Api'
        ELSE 'club'
    END AS "Sale Source",
    CASE
        WHEN s.start_date BETWEEN TO_TIMESTAMP(:from_date) 
                             AND TO_TIMESTAMP(:to_date) THEN 1
        ELSE 0
    END AS "New Member",
    pr.NAME AS "Subscription name",
    il.TOTAL_AMOUNT AS "Joining fee paid",
    s.SUBSCRIPTION_PRICE,
    DECODE(st.ST_TYPE, 1, 'EFT', 0, 'Cash') AS "Subscription Type",
    pg.NAME AS "Primary Product Group"
FROM
    PERSONS p
JOIN
    PERSONS p1 ON p.CURRENT_PERSON_CENTER = p1.CENTER
               AND p.CURRENT_PERSON_ID = p1.ID
JOIN
    SUBSCRIPTIONS s ON s.OWNER_CENTER = p.center
                   AND s.OWNER_ID = p.id
                   AND (s.END_DATE >= s.START_DATE OR s.END_DATE IS NULL)
                   AND s.SUB_STATE != 6
JOIN
    SUBSCRIPTIONTYPES st ON st.center = s.SUBSCRIPTIONTYPE_CENTER
                         AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCTS pr ON pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
               AND pr.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCT_GROUP pg ON pg.id = pr.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN
    INVOICELINES il ON il.CENTER = s.INVOICELINE_CENTER
                    AND il.ID = s.INVOICELINE_ID
                    AND s.INVOICELINE_SUBID = il.SUBID
LEFT JOIN
    INVOICES inv ON inv.CENTER = il.CENTER
                AND inv.id = il.ID
LEFT JOIN
    CASHREGISTERS cr ON cr.CENTER = inv.CASHREGISTER_CENTER
                    AND cr.id = inv.CASHREGISTER_ID
LEFT JOIN
    EMPLOYEES emp ON emp.CENTER = inv.EMPLOYEE_CENTER
                  AND emp.id = inv.EMPLOYEE_ID
LEFT JOIN
    PERSONS staff ON staff.CENTER = emp.PERSONCENTER
                  AND staff.id = emp.PERSONID
WHERE
    (
        (
            s.END_DATE BETWEEN TO_TIMESTAMP(:from_date) 
                          AND TO_TIMESTAMP(:to_date)
        )
        OR 
        (
            s.CREATION_TIME BETWEEN TO_TIMESTAMP(:from_date)
                               AND TO_TIMESTAMP(:to_date)
        )
    )
ORDER BY
    st.ST_TYPE;
