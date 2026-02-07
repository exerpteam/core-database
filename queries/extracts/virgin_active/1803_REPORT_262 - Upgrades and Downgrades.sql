 SELECT
     c.NAME                  club,
     p.CENTER || 'p' || p.id pid,
     p.FULLNAME,
     p.ZIPCODE                                       POSTAl_code,
     longToDate(scl.ENTRY_START_TIME)                changed,
     CASE scl.SUB_STATE WHEN 4 THEN 'Downgrade' WHEN 3 THEN 'Upgrade' END AS type,
     s.CENTER || 'ss' || s.ID                        old_Sub_Id,
     prod.NAME                                       old_Sub_Name,
     s2.CENTER || 'ss' || s2.ID                      new_Sub_Id,
     prod2.NAME                                      new_Sub_Name
 FROM
     STATE_CHANGE_LOG scl
 JOIN
     SUBSCRIPTIONS s
 ON
     s.CENTER = scl.CENTER
     AND s.id = scl.ID
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.id = s.SUBSCRIPTIONTYPE_ID
 JOIN
     PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
     AND p.id = s.OWNER_ID
 JOIN
     CENTERS c
 ON
     c.id = p.CENTER
 JOIN
     SUBSCRIPTIONS s2
 ON
     s2.OWNER_CENTER = p.CENTER
     AND s2.OWNER_ID = p.id
 JOIN
     PRODUCTS prod2
 ON
     prod2.CENTER = s2.SUBSCRIPTIONTYPE_CENTER
     AND prod2.id = s2.SUBSCRIPTIONTYPE_ID
 JOIN
     STATE_CHANGE_LOG scl2
 ON
     scl2.CENTER = s2.CENTER
     AND scl2.ID = s2.id
     AND scl2.ENTRY_TYPE = scl.ENTRY_TYPE
     AND (
         scl2.CENTER,scl2.ID) NOT IN ((scl.CENTER,
                                       scl.ID))
     AND scl2.STATEID IN (8)
     AND ABS(scl.ENTRY_START_TIME - scl2.ENTRY_START_TIME) < 1000
 WHERE
     scl.ENTRY_TYPE = 2
     AND scl.STATEID = 3
     AND scl.SUB_STATE IN (3,4)
     and p.CENTER in ($$scope$$)
     and scl.ENTRY_START_TIME between $$fromDate$$ and $$toDate$$   + (1000*60*60*24)
