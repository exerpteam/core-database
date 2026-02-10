-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    en.ref_center ||'p'|| en.ref_id as PERSONKEY,
    en.identity AS CARDNUMBER,
    CASE en.idmethod
        WHEN 1
        THEN 'BARCODE'
        WHEN 4
        THEN 'RFID'
        ELSE 'UNKNOWN'
    END AS CARDTYPE,
    CASE en.entitystatus
        WHEN 1
        THEN 'OK'
        WHEN 2
        THEN 'STOLEN'
        WHEN 3
        THEN 'MISSING'
        WHEN 4
        THEN 'BLOCKED'
        WHEN 5
        THEN 'BROKEN'
        WHEN 5
        THEN 'RETURNED'
        WHEN 8
        THEN 'DELETED'
        ELSE 'UNKNOWN'
    END AS STATUS
FROM
    entityidentifiers en
WHERE
    en.ref_type = 1
	AND en.entitystatus != 8