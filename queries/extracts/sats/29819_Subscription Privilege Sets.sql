SELECT distinct
    ps.NAME      AS "Privilege Set",
    case when ps.SCOPE_TYPE = 'T' then 'Global'
    when a.ID is not null then a.NAME
    when c.ID is not null then c.NAME end as "Scope",
    mpr.GLOBALID AS "Subscription GlobalID"
FROM
    SATS.PRIVILEGE_SETS ps
LEFT JOIN
    SATS.PRIVILEGE_GRANTS pg
ON
    pg.PRIVILEGE_SET = ps.ID
    AND pg.VALID_FROM <= exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
    AND (
        pg.VALID_TO > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
        OR pg.VALID_TO IS NULL)
    AND pg.GRANTER_SERVICE='GlobalSubscription'
LEFT JOIN
    SATS.MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = pg.GRANTER_ID
    left join SATS.AREAS a on ps.SCOPE_TYPE = 'A' and ps.SCOPE_ID = a.ID
    left join SATS.CENTERS c on ps.SCOPE_TYPE = 'C' and ps.SCOPE_ID = c.ID
WHERE
    ps.BLOCKED_ON IS NULL
ORDER BY
    1