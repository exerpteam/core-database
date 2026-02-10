-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT

    p.center||'p'||p.id as member_key,
    p.fullname as person_name,
    CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARY INACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS person_STATUS,
    cag.center||'p'||cag.id||'rpt'||cag.subid  as COMPANY_AGREEMENT_ID,
    comp.external_id as COMPANY_ID,
    comp.fullname as company_NAME,
    cag.name as company_agreement_name,
    cag.ref as company_ref,
    ps.name as company_agreement_privilege_set

FROM
    persons p
JOIN
    CENTERS center ON p.center = center.id
LEFT JOIN
    ACCOUNT_RECEIVABLES payment_ar ON payment_ar.CUSTOMERCENTER = p.center AND payment_ar.CUSTOMERID = p.id AND payment_ar.AR_TYPE = 4
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_ar ON cash_ar.CUSTOMERCENTER = p.center AND cash_ar.CUSTOMERID = p.id AND cash_ar.AR_TYPE = 1
LEFT JOIN
    RELATIVES comp_rel ON comp_rel.center = p.center AND comp_rel.id = p.id AND comp_rel.RTYPE = 3 AND comp_rel.STATUS < 3
JOIN
    COMPANYAGREEMENTS cag ON cag.center = comp_rel.RELATIVECENTER AND cag.id = comp_rel.RELATIVEID AND cag.subid = comp_rel.RELATIVESUBID
LEFT JOIN
    persons comp ON comp.center = cag.center AND comp.id = cag.id
LEFT JOIN
    PAYMENT_ACCOUNTS paymentaccount ON paymentaccount.center = payment_ar.center AND paymentaccount.id = payment_ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pa ON paymentaccount.ACTIVE_AGR_CENTER = pa.center AND paymentaccount.ACTIVE_AGR_ID = pa.id AND paymentaccount.ACTIVE_AGR_SUBID = pa.subid
LEFT JOIN
    RELATIVES op_rel ON op_rel.relativecenter = p.center AND op_rel.relativeid = p.id AND op_rel.RTYPE = 12 AND op_rel.STATUS < 3
LEFT JOIN
    PERSONS op ON op.center = op_rel.center AND op.id = op_rel.id
LEFT JOIN
    ACCOUNT_RECEIVABLES otherPayerAR ON otherPayerAR.CUSTOMERCENTER = op.center AND otherPayerAR.CUSTOMERID = op.id AND otherPayerAR.AR_TYPE = 4 -- other payer
LEFT JOIN
    RELATIVES pt_rel ON pt_rel.CENTER = p.center AND pt_rel.id = p.id AND pt_rel.STATUS < 3 AND ( (p.PERSONTYPE = 3 AND pt_rel.RTYPE = 1) OR (p.PERSONTYPE = 6 AND pt_rel.RTYPE = 4))
LEFT JOIN
    PERSONS pt_rel_p ON pt_rel_p.center = pt_rel.RELATIVECENTER AND pt_rel_p.id = pt_rel.RELATIVEID
    
LEFT JOIN 
    privilege_grants pg ON cag.center = pg.granter_center AND cag.id = pg.granter_id and cag.subid = pg.granter_subid 
    and (pg.valid_to is null or pg.valid_to <= extract(epoch from now()))
LEFT JOIN 
    privilege_sets ps on pg.privilege_set = ps.id


WHERE
    p.sex != 'C' 
    AND p.status not in (2, 4, 7, 8) --- 2 inactive, 4 transferred, 7 deleted, 8 anonymized
    AND p.persontype NOT IN (2,8)  --- 2 staff, 8 guest
    AND p.center||'p'||p.id in (:members)