SELECT DISTINCT
    ps.ID,
    ps.NAME,
    ps.STATE
FROM
    SATS.PRIVILEGE_SETS ps
JOIN
    SATS.PRIVILEGE_GRANTS pg
ON
    pg.PRIVILEGE_SET = ps.id
WHERE
    ps.STATE = 'ACTIVE'
    AND ps.REUSABLE = 1
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            SATS.STARTUP_CAMPAIGN sc
        WHERE
            sc.ID = pg.GRANTER_ID
            AND pg.GRANTER_SERVICE = 'StartupCampaign'
            AND sc.STATE = 'ACTIVE'
            AND (
                sc.ENDTIME > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
                OR sc.ENDTIME IS NULL)
            AND sc.STARTTIME <= exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')))
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            SATS.COMPANYAGREEMENTS ca
        WHERE
            pg.GRANTER_SERVICE = 'CompanyAgreement'
            AND ca.BLOCKED = 0
            AND ca.STATE NOT IN (2,3,5,6)
            AND ca.CENTER = pg.GRANTER_CENTER
            AND ca.id = pg.GRANTER_ID
            AND ca.SUBID = pg.GRANTER_SUBID )
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            SATS.PRIVILEGE_RECEIVER_GROUPS prg
        WHERE
            prg.ID = pg.GRANTER_ID
            AND pg.GRANTER_SERVICE = 'ReceiverGroup'
            AND prg.BLOCKED = 0
            AND (
                prg.ENDTIME> exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
                OR prg.ENDTIME IS NULL))
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            SATS.MASTERPRODUCTREGISTER mpr
        JOIN
            SATS.PRODUCTS pr
        ON
            pr.GLOBALID = mpr.GLOBALID
            AND pr.BLOCKED = 0
        WHERE
            pg.GRANTER_SERVICE IN ('GlobalCard',
                                   'Addon',
                                   'GlobalSubscription')
            AND mpr.id = pg.GRANTER_ID)