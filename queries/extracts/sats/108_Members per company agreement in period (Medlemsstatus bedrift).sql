 SELECT ca.center as companycenter, ca.id as companyid, ca.subid as agreementid, c.lastname as company , ca.name as agreement, mc.lastname as mothercompany, mc.center as mccenter, mc.id as mcid, key.firstname || ' ' || key.lastname as employeeName, ( SELECT COUNT(*) FROM /*company agreement relation*/ RELATIVES rel , /* persons under agreement*/ PERSONS p , subscriptions s WHERE rel.RELATIVECENTER = ca.CENTER AND rel.RELATIVEID = ca.ID AND rel.RELATIVESUBID = ca.SUBID AND rel.RTYPE = 3 AND rel.CENTER = p.CENTER AND rel.ID = p.ID AND rel.RTYPE = 3 AND s.OWNER_CENTER = rel.CENTER AND s.OWNER_ID = rel.ID AND
 s.start_date < :fromDate
  AND
 ( s.end_date > :fromDate
   or s.end_date IS NULL ) )
 as MembersBeginning , ( SELECT COUNT(*) FROM /*company agreement relation*/ RELATIVES rel , /* persons under agreement*/ PERSONS p , subscriptions s WHERE rel.RELATIVECENTER = ca.CENTER AND rel.RELATIVEID = ca.ID AND rel.RELATIVESUBID = ca.SUBID AND rel.RTYPE = 3 AND rel.CENTER = p.CENTER AND rel.ID = p.ID AND rel.RTYPE = 3 AND s.OWNER_CENTER = rel.CENTER AND s.OWNER_ID = rel.ID AND
 s.start_date >= :fromDate
 AND
 s.start_date <= :toDate
  ) as memberStarted , ( SELECT COUNT(*) FROM /*company agreement relation*/ RELATIVES rel , /* persons under agreement*/ PERSONS p , subscriptions s WHERE rel.RELATIVECENTER = ca.CENTER AND rel.RELATIVEID = ca.ID AND rel.RELATIVESUBID = ca.SUBID AND rel.RTYPE = 3 AND rel.CENTER = p.CENTER AND rel.ID = p.ID AND rel.RTYPE = 3 AND s.OWNER_CENTER = rel.CENTER AND s.OWNER_ID = rel.ID AND
 s.end_date >= :fromDate
 AND
 s.end_date <= :toDate
  ) as memberStopped
 FROM
 COMPANYAGREEMENTS ca /* company */ JOIN PERSONS c ON ca.CENTER = c.CENTER AND ca.ID = c.ID /* mother company */ LEFT JOIN RELATIVES relc ON relc.RELATIVECENTER = c.CENTER AND relc.RELATIVEID = c.ID AND relc.RTYPE = 6 LEFT JOIN PERSONS mc ON relc.CENTER = mc.CENTER AND relc.ID = mc.ID AND relc.RTYPE = 6 /* key account manager */ LEFT JOIN RELATIVES relkey ON relkey.CENTER = c.CENTER AND relkey.ID = c.ID AND relkey.RTYPE = 10 LEFT JOIN PERSONS key ON relkey.RELATIVECENTER = key.CENTER AND relkey.RELATIVEID = key.ID AND relkey.RTYPE = 10 ORDER BY ca.center, ca.id, ca.subid
