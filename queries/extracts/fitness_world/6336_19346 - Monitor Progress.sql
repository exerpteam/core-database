-- This is the version from 2026-02-05
--  
SELECT
    s.center,
    count(*)
FROM
    persons p

JOIN subscriptions s
ON
    p.id = s.owner_id
    AND p.center = s.owner_center

JOIN FW.SUBSCRIPTIONTYPES st
ON
    s.subscriptiontype_center = st.center
    AND s.subscriptiontype_id = st.id

JOIN products pr
ON
    st.center = pr.center
    AND st.id = pr.id

LEFT JOIN STATE_CHANGE_LOG scl on scl.center = s.center and scl.id = s.id and scl.STATEID = 8 and scl.ENTRY_TYPE = 2 and scl.SUB_STATE in (3,4,6) -- to check if the sub is upgrade / downgrade

WHERE
s.CENTER BETWEEN :FromCenter AND :ToCenter
and s.center >100 and s.center < 200

    AND st.st_type = 1 -- only EFT of course
    and s.state in (2,4,8) -- exclude ended, window subscription as they have been invoiced already at least for next month since the renewal is supposed to run before that script
    and (s.billed_until_date is null or s.billed_until_date >= trunc(to_date('2011-06-30', 'YYYY-MM-DD'),'mon')) -- should be the normal BUD beofre the auto renewal (this is to exclude those which failed in the renewal). Should be 2010-12-31
	and (s.billed_until_date is null or s.billed_until_date < to_date('2011-07-31', 'YYYY-MM-DD'))
   and (s.end_date is null or s.end_date >=  trunc(to_date('2011-07-31', 'YYYY-MM-DD'),'mon'))
  and (s.start_date <= to_date('2011-07-31', 'YYYY-MM-DD'))


    and (
        (s.CREATION_TIME < (datetolong('2011-05-15 00:00') + (86400 * 1000 - 1))) -- cut date: 14/01/2011. Exclude those creatd after the cut date except transfers / upgrades / downgrades
        or (scl.center is not null) -- except transfers / upgrades / downgrades
    )
 /* exclude company agreements */
    and not exists (
        select 1 
        from RELATIVES rel
        JOIN COMPANYAGREEMENTS ca
        ON
            ca.CENTER = rel.RELATIVECENTER
            AND ca.ID = rel.RELATIVEID
            AND ca.SUBID = rel.RELATIVESUBID
        JOIN PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_CENTER = ca.CENTER
            AND pg.GRANTER_ID = ca.ID
            AND pg.GRANTER_SUBID = ca.SUBID
            AND pg.SPONSORSHIP_NAME = 'FULL'
            AND pg.VALID_FROM < dateToLong(TO_CHAR(exerpsysdate()+1, 'YYYY-MM-dd HH24:MI'))
            AND pg.VALID_TO is null
        JOIN PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
            AND pp.VALID_FROM < dateToLong(TO_CHAR(exerpsysdate()+1, 'YYYY-MM-dd HH24:MI'))
            AND pp.VALID_TO is null
        WHERE 
            rel.CENTER = p.center
            AND rel.id = p.id
            AND rel.RTYPE = 3
            AND rel.STATUS = 1 -- which status ?
            AND pp.REF_GLOBALID = pr.GLOBALID
    )
    /* exclude company agreements included privilege sets (comment #144) */
    and not exists (
        select 1 
        from RELATIVES rel
        JOIN COMPANYAGREEMENTS ca
        ON
            ca.CENTER = rel.RELATIVECENTER
            AND ca.ID = rel.RELATIVEID
            AND ca.SUBID = rel.RELATIVESUBID
        JOIN PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_CENTER = ca.CENTER
            AND pg.GRANTER_ID = ca.ID
            AND pg.GRANTER_SUBID = ca.SUBID
            AND pg.SPONSORSHIP_NAME = 'FULL'
            AND pg.VALID_FROM < dateToLong(TO_CHAR(exerpsysdate()+1, 'YYYY-MM-dd HH24:MI'))
            AND pg.VALID_TO is null
        JOIN FW.PRIVILEGE_SET_INCLUDES incl
            on incl.PARENT_ID = pg.PRIVILEGE_SET
            AND incl.VALID_FROM < dateToLong(TO_CHAR(exerpsysdate()+1, 'YYYY-MM-dd HH24:MI'))
            AND incl.VALID_TO is null
        JOIN PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = incl.CHILD_ID
            AND pp.VALID_FROM < dateToLong(TO_CHAR(exerpsysdate()+1, 'YYYY-MM-dd HH24:MI'))
            AND pp.VALID_TO is null
        WHERE 
            rel.CENTER = p.center
            AND rel.id = p.id
            AND rel.RTYPE = 3
            AND rel.STATUS = 1 -- which status ?
            AND pp.REF_GLOBALID = pr.GLOBALID
    )

and
(P.CENTER,P.ID) NOT IN ((100, 1))
group by s.center