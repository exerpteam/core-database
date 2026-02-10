-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        pea.txtvalue AS PersonId,
        cc.center AS ClipcardCenterId,
        longToDateC(cc.valid_until, cc.center) AS ClipcardExpirationDate,
        il.total_amount AS ClipcardPrice,
        cc.clips_initial AS ClipsInitial,
        cc.clips_left AS ClipsLeft,
        pr.globalid AS NewClipcardGlobalId,
        CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
        CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE,
        c.name,
        pr.name as Clipcard_Name,
        il.total_amount as package_price,
        il.total_amount/NULLIF(cc.clips_initial,0) as price_per_session,
il.net_amount AS net_amount
FROM evolutionwellness.persons p
JOIN evolutionwellness.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
JOIN evolutionwellness.clipcards cc ON p.center = cc.owner_center AND p.id = cc.owner_id
JOIN evolutionwellness.invoice_lines_mt il ON cc.invoiceline_center = il.center AND cc.invoiceline_id = il.id AND cc.invoiceline_subid = il.subid
JOIN evolutionwellness.products pr ON il.productcenter = pr.center AND il.productid = pr.id
JOIN evolutionwellness.centers c ON c.id = p.center
WHERE
        p.center IN (:Scope)
        AND p.sex NOT IN ('C')
        AND cc.cc_comment IS NOT NULL