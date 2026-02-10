-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI') - 30), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS cutDate,
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-40) AS cutDate2,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT DISTINCT
    E.IDENTITY AS CARDNO,
    CASE
        WHEN (CC.CENTER IS NOT NULL
            AND CC.STARTDATE < params.cutDate2)
        THEN 33
        WHEN (CC.CENTER IS NOT NULL
            AND CC.STARTDATE >= params.cutDate2)
        THEN 67
        WHEN (S.SUB_STATE = 9)
        THEN 65
        WHEN (E.ENTITYSTATUS != 1)
        THEN 3
        ELSE 1
    END AS CARDSTATUS,
    CASE
        WHEN (P.SSN IS NOT NULL
            AND LENGTH(p.ssn) = 12
            AND REGEXP_LIKE(p.SSN,'^[0-9]+$'))
        THEN REPLACE(TO_CHAR((P.SSN) / 10000, '00000000.0000'),'.', '-')
    END AS VATNO
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
    AND E.IDMETHOD = 1)
LEFT JOIN
    CASHCOLLECTIONCASES CC
ON
    (
        CC.PERSONCENTER = P.CENTER
    AND CC.PERSONID = P.ID
    AND CC.MISSINGPAYMENT = 1
    AND CC.CLOSED = 0)
LEFT JOIN
    SUBSCRIPTIONS S
ON
    (
        E.REF_CENTER = S.OWNER_CENTER
    AND E.REF_ID = S.OWNER_ID)
WHERE
    (
        P.CENTER,P.ID) NOT IN
    (
        SELECT
            P.CENTER,
            P.ID
        FROM
            ENTITYIDENTIFIERS E
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
            AND S.CENTER < 200)
        OR  (
                E.REF_CENTER < 200
            AND (
                    E.START_TIME >= params.cutDate)) )
AND P.CENTER < 500
AND P.SEX != 'C'
AND E.ENTITYSTATUS != 6