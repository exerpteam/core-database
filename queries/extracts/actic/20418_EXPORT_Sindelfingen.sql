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
    'actic'                AS system,
    E.IDENTITY             AS MEDIUMNUMBER,
    725 || 'p' || E.REF_ID AS MEMBERNUMBER,
    P.FIRSTNAME            AS FIRSTNAME,
    P.LASTNAME,
    P.ADDRESS1 AS STREET,
    P.ZIPCODE  AS PLZ,
    P.CITY,
    ''                 AS PICTUREPATH,
    ''                 AS RESERVE,
    'Bad+Sindelfingen' AS TARIF
FROM
    ENTITYIDENTIFIERS E
JOIN
	PARAMS params ON params.CenterID = e.REF_CENTER
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
    AND s.CENTER = 725)
OR  (
        E.REF_CENTER = 725
    AND (
            E.START_TIME >= params.cutDate))
