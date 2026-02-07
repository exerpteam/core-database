
SELECT DISTINCT
    ps.ID,
    ps.NAME,
    ps.STATE,
    psg.NAME group_name,
    pg.GRANTER_SERVICE,
    case
        when sc.ID is not null then sc.NAME
        when ca.CENTER is not null then ca.NAME
        when prg.ID is not null then prg.NAME
        when mpr.ID is not null and pr.CENTER is not null then mpr.SCOPE_TYPE || '' || mpr.SCOPE_ID || ' - ' || mpr.CACHED_PRODUCTNAME
        else 'SHOULD NOT HAPPEN'
    end SPECIFIC_GRANTER,
    case
        when sc.ID is not null then sc.SCOPE_TYPE || ' ' || sc.SCOPE_ID
        when ca.CENTER is not null then ca.CENTER || 'ca' || ca.ID || 'agr' || ca.SUBID
        when prg.ID is not null then prg.SCOPE_TYPE  || ' ' || prg.SCOPE_ID
        when mpr.ID is not null and pr.CENTER is not null then nvl2(a.NAME,a.NAME,c.shortname)
        else 'SHOULD NOT HAPPEN'
    end "indentity/scope"
FROM
    SATS.PRIVILEGE_SETS ps
JOIN
    PRIVILEGE_SET_GROUPS psg
ON
    psg.ID = ps.PRIVILEGE_SET_GROUPS_ID
JOIN
    SATS.PRIVILEGE_GRANTS pg
ON
    pg.PRIVILEGE_SET = ps.id
    AND (
        pg.VALID_TO IS NULL
        OR pg.VALID_TO > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')))
LEFT JOIN
    SATS.STARTUP_CAMPAIGN sc
ON
    sc.ID = pg.GRANTER_ID
    AND pg.GRANTER_SERVICE = 'StartupCampaign'
    /* We have planned also. I would skip this all toghter since it's not a huge problem if we miss a few here */
    --AND sc.STATE = 'ACTIVE'
    AND (
        sc.ENDTIME > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
        OR sc.ENDTIME IS NULL)
LEFT JOIN
    SATS.COMPANYAGREEMENTS ca
ON
    pg.GRANTER_SERVICE = 'CompanyAgreement'
    AND ca.BLOCKED = 0
    AND ca.STATE IN (0,1,2,3,4)
    AND ca.CENTER = pg.GRANTER_CENTER
    AND ca.id = pg.GRANTER_ID
    AND ca.SUBID = pg.GRANTER_SUBID
LEFT JOIN
    SATS.PRIVILEGE_RECEIVER_GROUPS prg
ON
    prg.ID = pg.GRANTER_ID
    AND pg.GRANTER_SERVICE = 'ReceiverGroup'
    AND prg.BLOCKED = 0
    AND (
        prg.ENDTIME> exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
        OR prg.ENDTIME IS NULL)
LEFT JOIN
    SATS.MASTERPRODUCTREGISTER mpr
ON
    mpr.id = pg.GRANTER_ID
    AND pg.GRANTER_SERVICE IN ('GlobalCard',
                               'Addon',
                               'GlobalSubscription')
left join AREAS a on mpr.SCOPE_TYPE = 'A' and a.ID = mpr.SCOPE_ID
left join centers c on mpr.SCOPE_TYPE = 'C' and c.id = mpr.SCOPE_ID
LEFT JOIN
    SATS.PRODUCTS pr
ON
    pr.GLOBALID = mpr.GLOBALID
    AND pr.BLOCKED = 0
WHERE
    ps.STATE = 'ACTIVE'
    AND ps.REUSABLE = 1
    AND (
        sc.ID IS NOT NULL
        OR ca.CENTER IS NOT NULL
        OR prg.ID IS NOT NULL
        OR (
            mpr.ID IS NOT NULL
            AND pr.CENTER IS NOT NULL))