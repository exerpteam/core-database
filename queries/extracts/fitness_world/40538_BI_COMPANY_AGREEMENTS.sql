-- This is the version from 2026-02-05
--  
select * from (SELECT DISTINCT
    ca.center||'p'||ca.id||'rpt'||ca.SUBID                                                                                                 AS "COMPANY_AGREEMENT_ID",
    p.EXTERNAL_ID                                                                                                                          AS "COMPANY_ID",
    ca.NAME                                                                                                                                AS "NAME",
    UPPER(DECODE(ca.STATE, 0, 'Under target', 1, 'Active', 2, 'Stop new', 3, 'Old', 4, 'Awaiting activation', 5, 'Blocked', 6, 'Deleted')) AS "STATE",
    ca.center                                                                                                                              AS "CENTER_ID"
FROM
    COMPANYAGREEMENTS ca
LEFT JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.GRANTER_SERVICE= 'CompanyAgreement'
    AND pg.GRANTER_CENTER = ca.center
    AND pg.GRANTER_ID = ca.id
    AND pg.GRANTER_SUBID = ca.SUBID
JOIN
    PERSONS p
ON
    p.center = ca.center
    AND p.id = ca.id) biview