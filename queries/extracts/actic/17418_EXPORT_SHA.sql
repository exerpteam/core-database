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
SELECT DISTINCT ('x'||lpad(CONCAT( CONCAT( SUBSTR( CONCAT(
    CASE MOD(LENGTH( to_hex(E.IDENTITY::bigint) ), 2 )
        WHEN 1
        THEN '0'
        WHEN 0
        THEN ''
    END, to_hex(E.IDENTITY::bigint) ), 7, 2 ), SUBSTR( CONCAT (
    CASE MOD(LENGTH( to_hex(E.IDENTITY::bigint) ), 2 )
        WHEN 1
        THEN '0'
        WHEN 0
        THEN ''
    END, to_hex(E.IDENTITY::bigint) ), 5, 2 ) ), CONCAT ( SUBSTR( CONCAT(
    CASE MOD(LENGTH( to_hex(E.IDENTITY::bigint) ), 2 )
        WHEN 1
        THEN '0'
        WHEN 0
        THEN ''
    END, to_hex(E.IDENTITY::bigint) ), 3, 2 ), SUBSTR( CONCAT (
    CASE MOD(LENGTH( to_hex(E.IDENTITY::bigint) ), 2 )
        WHEN 1
        THEN '0'
        WHEN 0
        THEN ''
    END, to_hex(E.IDENTITY::bigint) ), 1, 2 ) ) ),16,'0'))::BIT(64)::bigint::VARCHAR AS
    CHIPID_BYTE_SWAPPED
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
    SUBSCRIPTIONS S
ON
    (
        E.REF_CENTER = S.OWNER_CENTER
    AND E.REF_ID = S.OWNER_ID
    AND S.STATE IN (2,8)
    AND S.SUB_STATE != 9)
LEFT JOIN
    PERSON_EXT_ATTRS oldId
ON
    oldId.PERSONCENTER = P.CENTER
AND oldId.PERSONID = P.ID
AND oldId.NAME = '_eClub_OldSystemPersonId'
WHERE
    (
        S.CENTER IS NOT NULL
    AND s.CENTER = 728)
OR  (
        E.REF_CENTER = 728
    AND (
            E.START_TIME >= params.cutDate))
