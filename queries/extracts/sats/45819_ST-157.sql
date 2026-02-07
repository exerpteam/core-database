SELECT DISTINCT
    *
FROM
    (
        /* We also need all the ones that are note at all linked to any grant or are linked to a grand that is no longer valid */
        SELECT
            ps.ID,
            ps.NAME,
            ps.STATE,
            psg.NAME PS_GROUP
        FROM
            PRIVILEGE_SETS ps
        join PRIVILEGE_SET_GROUPS psg on psg.ID = ps.PRIVILEGE_SET_GROUPS_ID
        LEFT JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.PRIVILEGE_SET = ps.ID
            AND (
                pg.VALID_TO IS NULL
                OR pg.VALID_TO > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')))
                
        WHERE
            pg.ID IS NULL
            AND ps.STATE = 'ACTIVE'
        UNION ALL
        SELECT
            ps.ID,
            ps.NAME,
            ps.STATE,
            psg.NAME
        FROM
            SATS.PRIVILEGE_SETS ps
            join PRIVILEGE_SET_GROUPS psg on psg.ID = ps.PRIVILEGE_SET_GROUPS_ID
        JOIN
            SATS.PRIVILEGE_GRANTS pg
        ON
            pg.PRIVILEGE_SET = ps.id
            AND (
                pg.VALID_TO IS NULL
                OR pg.VALID_TO > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')))            
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
                    /* We have planned also. I would skip this all toghter since it's not a huge problem if we miss a few here */
                    --AND sc.STATE = 'ACTIVE'
                    AND (
                        sc.ENDTIME > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
                        OR sc.ENDTIME IS NULL)
                    /* Below needs to go since we might have some that starts in the future as well */
                    --AND sc.STARTTIME <= exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
                    /* We are only interested grants that are valid now or will become valid in the future */
                    AND (
                        pg.VALID_TO IS NULL
                        OR pg.VALID_TO > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')) ) )
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    SATS.COMPANYAGREEMENTS ca
                WHERE
                    pg.GRANTER_SERVICE = 'CompanyAgreement'
                    AND ca.BLOCKED = 0
                    /* 0-4 needs to be included */
                    --AND ca.STATE NOT IN (2,3,5,6)
                    /*
                    select ca.STATE,count(ca.CENTER) from COMPANYAGREEMENTS ca
                    join RELATIVES rel on rel.RELATIVECENTER = ca.CENTER and        rel.RELATIVEID = ca.ID and rel.RELATIVESUBID = ca.SUBID and rel.STATUS not in  (2,3)
                    group by ca.STATE
                    */
                    AND ca.STATE IN (0,1,2,3,4)
                    AND ca.CENTER = pg.GRANTER_CENTER
                    AND ca.id = pg.GRANTER_ID
                    AND ca.SUBID = pg.GRANTER_SUBID
                    /* We are only interested grants that are valid now or will become valid in the future */
                    AND (
                        pg.VALID_TO IS NULL
                        OR pg.VALID_TO > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')) ) )
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
                        OR prg.ENDTIME IS NULL)
                    /* We are only interested grants that are valid now or will become valid in the future */
                    AND (
                        pg.VALID_TO IS NULL
                        OR pg.VALID_TO > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')) ) )
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
                    AND mpr.id = pg.GRANTER_ID
                    /* We are only interested grants that are valid now or will become valid in the future */
                    AND (
                        pg.VALID_TO IS NULL
                        OR pg.VALID_TO > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')) ) ) )
