-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI') - 20), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS cutDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
    E.IDENTITY    AS cardno,
    MAX(P.CENTER) AS sit_nr,
    MAX(
        CASE
            WHEN st.ST_TYPE IS NOT NULL
            AND st.ST_TYPE = 0
            THEN 'Kontant'
            ELSE 'Autogiro'
        END)         AS payment_type,
    MAX(P.FIRSTNAME) AS NAME,
    MAX(P.LASTNAME)  AS lastname,
    MAX(P.ADDRESS1)  AS address,
    MAX(P.ZIPCODE)   AS zip,
    MAX(P.CITY)      AS city,
    MAX(
        CASE
            WHEN (P.SSN IS NOT NULL)
            THEN trim(REPLACE(TO_CHAR((P.SSN) / 10000, '00000000.0000'), '.', '-'))
            WHEN pea.TXTVALUE IS NOT NULL
            THEN trim(pea.txtvalue)
            ELSE NULL
        END)                                          AS VATNO,
    MAX(TO_CHAR(s.end_date, 'YYYY-MM-DD HH24:MI:SS')) AS enddate
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
    AND E.IDMETHOD = 1
    AND E.ENTITYSTATUS = 1)
LEFT JOIN
    PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.center
AND pea.PERSONID = p.id
AND pea.name = '_eClub_OldSystemPersonId'
LEFT JOIN
    SUBSCRIPTIONS S
ON
    (
        E.REF_CENTER = S.OWNER_CENTER
    AND E.REF_ID = S.OWNER_ID
    AND S.STATE IN (2)
    AND S.SUB_STATE != 9)
LEFT JOIN
    SUBSCRIPTIONTYPES st
ON
    st.center = S.SUBSCRIPTIONTYPE_CENTER
AND st.id = S.SUBSCRIPTIONTYPE_ID
WHERE
    (
        S.CENTER IS NOT NULL
    AND s.CENTER = 23)
OR  (
        E.REF_CENTER = 23
    AND (
            E.START_TIME >= params.cutDate))
GROUP BY
    E.IDENTITY