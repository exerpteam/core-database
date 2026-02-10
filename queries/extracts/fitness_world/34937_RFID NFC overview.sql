-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t1.CENTER,
        t1.NAME,
        t1.RFID_NFC,
        t1.NOT_RFID_NFC,
        t1.TOTAL,
        ROUND((t1.RFID_NFC/t1.TOTAL)*100,2) AS "NFC/RFID Percentage (%)"
FROM
   
        (SELECT
                p.CENTER,
                c.NAME,
                SUM(CASE
                        WHEN ei.IDMETHOD=4 THEN
                                1
                        ELSE
                                0
                END) AS RFID_NFC,
                SUM(CASE
                        WHEN ei.IDMETHOD=4 THEN
                                0
                        ELSE
                                1
                END) AS NOT_RFID_NFC,
                count(*) AS TOTAL
        FROM PERSONS p
        JOIN ENTITYIDENTIFIERS ei
                ON ei.REF_CENTER = p.CENTER 
                   AND ei.REF_ID = p.ID 
                   AND ei.ENTITYSTATUS = 1
        JOIN CENTERS c
                ON c.ID = p.CENTER
        WHERE p.STATUS IN (1,3)
              AND p.CENTER IN (:scope)
        GROUP BY
                p.CENTER,
                c.NAME
        ) t1