-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.CENTER || 'p' || p.ID AS "PersonId",
    c.COUNTRY,
    CASE p.status
			WHEN 0 THEN 'LEAD'
			WHEN 1 THEN 'ACTIVE'
			WHEN 2 THEN 'INACTIVE'
			WHEN 3 THEN 'TEMPORARYINACTIVE'
			WHEN 4 THEN 'TRANSFERRED'
			WHEN 5 THEN 'DUPLICATE'
			WHEN 6 THEN 'PROSPECT'
			WHEN 7 THEN 'DELETED'
			WHEN 8 THEN 'ANONYMIZED'
			WHEN 9 THEN 'CONTACT'
			ELSE 'Undefined'
		END As "P Status",
    ch.ID   AS "ClearingHouse ID",
    ch.NAME AS "ClearingHouse Name",
    (
        CASE pag.STATE
            WHEN 2
            THEN 'SENT'
            WHEN 3
            THEN 'FAILED'
            WHEN 4
            THEN 'OK'
            WHEN 6
            THEN 'ENDED, CLEARINGHOUSE'
            WHEN 10
            THEN 'ENDED, CREDITOR'
            ELSE 'UNKNOWN'
        END) AS "Agreement State",
    pag.EXPIRATION_DATE,
    pag.REF,
    pag.CLEARINGHOUSE_REF,
    p.EXTERNAL_ID,
    (CASE
        WHEN c.country = 'AT' THEN CAST(pag.REF AS NUMERIC)
        ELSE NULL
    END) AS "REF_AUSTRIA"
FROM
    PERSONS p
JOIN
    HP.ACCOUNT_RECEIVABLES ar
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
    AND ar.AR_TYPE = 4
JOIN
    HP.PAYMENT_ACCOUNTS pac
ON
    ar.CENTER = pac.CENTER
    AND ar.ID = pac.ID
JOIN
    HP.PAYMENT_AGREEMENTS pag
ON
    pac.ACTIVE_AGR_CENTER = pag.CENTER
    AND pac.ACTIVE_AGR_ID = pag.ID
    AND pac.ACTIVE_AGR_SUBID = pag.SUBID
JOIN
    HP.CLEARINGHOUSES ch
ON
    pag.CLEARINGHOUSE = ch.ID
JOIN
    hp.centers c 
ON
    c.id = p.center
WHERE
    p.STATUS NOT IN (4,5,7,8)
        
    AND pag.CLEARINGHOUSE IN ( 1602, --CC AMG
                              1201, --CC BFD
                              5805, --CC BMS
                              2002, --CC BPL
                              3403, --CC CPL
                              6604, --CC ESS
                              802, --CC GMT
                              4809, --CC GVA
                              201, --CC HAM
                              7204, --CC HPDE
                              2202, --CC HUT
                              1408, --CC KOE
                              4814, --CC LAU
                              1405, --CC LBK
                              1809, --CC MIL
                              601, --CC NWT
                              6207, --CC OBK
                              1801, --CC OSK
                              5405, --CC PNTL
                              1003, --CC POP
                              1411, --CC PPL
                              4405, --CC REG
                              4605, --CC SEE
                              2406, --CC SST
                              2206, --CC VIC
                              4804, --CC ZUR
7608, --CC AMG Adyen
8005, -- CC BFD Adyen
7804, -- CC BMS Adyen
8207, -- CC BPL Adyen
7609, -- CC CPL Adyen
8004, -- CC ESS Adyen
7805, -- CC GMT Adyen
8008, -- CC GVA Adyen
7605, -- CC HAM Adyen
8206, -- CC HPDE Adyen
7809, -- CC HUT Adyen
8006, -- CC KOE Adyen
8009, -- CC LAU Adyen
7606, -- CC LBK Adyen
8208, -- CC MIL Adyen
7607, -- CC NWT Adyen
8204, -- CC OBK Adyen
8205, -- CC OSK Adyen
7807, -- CC POP Adyen
7806, -- CC PPL Adyen
7808, -- CC SEE Adyen
8007, -- CC SST Adyen
7810, -- CC VIC Adyen
8010 -- CC ZUR Adyen
)
	AND c.COUNTRY IN (:listCountries)