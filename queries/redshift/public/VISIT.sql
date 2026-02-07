SELECT
    c.ID             "ID",
    c.CHECKIN_CENTER "CENTER_ID",
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
            OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END AS                                                        "PERSON_ID",
    p.CENTER                                                      "HOME_CENTER_ID",
    c.CHECKIN_TIME  AS                                            "CHECK_IN_DATETIME",
    c.CHECKOUT_TIME AS                                            "CHECK_OUT_DATETIME",
	CASE 
		WHEN c.CHECKIN_RESULT = 1 THEN 'ACCESS_GRANTED'
		WHEN c.CHECKIN_RESULT = 2 THEN 'PRESENCE_REGISTERED'
		WHEN c.CHECKIN_RESULT = 3 THEN 'ACCESS_DENIED'
		ELSE 'UNKNOWN'
	END AS "RESULT", 
    CAST(CAST (c.CARD_CHECKED_IN AS INT) AS SMALLINT) AS          "CARD_CHECKED_IN",
    CASE
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
        ELSE 'Undefined'
    END AS          "IDENTITY_METHOD",
    c.last_modified "ETS"
FROM
    CHECKINS c
LEFT JOIN
    PERSONS p
ON
    p.CENTER = c.PERSON_CENTER
AND p.id = c.PERSON_ID
