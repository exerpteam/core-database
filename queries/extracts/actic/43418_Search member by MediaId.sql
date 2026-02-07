/**
* Creator: Henrik Håkanson
* Purpose: Find member by MediaId (number printed on card).
* ServiceTicket: Actic Internal Ticket 594253
*
*/
SELECT DISTINCT
    TO_CHAR( TO_NUMBER( CONCAT( CONCAT( SUBSTR( CONCAT(
        CASE MOD(LENGTH( TRIM(TO_CHAR(E.IDENTITY, LPAD('X',LENGTH(E.IDENTITY),'X'))) ), 2 )
            WHEN 1
            THEN '0'
            WHEN 0
            THEN ''
        END, TRIM(TO_CHAR(E.IDENTITY, LPAD('X',LENGTH(E.IDENTITY),'X'))) ), 7, 2 ), SUBSTR( CONCAT
    (
        CASE MOD(LENGTH( TRIM(TO_CHAR(E.IDENTITY, LPAD('X',LENGTH(E.IDENTITY),'X'))) ), 2 )
            WHEN 1
            THEN '0'
            WHEN 0
            THEN ''
        END, TRIM(TO_CHAR(E.IDENTITY, LPAD('X',LENGTH(E.IDENTITY),'X'))) ), 5, 2 ) ), CONCAT
    ( SUBSTR( CONCAT(
        CASE MOD(LENGTH( TRIM(TO_CHAR(E.IDENTITY, LPAD('X',LENGTH(E.IDENTITY),'X'))) ), 2 )
            WHEN 1
            THEN '0'
            WHEN 0
            THEN ''
        END, TRIM(TO_CHAR(E.IDENTITY, LPAD('X',LENGTH(E.IDENTITY),'X'))) ), 3, 2 ), SUBSTR( CONCAT
    (
        CASE MOD(LENGTH( TRIM(TO_CHAR(E.IDENTITY, LPAD('X',LENGTH(E.IDENTITY),'X'))) ), 2 )
            WHEN 1
            THEN '0'
            WHEN 0
            THEN ''
        END, TRIM(TO_CHAR(E.IDENTITY, LPAD('X',LENGTH(E.IDENTITY),'X'))) ), 1, 2 ) ) ), LPAD('X',
    LENGTH(E.IDENTITY),'X') )) AS CHIPID_BYTE_SWAPPED,
	p.CENTER || 'p' || p.ID AS MEMBER_ID,
	p.FULLNAME AS NAME,
	E.IDENTITY AS MEDIA_ID
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
LEFT JOIN
    PERSON_EXT_ATTRS oldId
ON
    oldId.PERSONCENTER = P.CENTER
AND oldId.PERSONID = P.ID
AND oldId.NAME = '_eClub_OldSystemPersonId'
WHERE
	E.IDENTITY IN (:mediaId)