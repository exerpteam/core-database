SELECT distinct
    ps.ID,
    ps.NAME ,
    psg.NAME group_name,
    nvl2(nvl2(a.NAME,a.NAME,c.shortname),nvl2(a.NAME,a.NAME,c.shortname),ps.SCOPE_TYPE || ps.SCOPE_ID) scope
FROM
    PRIVILEGE_SETS ps
left join PRIVILEGE_SET_GROUPS psg on psg.ID = ps.PRIVILEGE_SET_GROUPS_ID    
LEFT JOIN
    AREAS a
ON
    ps.SCOPE_TYPE = 'A'
    AND a.ID = ps.SCOPE_ID
LEFT JOIN
    CENTERS c
ON
    ps.SCOPE_TYPE = 'C'
    AND c.ID = ps.SCOPE_ID
WHERE
    ps.STATE = 'ACTIVE'
    AND ps.REUSABLE = 1
    AND ps.ID NOT IN
                      (
                      SELECT DISTINCT
                          ps.ID
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
                      LEFT JOIN
                          AREAS a
                      ON
                          mpr.SCOPE_TYPE = 'A'
                          AND a.ID = mpr.SCOPE_ID
                      LEFT JOIN
                          centers c
                      ON
                          mpr.SCOPE_TYPE = 'C'
                          AND c.id = mpr.SCOPE_ID
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
                                  AND pr.CENTER IS NOT NULL)) )