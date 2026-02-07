-- This is the version from 2026-02-05
--  
SELECT
    *
FROM
    (
        SELECT
            p.CENTER,
            p.FIRSTNAME,
            p.LASTNAME,
            p.SEX,
            ROUND(months_between(exerpsysdate(),p.BIRTHDATE) / 12) AGE,
            p.BIRTHDATE,
            prod.NAME,
            s.BINDING_PRICE
        FROM
            PERSONS p
        JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.center
            AND s.OWNER_ID = p.id
            AND s.STATE IN (2)
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID 
            ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM <= $$number_of_rows$$