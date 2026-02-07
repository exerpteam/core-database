SELECT
    p.CENTER || 'p' || p.ID                                AS MemberID,
    p.FIRSTNAME|| ' ' || p.MIDDLENAME || ' ' || p.LASTNAME AS CompanyName,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ZIPCODE,
    p.CITY,
    p.COUNTRY,
    pea1.TXTVALUE   AS ContactinfoEmail,
    pea2.TXTVALUE   AS Invoicebyemail,
    pr.REQ_DELIVERY AS PaymentExport
FROM
    PAYMENT_REQUESTS pr
JOIN
    PAYMENT_AGREEMENTS pa
ON
    pr.CENTER = pa.CENTER
    AND pr.ID = pa.ID
    AND pr.AGR_SUBID = pa.SUBID
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    pa.CENTER = ar.CENTER
    AND pa.ID = ar.ID
JOIN
    PERSONS p
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
LEFT JOIN
    PERSON_EXT_ATTRS pea1
ON
    p.CENTER = pea1.PERSONCENTER
    AND p.ID = pea1.PERSONID
    AND pea1.NAME = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS pea2
ON
    p.CENTER = pea2.PERSONCENTER
    AND p.ID = pea2.PERSONID
    AND pea2.NAME = '_eClub_InvoiceEmail'
WHERE
    p.SEX = 'C'
    AND pr.REQ_DELIVERY IN (310535,310532)