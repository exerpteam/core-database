WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            $$Membercard$$ as membercard
        FROM
            DUAL
    )
SELECT
    e.REF_CENTER ||'p'|| e.REF_ID AS "MEMBER ID",
    p.FULLNAME,
    DECODE(e.IDMETHOD, 1, 'BARCODE', 2, 'MAGNETIC_CARD', 3, 'SSN', 4, 'RFID_CARD', 5, 'MEMBER_ID','UNKNOWN')        AS "IDMETHOD",
    DECODE(e.ENTITYSTATUS, 1, 'OK', 2, 'STOLEN', 3, 'MISSING', 4, 'BLOCKED', 5, 'BROKEN', 6, 'RETURNED', 'UNKNOWN') AS "ENTITY STATUS",
    e.IDENTITY
FROM
    params,ENTITYIDENTIFIERS e
LEFT JOIN
    PERSONS p
ON
    p.CENTER = e.REF_CENTER
    AND p.ID = e.REF_ID
WHERE
    e.IDENTITY LIKE '%'||params.membercard||'%'