WITH params AS MATERIALIZED
(
        SELECT
                dateToLongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) as fromDate,
                dateToLongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),c.id)-1 as toDate,
                c.id
        FROM centers c
		WHERE c.id IN (:Scope)
)
SELECT
        c.person_center || 'p' || c.person_id AS personId,
(CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END) AS currentstatus,
c.checkin_center,
cc.name,
TO_CHAR(longtodateC(c.checkin_time, c.checkin_center), 'YYYY-MM-dd HH24:MI') AS checkin_datetime,

        (CASE c.checkin_result
                WHEN 0 THEN 'Undefined' 
                WHEN 1 THEN 'accessGranted' 
                WHEN 2 THEN 'Staff Manual CheckedIn' 
                WHEN 3 THEN 'accessDenied' 
                ELSE 'Undefined'
        END) AS CheckIn_Result,
        (CASE   WHEN c.origin=0 THEN 'Unknown'
                WHEN c.origin=1 AND c.checkin_result=2 THEN 'Kiosk'
                WHEN c.origin=1 THEN 'Membercard'
                WHEN c.origin=2 THEN 'Offline'
                WHEN c.origin=3 THEN 'External'
                WHEN c.origin=4 THEN 'QR'
                WHEN c.origin=5 THEN 'Legacy'
                ELSE 'Undefined'
        END) AS origin,CASE
        WHEN IDENTITY_METHOD = 1
        THEN 'Barcode'
        WHEN IDENTITY_METHOD = 2
        THEN 'MagneticCard'
        WHEN IDENTITY_METHOD = 4
        THEN 'RFCard'
        WHEN IDENTITY_METHOD = 5
        THEN 'Pin'
        WHEN IDENTITY_METHOD = 6
        THEN 'AntiDrown'
        WHEN IDENTITY_METHOD = 7
        THEN 'QRCode'
        WHEN IDENTITY_METHOD = 8
        THEN 'ExternalSystem'
        ELSE IDENTITY_METHOD::text
    END AS "Identify Method"
FROM purefitnessus.checkins c
JOIN params par ON c.checkin_center = par.id
JOIN centers cc ON cc.id = c.checkin_center
JOIN persons p ON c.person_center = p.center AND c.person_id = p.id
WHERE
        c.checkin_time between par.fromDate AND par.toDate
ORDER BY 2