-- The extract is extracted from Exerp on 2026-02-08
--  
    SELECT 
        ar.CUSTOMERCENTER center, 
        ar.CUSTOMERID id, 
        per.lastname name, 
        art.AMOUNT invoice, 
		
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
	
join fw.invoice_lines il
		on
		
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


