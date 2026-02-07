 SELECT
     p.center,
     p.id,
     CASE  ps_scl.stateid  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 
     'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' ELSE 'UNKNOWN' END AS Person_STATUS,
     company.LASTNAME                                  AS companyname,
     ca.NAME                                           AS agreementname,
     sp.price                                          AS subscription_price,
     --    sub.binding_price,
     --    eclub2.longToDate(max(c.checkin_time)) as last_checkin,
     --   ps.name as privilege_name,
     --    pg.sponsorship_name as sponsorship_type,
     --    psg.name as privilege_group,
     p1.name AS product_name
 --    ,sub_scl.BOOK_START_TIME
 --   ,sub_scl.BOOK_END_TIME
 FROM
     PERSONS p
 JOIN
     subscriptions sub
 ON
     p.center = sub.owner_center
 AND p.id = sub.owner_id
     --    and sub.state in (2,4) --7)
 JOIN
     STATE_CHANGE_LOG sub_scl
 ON
     sub_scl.CENTER = sub.center
 AND sub_scl.ID = sub.id
 AND sub_scl.ENTRY_TYPE = 2
 AND sub_scl.STATEID IN (2,4)
 AND sub_scl.BOOK_START_TIME < ($$compareDate$$ + 86400 * 1000 - 1)
 AND (
         sub_scl.BOOK_END_TIME IS NULL
     OR  sub_scl.BOOK_END_TIME >= ($$compareDate$$ + 86400 * 1000 - 1))
     -- get the right price at this point in time
 JOIN
     SUBSCRIPTION_PRICE sp
 ON
     sub.CENTER = sp.SUBSCRIPTION_CENTER
 AND sub.id = sp.SUBSCRIPTION_ID
 AND sp.FROM_DATE <= longtodate($$compareDate$$)
 AND (
         sp.TO_DATE IS NULL
     OR  sp.TO_DATE >= longtodate($$compareDate$$))
 JOIN
     subscriptiontypes st
 ON
     sub.subscriptiontype_center = st.center
 AND sub.subscriptiontype_id = st.id
 JOIN
     products p1
 ON
     st.center = p1.center
 AND st.id = p1.id
 JOIN
     product_group pgr
 ON
     p1.primary_product_group_id = pgr.id
 JOIN
     RELATIVES companyAgrRel
 ON
     sub.owner_center = companyAgrRel.CENTER
 AND sub.owner_id = companyAgrRel.ID
     --    and companyAgrRel.STATUS = 1
 AND companyAgrRel.RTYPE = 3
 JOIN
     STATE_CHANGE_LOG rel_scl
 ON
     rel_scl.CENTER = companyAgrRel.center
 AND rel_scl.ID = companyAgrRel.id
 AND rel_scl.SUBID = companyAgrRel.subid
 AND rel_scl.ENTRY_TYPE = 4
 AND rel_scl.STATEID = 1
 -- CHECK relation book end time: 000
 AND rel_scl.BOOK_START_TIME < ($$compareDate$$ + 86400 * 1000)
 AND (
         rel_scl.BOOK_END_TIME IS NULL
     OR  rel_scl.BOOK_END_TIME >= ($$compareDate$$ + 86400 * 1000)
     )
 JOIN
     COMPANYAGREEMENTS ca
 ON
     ca.CENTER = companyAgrRel.RELATIVECENTER
 AND ca.ID = companyAgrRel.RELATIVEID
 AND ca.SUBID = companyAgrRel.RELATIVESUBID
 JOIN
     PERSONS company
 ON
     company.CENTER = ca.CENTER
 AND company.ID = ca.id
 AND company.sex = 'C'
 JOIN
     STATE_CHANGE_LOG pt_scl
 ON
     pt_scl.CENTER = p.center
 AND pt_scl.ID = p.id
 AND pt_scl.ENTRY_TYPE = 3
 AND pt_scl.STATEID IN (4)
 AND pt_scl.BOOK_START_TIME < ($$compareDate$$ + 86400 * 1000)
 AND (
         pt_scl.BOOK_END_TIME IS NULL
     OR  pt_scl.BOOK_END_TIME >= ($$compareDate$$ + 86400 * 1000)
     )
 JOIN
     STATE_CHANGE_LOG ps_scl
 ON
     ps_scl.CENTER = p.center
 AND ps_scl.ID = p.id
 AND ps_scl.ENTRY_TYPE = 1
 AND ps_scl.STATEID IN (1,3)
 AND ps_scl.BOOK_START_TIME < ($$compareDate$$ + 86400 * 1000)
 AND (
         ps_scl.BOOK_END_TIME IS NULL
     OR  ps_scl.BOOK_END_TIME >= ($$compareDate$$ + 86400 * 1000)
     )
 WHERE
 --    p.CENTER BETWEEN (11) AND (20)
         p.CENTER BETWEEN ($$center_from$$) AND ($$center_to$$)
     --and p1.globalid = pp.ref_globalid
     -- persons subscription equal subscription agreement
     -- and psg.name like 'Company Agreements'
     --and p.STATUS in (1,3)
 AND pgr.name NOT IN ('Tillægsmedlemskaber',
                      'Markeringsmedlemskaber')
 GROUP BY
     p.center,
     p.id,
     ps_scl.stateid,
     company.LASTNAME,
     ca.NAME,
     sp.price,
     p1.name
 --    ,sub_scl.BOOK_START_TIME
 --    ,sub_scl.BOOK_END_TIME
 ORDER BY
     company.LASTNAME,
     p.center,
     p.id
