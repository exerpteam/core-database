SELECT
        prs.CENTER,
        prs.ID,
        prs.SUBID,
        p.FIRSTNAME,
        p.LASTNAME,
        p.center || 'p' || p.id AS "PERSONKEY",
        to_char(prs.ORIGINAL_DUE_DATE, 'YY-MM-DD') AS "DUE_DATE",
        pr.REQ_AMOUNT AS "REQ_AMOUNT",
        pr.FULL_REFERENCE AS "INVOICE_REF",
        prs.OPEN_AMOUNT AS "OPEN_AMOUNT"

FROM PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN ACCOUNT_RECEIVABLES ar ON ar.CENTER = prs.CENTER AND ar.ID = prs.ID
JOIN PERSONS p ON p.CENTER = ar.CUSTOMERCENTER AND p.ID = ar.CUSTOMERID
JOIN PAYMENT_REQUESTS pr ON pr.center = prs.center and pr.ID = prs.ID and pr.SUBID = prs.SUBID
WHERE 
  pr.FULL_REFERENCE = (:REF)