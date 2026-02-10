-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    /*+ NO_BIND_AWARE */
    a.center  ClubNumber,
    c.NAME    AS "Center Name",
    c.ZIPCODE AS "Center Post Code",
    a."Region Post Code",
    a."Member Count"
FROM
    (
        SELECT
            center,
            CASE
                WHEN SUBSTR(RE,-1,1)=' '
                THEN SUBSTR(RE,0,LENGTH(RE)-1)
                ELSE RE
            END      AS "Region Post Code",
            COUNT(*) AS "Member Count"
        FROM
            (
                SELECT DISTINCT
                    p.CENTER,
                    p.ID,
                    SUBSTR(p.ZIPCODE,0,LENGTH(p.ZIPCODE)-3) RE
                FROM
                    PUREGYM.PERSONS p
                JOIN
                    PUREGYM.SUBSCRIPTIONS s
                ON
                    s.OWNER_CENTER = p.CENTER
                    AND s.OWNER_ID = p.id
                    AND s.STATE IN (2,4)
                JOIN
                    PUREGYM.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND st.id = s.SUBSCRIPTIONTYPE_ID
                    AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
                WHERE
                    p.STATUS IN (1,3))
        GROUP BY
            center,
            CASE
                WHEN SUBSTR(RE,-1,1)=' '
                THEN SUBSTR(RE,0,LENGTH(RE)-1)
                ELSE RE
            END ) a
JOIN
    PUREGYM.CENTERS c
ON
    c.id = a.center
WHERE
    c.id IN ($$scope$$)