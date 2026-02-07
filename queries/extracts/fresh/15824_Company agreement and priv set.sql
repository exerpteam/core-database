SELECT
    company.center||'p'||company.id as companyId,
    company.LASTNAME as companyname,
    ca.NAME as agreementname,
    ps.name as privilege_name,
    psg.name as privilege_group
FROM
     COMPANYAGREEMENTS ca
JOIN PERSONS company
ON
    company.CENTER = ca.CENTER
    AND company.ID = ca.id
    AND company.sex = 'C'
JOIN PRIVILEGE_GRANTS pg
ON
    pg.GRANTER_CENTER = ca.CENTER
    AND pg.GRANTER_ID = ca.ID
    AND pg.GRANTER_SUBID = ca.SUBID
    AND pg.GRANTER_SERVICE = 'CompanyAgreement'
    and pg.valid_to is null
JOIN PRIVILEGE_SETS ps
ON
    pg.PRIVILEGE_SET = ps.id             
join privilege_set_groups psg
    on
     ps.privilege_set_groups_id = psg.id
where
	ca.state = 1
	and company.center in (:scope)
group by
    company.center,
    company.id,
    company.LASTNAME,
    ca.NAME,
    ps.name,
    psg.name
order by
    company.center,
    company.id,
    company.LASTNAME,
    ca.NAME,
    ps.name
