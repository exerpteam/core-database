 SELECT DISTINCT
     p.center ||'p'|| p.id                                                                                                                                   AS "Member ID",
     p.FULLNAME                                                                                                                                              AS "Member Name",
     CASE  p.persontype  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 'Corporate'  WHEN 5 THEN 'Onemancorporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest' ELSE 'Unknown' END AS "Person Type",
     co.FULLNAME                                                                                                                                             AS "Present Company",
     ca.name                                                                                                                                                 AS "Present Company Agreement",
     priset.NAME                                                                                                                                             AS "Privilege Set used",
     pr3.name                                                                                                                                                AS "privilege Set Granter",
     pr.NAME                                                                                                                                                 AS "Product bought",
     pr2.name                                                                                                                                                AS "Current Subscription",
     CASE  s.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE 'Unknown' END                                                                  AS "Subscription State"
 FROM
     PRIVILEGE_USAGES pu
 JOIN
     PRIVILEGE_GRANTS pgra
 ON
     pgra.ID = pu.GRANT_ID
 JOIN
     PRIVILEGE_SETS priset
 ON
     priset.ID = pgra.PRIVILEGE_SET
 JOIN
     INVOICELINES il
 ON
     pu.TARGET_CENTER = il.CENTER
     AND pu.TARGET_ID = il.ID
     AND pu.TARGET_SUBID = il.SUBID
 JOIN
     PRODUCTS pr
 ON
     pr.CENTER = il.PRODUCTCENTER
     AND pr.id = il.PRODUCTID
 JOIN
     persons p
 ON
     p.CENTER = il.PERSON_CENTER
     AND p.id = il.PERSON_ID
 JOIN
     subscriptions s
 ON
     s.OWNER_CENTER = p.CENTER
     AND s.OWNER_ID = p.id
 JOIN
     PRODUCTS pr2
 ON
     pr2.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND pr2.id = s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     relatives rel
 ON
     p.center = rel.CENTER
     AND p.id = rel.id
     AND rel.RTYPE = 3
     AND rel.STATUS = 1
 LEFT JOIN
     COMPANYAGREEMENTS ca
 ON
     rel.RELATIVECENTER = ca.CENTER
     AND rel.RELATIVEID = ca.ID
     AND rel.RELATIVESUBID = ca.SUBID
     AND ca.STATE = 1
     AND p.PERSONTYPE = 4
 LEFT JOIN
     relatives rel2
 ON
     p.center = rel2.RELATIVECENTER
     AND p.ID = rel2.RELATIVEID
     AND rel2.RTYPE = 2
     AND rel2.STATUS = 1
 LEFT JOIN
     PERSONS co
 ON
     co.CENTER = rel2.CENTER
     AND co.ID = rel2.ID
 JOIN
     SUBSCRIPTIONS s2
 ON
     pu.SOURCE_CENTER = s2.CENTER
     AND pu.SOURCE_ID = s2.ID
 JOIN
     products pr3
 ON
     pr3.CENTER = s2.SUBSCRIPTIONTYPE_CENTER
     AND pr3.id = s2.SUBSCRIPTIONTYPE_ID
     AND pr3.NAME NOT LIKE '%Vitality %'
     AND pr3.name NOT LIKE '%Pru%'
 WHERE
     pu.PRIVILEGE_TYPE = 'PRODUCT'
     AND pu.state = 'USED'
     AND priset.ID != 1010
     AND (
         pr.NAME LIKE '%Vitality %'
         OR pr.name LIKE '%Pru%')
     AND (
         pr2.NAME LIKE '%Vitality %'
         OR pr2.name LIKE '%Pru%')
     AND (
         co.center ||'p'|| co.id != '4p674'
         OR (
             co.center ||'p'|| co.id = '4p674'
             AND ca.NAME IS NULL))
                 AND s.STATE IN (2,4)
