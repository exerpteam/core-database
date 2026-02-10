-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    person.center,
    person.id,
    person.CENTER || 'p' || person.id personid,    
    company.center compcenter,
    company.id compid,
    company.CENTER || 'p' || company.id companyid,
    company.LASTNAME company,
    SUM(sums.invoice) invoiced,
    SUM(sums.credit) credited,
    SUM(sums.invoice) + SUM(sums.credit) Invoice_total,
    SUM(sums.other) other_trans
FROM
    PERSONS person
LEFT JOIN RELATIVES rel
ON
    person.CENTER = rel.RELATIVECENTER
    AND person.ID = rel.RELATIVEID
    AND rel.RTYPE = 2
LEFT JOIN PERSONS company
ON
    company.CENTER = rel.CENTER
    AND company.ID = rel.ID
JOIN
    (
        SELECT
            ar.CUSTOMERCENTER center,
            ar.CUSTOMERID id,
            SUM(art.AMOUNT) invoice,
            SUM(0) credit,
            SUM(0) other
        FROM
            PERSONS per
        JOIN ACCOUNT_RECEIVABLES ar
        ON
            per.center = ar.CUSTOMERCENTER
            AND per.id = ar.CUSTOMERID
        JOIN AR_TRANS art
        ON
            ar.center = art.center
            AND ar.id = art.id
            AND art.REF_TYPE = 'INVOICE'
        WHERE
            per.PERSONTYPE = 4
            AND per.SEX <> 'C'
            and eclub2.longtodate(art.ENTRY_TIME) >= :FromDate 
            and eclub2.longtodate(art.ENTRY_TIME) <= :ToDate   
            and ar.CUSTOMERCENTER =(:scope)                  
        GROUP BY
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            per.lastname
        
        UNION
        
        SELECT
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            SUM(0) invoice,
            SUM(art.AMOUNT) credit,
            SUM(0) other
        FROM
            PERSONS per
        JOIN ACCOUNT_RECEIVABLES ar
        ON
            per.center = ar.CUSTOMERCENTER
            AND per.id = ar.CUSTOMERID
        JOIN AR_TRANS art
        ON
            ar.center = art.center
            AND ar.id = art.id
            AND art.REF_TYPE = 'CREDIT_NOTE'
        WHERE
            per.PERSONTYPE = 4
            AND per.SEX <> 'C'
            and eclub2.longtodate(art.ENTRY_TIME) >= :FromDate 
            and eclub2.longtodate(art.ENTRY_TIME) <= :ToDate 
            and ar.CUSTOMERCENTER =(:scope)
        GROUP BY
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            per.lastname
        /* Join all other finance transactions */
        UNION
        
        SELECT
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            SUM(0) invoice,
            SUM(0) credit,
            SUM(art.AMOUNT) other
        FROM
            PERSONS per
        JOIN ACCOUNT_RECEIVABLES ar
        ON
            per.center = ar.CUSTOMERCENTER
            AND per.id = ar.CUSTOMERID
        JOIN AR_TRANS art
        ON
            ar.center = art.center
            AND ar.id = art.id
            AND art.REF_TYPE <> 'CREDIT_NOTE'
            AND art.REF_TYPE <> 'INVOICE'
        WHERE
            per.PERSONTYPE = 4
            AND per.SEX <> 'C'
            and eclub2.longtodate(art.ENTRY_TIME) >= :FromDate 
            and eclub2.longtodate(art.ENTRY_TIME) <= :ToDate 
            and ar.CUSTOMERCENTER =(:scope)
        GROUP BY
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            per.lastname
    )
    sums
ON
    sums.center = person.center
    AND sums.id = person.id
WHERE
    person.PERSONTYPE = 4
    AND person.SEX <> 'C'
GROUP BY
    person.center,
    person.id,
    person.CENTER || 'p' || person.id,
    company.center,
    company.id,
    company.CENTER || 'p' || company.id,
    company.LASTNAME
ORDER BY
    company.CENTER || 'p' || company.id, person.CENTER || 'p' || person.id