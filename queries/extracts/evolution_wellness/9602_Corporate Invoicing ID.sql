-- The extract is extracted from Exerp on 2026-02-08
-- Do not move this one to system, cna not be runned by ID team then
WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT
        p.fullname                                                                                      AS "Corporate Name"
        ,COALESCE(cai.name,cac.name)                                                                    AS "Agreement Reference"
        ,c.name                                                                                         AS "Club"
        ,COALESCE((pi.center||'p'||pi.id),(pc.center||'p'||pc.id))                                      AS "PersonID"
        ,COALESCE(pi.external_id,pc.external_id)                                                        AS "Member Number"
        ,COALESCE(pi.firstname,pc.firstname)                                                            AS "First Name"
        ,COALESCE(pi.lastname,pi.lastname)                                                              AS "Last Name"
        ,TO_CHAR(((DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month')::DATE), 'YYYY-MM-DD')        AS "First Billed Month"
        ,'Package Fees'                                                                                 AS "Charge Type"
        ,art.unsettled_amount                                                                           AS "Gross"
        ,COALESCE(pgi.sponsorship_name,pgc.sponsorship_name)                                            AS "Sponsorship Type"
        ,CASE
                WHEN art.amount < 0 THEN -art.amount
                ELSE art.amount
        END                                                                                             AS "Sponsorship Price" 
        ,art.unsettled_amount                                                                           AS "Invoice amount"
        ,TO_CHAR(DATE_TRUNC('month', CURRENT_DATE), 'YYYY-MM-DD')                                       AS "Last Billed Month"
        ,COALESCE(prodi.name,prodc.name)                                                                AS "Product Name"
        ,ar.balance                                                                                     AS "Company Balance"
FROM
        evolutionwellness.persons p
JOIN
        evolutionwellness.centers c
        ON c.id = p.center                  
JOIN
        evolutionwellness.account_receivables ar
        ON ar.customercenter = p.center
        AND ar.customerid = p.id
        AND ar.ar_type = 4
JOIN
        evolutionwellness.ar_trans art
        ON art.center = ar.center
        AND art.id = ar.id
        AND art.status != 'CLOSED' 
JOIN
        params
        ON params.center_id = p.center
LEFT JOIN
        evolutionwellness.credit_notes cn
        ON cn.center = art.ref_center
        AND cn.id = art.ref_id
        AND art.ref_type = 'CREDIT_NOTE'
LEFT JOIN
        evolutionwellness.credit_note_lines_mt cnl
        ON cnl.center = cn.center
        AND cnl.id = cn.id
LEFT JOIN
        evolutionwellness.invoices inv
        ON inv.center = art.ref_center
        AND inv.id = art.ref_id
        AND art.ref_type = 'INVOICE'
LEFT JOIN
        evolutionwellness.invoice_lines_mt invl
        ON invl.center = inv.center
        AND invl.id = inv.id 
LEFT JOIN
        evolutionwellness.persons pc
        ON pc.center = cnl.person_center
        AND pc.id = cnl.person_id
LEFT JOIN
        evolutionwellness.persons pi
        ON pi.center = invl.person_center
        AND pi.id = invl.person_id      
LEFT JOIN
        evolutionwellness.relatives ri
        ON pi.center = ri.center
        AND pi.id = ri.id
        AND ri.rtype = 3 
LEFT JOIN
        evolutionwellness.relatives rc
        ON pc.center = rc.center
        AND pc.id = rc.id
        AND rc.rtype = 3 
LEFT JOIN
        evolutionwellness.companyagreements cai
        ON cai.center = ri.relativecenter
        AND cai.id = ri.relativeid
        AND cai.subid = ri.relativesubid         
LEFT JOIN
        evolutionwellness.companyagreements cac
        ON cac.center = rc.relativecenter
        AND cac.id = rc.relativeid
        AND cac.subid = rc.relativesubid 
LEFT JOIN 
        privilege_grants pgi
        ON pgi.granter_center = cai.center
        AND pgi.granter_id = cai.id
        AND pgi.granter_subid = cai.subid
        AND pgi.granter_service = 'CompanyAgreement'
        AND pgi.valid_to IS NULL 
LEFT JOIN 
        privilege_grants pgc
        ON pgc.granter_center = cac.center
        AND pgc.granter_id = cac.id
        AND pgc.granter_subid = cac.subid
        AND pgc.granter_service = 'CompanyAgreement'
        AND pgc.valid_to IS NULL 
LEFT JOIN
        evolutionwellness.products prodi
        ON prodi.center = invl.productcenter
        AND prodi.id = invl.productid   
LEFT JOIN
        evolutionwellness.products prodc
        ON prodc.center = cnl.productcenter
        AND prodc.id = cnl.productid                                                                                               
WHERE
        p.center ||'p'|| p.id = :CompanyID 
        AND
        art.trans_time BETWEEN params.FromDate AND params.ToDate  
        AND 
        p.sex = 'C'                     