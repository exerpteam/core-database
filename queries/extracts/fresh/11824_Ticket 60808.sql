SELECT
    SUM(art.AMOUNT) amount,
    nvl2(rel.CENTER,1,0) other_payer,
--    CASE
--        WHEN art.REF_TYPE = 'INVOICE'
--        THEN invl.PERSON_CENTER || 'p' || invl.PERSON_ID
--        ELSE cnl.PERSON_CENTER || 'p' || cnl.PERSON_ID
--    END                                       AS paid,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID    pid
FROM
    AR_TRANS art
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
left join RELATIVES rel on rel.CENTER = ar.CUSTOMERCENTER and rel.ID = ar.CUSTOMERID and rel.RTYPE = 12 and rel.STATUS = 1    
LEFT JOIN
    CREDIT_NOTE_LINES cnl
ON
    cnl.CENTER = art.REF_CENTER
    AND cnl.ID = art.REF_ID
    AND art.REF_TYPE = 'CREDIT_NOTE'
LEFT JOIN
    INVOICELINES invl
ON
    invl.CENTER = art.REF_CENTER
    AND invl.ID = art.REF_ID
    AND art.REF_TYPE = 'INVOICE'
WHERE
    art.EMPLOYEECENTER = 200
    AND art.EMPLOYEEID = 2604
    AND art.TRANS_TIME >= 1433800800000
    --    and ar.CUSTOMERCENTER = 209 and ar.CUSTOMERID = 12004
    AND art.TEXT LIKE '%GX%'
--    AND AR.CUSTOMERCENTER = 204
--    AND ar.CUSTOMERID = 2824
GROUP BY
--    CASE
--        WHEN art.REF_TYPE = 'INVOICE'
--        THEN invl.PERSON_CENTER || 'p' || invl.PERSON_ID
--        ELSE cnl.PERSON_CENTER || 'p' || cnl.PERSON_ID
--    END,
    nvl2(rel.CENTER,1,0),
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID
    having sum(art.AMOUNT) != 100
order by other_payer,amount    