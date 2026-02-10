-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    center, 
    id, 
    name, 
    replace('' || sum(invoice), '.', ',') invoiced,
    replace('' || sum(credit), '.', ',') credited,
    replace('' || sum(invoice) + sum(credit), '.', ',') Invoice_total,
    replace('' || sum(other), '.', ',') other_trans
FROM 
    ( 
    SELECT 
        ar.CUSTOMERCENTER center, 
        ar.CUSTOMERID id, 
        per.lastname name, 
        sum(art.AMOUNT) invoice, 
        sum(0) credit,
        sum(0) other
    FROM 
        FW.PERSONS per 
    JOIN 
        FW.ACCOUNT_RECEIVABLES ar 
        ON 
        per.center = ar.CUSTOMERCENTER 
        and per.id = ar.CUSTOMERID 
    JOIN 
        FW.AR_TRANS art 
        ON 
        ar.center = art.center 
        and ar.id = art.id 
        and art.REF_TYPE = 'INVOICE'
	join FW.companyagreements ca
     	on
        per.center = ca.center
        and per.id = ca.id
	JOIN FW.privilege_grants grants
     	ON
        ca.center = grants.granter_center
        AND ca.id = grants.granter_id
        AND ca.subid = grants.granter_subid
    WHERE 
        per.SEX                                = 'C' 
        and longtodate(art.ENTRY_TIME) >= :FromDate 
        and longtodate(art.ENTRY_TIME) <= :ToDate 
        and per.center in (:scope)
	    AND grants.granter_service = 'CompanyAgreement'
        AND grants.sponsorship_name = 'FULL'
    GROUP BY 
        ar.CUSTOMERCENTER, 
        ar.CUSTOMERID, 
        per.lastname 
    UNION 
    SELECT 
        ar.CUSTOMERCENTER, 
        ar.CUSTOMERID, 
        per.lastname name, 
        sum(0) invoice, 
        sum(art.AMOUNT) credit,
        sum(0) other
    FROM 
        FW.PERSONS per 
    JOIN 
        FW.ACCOUNT_RECEIVABLES ar 
        ON 
        per.center = ar.CUSTOMERCENTER 
        and per.id = ar.CUSTOMERID 
    JOIN 
        FW.AR_TRANS art 
        ON 
        ar.center = art.center 
        and ar.id = art.id 
        and art.REF_TYPE = 'CREDIT_NOTE'
	join FW.companyagreements ca
     	on
        per.center = ca.center
        and per.id = ca.id
	JOIN FW.privilege_grants grants
     	ON
        ca.center = grants.granter_center
        AND ca.id = grants.granter_id
        AND ca.subid = grants.granter_subid
    WHERE 
        per.SEX                                = 'C' 
        and longtodate(art.ENTRY_TIME) >= :FromDate 
        and longtodate(art.ENTRY_TIME) <= :ToDate
        and per.center in (:scope)
		AND grants.granter_service = 'CompanyAgreement'
        AND grants.sponsorship_name = 'FULL'
    GROUP BY 
        ar.CUSTOMERCENTER, 
        ar.CUSTOMERID, 
        per.lastname 
   
    /* Join all other finance transactions */
    UNION 
    SELECT 
        ar.CUSTOMERCENTER, 
        ar.CUSTOMERID, 
        per.lastname name, 
        sum(0) invoice, 
        sum(0) credit,
        sum(art.AMOUNT) other  
    FROM 
        FW.PERSONS per 
    JOIN 
        FW.ACCOUNT_RECEIVABLES ar 
        ON 
        per.center = ar.CUSTOMERCENTER 
        and per.id = ar.CUSTOMERID 
    JOIN 
        FW.AR_TRANS art 
        ON 
        ar.center = art.center 
        and ar.id = art.id 
        and art.REF_TYPE <> 'CREDIT_NOTE' AND art.REF_TYPE <> 
'INVOICE'
	join FW.companyagreements ca
     	on
        per.center = ca.center
        and per.id = ca.id
	JOIN FW.privilege_grants grants
     	ON
        ca.center = grants.granter_center
        AND ca.id = grants.granter_id
        AND ca.subid = grants.granter_subid
    WHERE 
        per.SEX                                = 'C' 
        and longtodate(art.ENTRY_TIME) >= :FromDate 
        and longtodate(art.ENTRY_TIME) <= :ToDate
        and per.center in (:scope)
		AND grants.granter_service = 'CompanyAgreement'
        AND grants.sponsorship_name = 'FULL'
    GROUP BY 
        ar.CUSTOMERCENTER, 
        ar.CUSTOMERID, 
        per.lastname 
    ) 
GROUP BY 
    center, 
    id, 
    name 
ORDER BY 
    center, 
    name

