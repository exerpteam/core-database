-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI') - 30), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS cutDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT DISTINCT
    E.IDENTITY  AS CARDNO,
    1           AS CARDSTATUS,
   P.FIRSTNAME as NAME,
   P.LASTNAME
FROM
    ENTITYIDENTIFIERS E
JOIN PARAMS params ON params.CenterID = E.REF_CENTER
JOIN
    PERSONS P
ON
    (
        E.REF_CENTER = P.CENTER
        AND E.REF_ID = P.ID
        AND E.REF_TYPE = 1
        AND E.ENTITYSTATUS = 1)
LEFT JOIN
    SUBSCRIPTIONS S
ON
    (
        E.REF_CENTER = S.OWNER_CENTER
        AND E.REF_ID = S.OWNER_ID
        AND S.STATE IN (2,8)
        AND S.SUB_STATE != 9)
WHERE
    (
        S.CENTER IS NOT NULL
        AND s.CENTER > 200
        AND s.CENTER < 600 )
    OR (
        E.REF_CENTER > 200
        AND E.REF_CENTER < 600
        AND (
            E.START_TIME >= params.cutDate))
    AND E.IDMETHOD IN (1,4)
