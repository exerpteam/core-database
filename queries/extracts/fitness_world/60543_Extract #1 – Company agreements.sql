-- This is the version from 2026-02-05
-- ST-12910
SELECT
distinct
    ca.center ||'p'|| ca.id                    AS companyid,
    ca.center ||'p'|| ca.id ||'rpt'|| ca.subid AS agreementid,
    c.fullname                                 AS company ,
    ca.name                                    AS agreement,
    longtodate(scl.ENTRY_START_TIME)           as companystartdate,
    ca.STOP_NEW_DATE                           AS "Agreement SIGNUP END DATE",
    p.Globalid                                 AS GLOBALID ,   
 CASE
        WHEN ppr.PRICE_MODIFICATION_NAME = 'OVERRIDE'
        THEN ppr.PRICE_MODIFICATION_AMOUNT
        ELSE p.price
    END AS Price,
    pg.SPONSORSHIP_NAME                        AS "Sponsor type"

FROM
    COMPANYAGREEMENTS ca
    /* company */
JOIN
    PERSONS c
ON
    ca.CENTER = c.CENTER
AND ca.ID = c.ID
    
JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.GRANTER_CENTER = ca.CENTER
AND pg.GRANTER_ID = ca.ID
AND pg.GRANTER_SUBID = ca.SUBID
AND pg.GRANTER_SERVICE = 'CompanyAgreement'
    and pg.valid_to is null
join 
PRIVILEGE_SET_INCLUDES psi
on
pg.PRIVILEGE_SET = psi.PARENT_ID

and
psi.VALID_TO IS NULL

JOIN
    PRIVILEGE_SETS ps
ON
    psi.PARENT_ID = ps.id
or
psi.CHILD_ID = ps.id   
join
PRODUCT_PRIVILEGES ppr
on
ppr.PRIVILEGE_SET = ps.id
AND ppr.VALID_TO IS NULL

join
PRODUCTS p
on
ppr.REF_GLOBALID = p.GLOBALID
and p.ptype not in (12,5)
join
STATE_CHANGE_LOG scl
on
scl.center = c.center
and
scl.id = c.id
and ENTRY_TYPE = 3
left join
PRODUCTS p2
on
ppr.REF_GLOBALID = p2.GLOBALID
and p.ptype in (5)

WHERE
 ca.center in (:scope)

 