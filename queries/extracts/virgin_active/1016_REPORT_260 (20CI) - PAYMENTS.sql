SELECT
    inv.CENTER || 'inv' || inv.ID PAYMENTID,
    inv.CENTER                    SITEID,
    'POS'                         TYPE,
    p.EXTERNAL_ID                 PERSONID,
    TO_CHAR(crt.AMOUNT ,'FM99999999999999999990.00') AMOUNT,
    longToDateC(crt.TRANSTIME,p.center)                                                                                                                                                                                                        PAYMENTDATE,
    DECODE(crt.CRTTYPE,1,'CASH',2,'CHANGE',3,'RETURN ON CREDIT',4,'PAYOUT CASH',5,'PAID BY CASH AR ACCOUNT',6,'DEBIT CARD',7,'CREDIT CARD',8,'DEBIT OR CREDIT CARD',9,'GIFT CARD',10,'CASH ADJUSTMENT',11,'CASH TRANSFER',12,'PAYMENT AR',13,'CONFIG PAYMENT METHOD',14,'CASH REGISTER PAYOUT',15,'CREDIT CARD ADJUSTMENT',16,'CLOSING CASH ADJUST',17,'VOUCHER',18,'PAYOUT CREDIT CARD',19,'TRANSFER BETWEEN REGISTERS',20,'CLOSING CREDIT CARD ADJ',21,'TRANSFER BACK CASH COINS','UNKNOWN') DESCRIPTION,
    'SETTLED'                                                                                                                                                                                                        PAYMENTSTATUS
FROM
    INVOICES inv
LEFT JOIN
    CASHREGISTERTRANSACTIONS crt
ON
    crt.PAYSESSIONID = inv.PAYSESSIONID
    AND crt.CENTER = inv.CASHREGISTER_CENTER
    AND crt.ID = inv.CASHREGISTER_ID
LEFT JOIN
    AR_TRANS art
ON
    art.REF_TYPE = 'INVOICE'
    AND art.REF_CENTER = inv.CENTER
    AND art.REF_ID = inv.ID
LEFT JOIN
    PERSONS pold
ON
    pold.CENTER = crt.CUSTOMERCENTER
    AND pold.ID = crt.CUSTOMERID
LEFT JOIN
    PERSONS p
ON
    p.CENTER = pold.CURRENT_PERSON_CENTER
    AND p.ID = pold.CURRENT_PERSON_ID
WHERE
    art.CENTER IS NULL
	and inv.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'GB')
UNION ALL
SELECT
    inv.CENTER || 'inv' || inv.ID PAYMENTID,
    inv.CENTER ,
    CASE
        WHEN crt.CENTER IS NOT NULL
        THEN 'POS'
        ELSE 'ACCOUNT'
    END AS TYPE,
    p.EXTERNAL_ID ,
    to_char(artm.AMOUNT,'FM99999999999999999990.00'),
    exerpRO.longToDate(artm.ENTRY_TIME) ,
    CASE
        WHEN crt.CENTER IS NOT NULL
        THEN DECODE(crt.CRTTYPE,1,'CASH',2,'CHANGE',3,'RETURN ON CREDIT',4,'PAYOUT CASH',5,'PAID BY CASH AR ACCOUNT',6,'DEBIT CARD',7,'CREDIT CARD',8,'DEBIT OR CREDIT CARD',9,'GIFT CARD',10,'CASH ADJUSTMENT',11,'CASH TRANSFER',12,'PAYMENT AR',13,'CONFIG PAYMENT METHOD',14,'CASH REGISTER PAYOUT',15,'CREDIT CARD ADJUSTMENT',16,'CLOSING CASH ADJUST',17,'VOUCHER',18,'PAYOUT CREDIT CARD',19,'TRANSFER BETWEEN REGISTERS',20,'CLOSING CREDIT CARD ADJ',21,'TRANSFER BACK CASH COINS','UNKNOWN')
        ELSE 'PAYMENT AR'
    END AS PAYMENT_TYPE,
    'SETTLED'
FROM
    ART_MATCH artm
JOIN
    AR_TRANS artPaid
ON
    artPaid.CENTER = artm.ART_PAID_CENTER
    AND artPaid.ID = artm.ART_PAID_ID
    AND artPaid.SUBID = artm.ART_PAID_SUBID
JOIN
    AR_TRANS artPaying
ON
    artPaying.CENTER = artm.ART_PAYING_CENTER
    AND artPaying.ID = artm.ART_PAYING_ID
    AND artPaying.SUBID = artm.ART_PAYING_SUBID
JOIN
    INVOICES inv
ON
    artPaid.REF_TYPE = 'INVOICE'
    AND inv.CENTER = artPaid.REF_CENTER
    AND inv.ID = artPaid.REF_ID
LEFT JOIN
    CASHREGISTERTRANSACTIONS crt
ON
    crt.ARTRANSCENTER = artPaying.CENTER
    AND crt.ARTRANSID = artPaying.ID
    AND crt.ARTRANSSUBID = artPaying.SUBID
    AND crt.CRTTYPE IN (1,6,7,8,9,13)
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = artPaid.CENTER
    AND ar.ID = artPaid.ID
JOIN
    PERSONS pold
ON
    pold.CENTER = ar.CUSTOMERCENTER
    AND pold.ID = ar.CUSTOMERID
JOIN
    PERSONS p
ON
    p.CENTER = pold.CURRENT_PERSON_CENTER
    AND p.ID = pold.CURRENT_PERSON_ID
WHERE
    artm.CANCELLED_TIME IS NULL
	and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'GB')