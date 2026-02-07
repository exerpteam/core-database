SELECT
    p.EXTERNAL_ID        AS "External ref",
	CASE 
	 WHEN c.IDENTITY_METHOD = 1 THEN 'BARCODE'
	 WHEN c.IDENTITY_METHOD = 2 THEN 'MAGNETIC_CARD'
	 WHEN c.IDENTITY_METHOD = 3 THEN 'SSN'
	 WHEN c.IDENTITY_METHOD = 4 THEN 'Fob'
	 WHEN c.IDENTITY_METHOD = 5 THEN 'PIN'
	 WHEN c.IDENTITY_METHOD = 7 THEN 'QR'
	 ELSE 'Undefined'
	END AS "PIN/QR flag",
    TO_CHAR(longtodateC(c.CHECKIN_TIME,c.CHECKIN_CENTER),'DD/MM/YY HH24:MI:SS')      AS "Checkin Time",
    TO_CHAR(longtodateC(c.CHECKOUT_TIME,c.CHECKIN_CENTER),'DD/MM/YY HH24:MI:SS')     AS "Checkout Time",
    c.CHECKIN_CENTER                                                                 AS "Checkin center",
    CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL STAFF'
        ELSE 'UNKNOWN'
    END AS PersonType	
FROM
    checkins c
JOIN
    PERSONS p
ON
    c.PERSON_CENTER = p.CENTER
    AND c.PERSON_ID = p.ID
WHERE
    c.CHECKIN_TIME >= $$From_Date$$
    AND c.CHECKIN_TIME < $$From_To$$ + 24*3600*1000
    AND c.CHECKIN_CENTER IN ($$Scope$$)