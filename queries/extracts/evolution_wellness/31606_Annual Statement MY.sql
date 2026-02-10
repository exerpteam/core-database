-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate                        
      FROM
          centers c
  )
  
SELECT DISTINCT
PEA3.TXTVALUE AS "EmailAddress",
c.Name AS "TransactionClubName",
c.Address1 AS "ClubAddressLine1",
c.Address2 AS "ClubAddressLine2",
c.Address3 AS "ClubAddressLine3",
CASE c.Country
	WHEN 'MY' THEN 'Malaysia'
	ELSE c.Country END AS "ClubAddressLine4",
c.City AS "ClubCity",
c.zipcode AS "ClubPostalCode",
CASE c.org_code
	WHEN 'Exertainment Malaysia Sdn Bhd' THEN 'Exertainment Malaysia Sdn Bhd (200401002010)'
	WHEN 'Sportathlon (Malaysia) Sdn Bhd' THEN 'Sportathlon (Malaysia) Sdn Bhd (200101014526)'
	WHEN 'J.V. Fitness Concepts Sdn Bhd' THEN 'J.V. Fitness Concepts Sdn Bhd (200401036645)'
	WHEN 'Avocado Fit Sdn Bhd' THEN 'Avocado Fit Sdn Bhd (201901021086)'
	ELSE c.org_code END AS "CompanyName",
CASE c.org_code
	WHEN 'Exertainment Malaysia Sdn Bhd' THEN 'B16-1808-31016355'
	WHEN 'Sportathlon (Malaysia) Sdn Bhd' THEN 'W-10-1808-31018982'
	WHEN 'J.V. Fitness Concepts Sdn Bhd' THEN 'B16-1808-31037013'
	WHEN 'Avocado Fit Sdn Bhd' THEN 'W10-1906-32000087'
	ELSE 'Unknown' END AS "SST No",
p.External_id AS "MembershipNumber",
p.Firstname AS "MemberFirstName",
p.LastName AS "MemberLastName",
P.ADDRESS1 AS "MemberAddressLine1", 
P.ADDRESS2 AS "MemberAddressLine2",
P.CITY AS "MemberAddressLine3", 
'' AS "MemberAddressLine4",
P.ZIPCODE AS "MemberAddressLine5",
(invl.center||'inv'||invl.id) AS "InvoiceNumber",
longtodatec(inv.trans_time,inv.center) AS "InvoiceDate",
invl.text AS "FeeDescription",
invl.net_amount AS "exc.tax",
invl.total_amount - invl.net_amount AS "TaxAmount",
invl.total_amount AS "inc.tax",
vat.global_id AS "TaxGroup",
    CASE p.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END "Member Status"
FROM
        evolutionwellness.persons p             
JOIN
        evolutionwellness.account_receivables ar
        ON ar.customercenter = p.center
        AND ar.customerid = p.id
        AND ar.ar_type = 4
JOIN
		evolutionwellness.invoices inv
        ON inv.payer_center = p.center
        AND inv.payer_id = p.id
JOIN
        evolutionwellness.invoice_lines_mt invl
        ON invl.center = inv.center
        AND invl.id = inv.id
        AND invl.total_amount != 0
        AND invl.reason = 9  -- NOT IN (28,31) Exclude reminder fees and Clipcards
JOIN
    evolutionwellness.ar_trans art
	ON art.ref_center = inv.center
	AND art.ref_id = inv.id
	AND art.ref_type = 'INVOICE'
	AND art.status = 'CLOSED'
JOIN
        evolutionwellness.centers c
        ON c.id = inv.center    
JOIN 
    	params
    	ON params.center_id = inv.center
LEFT JOIN
	evolutionwellness.products prod
        ON prod.center = invl.productcenter
        AND prod.id = invl.productid 
LEFT JOIN
        evolutionwellness.product_account_configurations pac
        ON pac.id = prod.product_account_config_id  
LEFT JOIN
        evolutionwellness.accounts ac
        ON ac.globalid = pac.sales_account_globalid
        AND ac.center = prod.center 
LEFT JOIN
        evolutionwellness.account_vat_type_group vat
        ON vat.id = ac.account_vat_type_group_id
        AND vat.account_center = ac.center
        AND vat.account_id = ac.id    
JOIN 
	PERSON_EXT_ATTRS AS PEA3 ON (PEA3.PERSONCENTER = 
        P.CURRENT_PERSON_CENTER AND PEA3.PERSONID = P.CURRENT_PERSON_ID 
        AND PEA3.NAME = '_eClub_Email') 
WHERE 
	p.center IN (:Scope)
	AND p.sex != 'C'
	AND p.status IN (1,2,4,3,6,9)
	AND inv.trans_time BETWEEN params.FromDate AND params.ToDate
	--AND p.id = 604
ORDER BY 1,20

