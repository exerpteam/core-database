 SELECT
     CASE rel.RTYPE WHEN 1 THEN 'FRIEND' WHEN 4 THEN 'FAMILY' ELSE 'UNKNOWN - Contact Exerp support' END INVALID_RELATIONSHIP,
     rel.STATUS RELATION_STATUS,
     rel.CENTER || 'p' || rel.ID PRIMARY_PID,
     pp.FIRSTNAME PRIMARY_FIRSTNAME,
     pp.LASTNAME PRIMARY_LASTNAME,
     cp.NAME PRIMARY_HOME_CLUB,
     rel.RELATIVECENTER || 'p' || rel.RELATIVEID SECONDARY_PID,
     ps.FIRSTNAME SECONDARY_FIRSTNAME,
     ps.LASTNAME SECONDARY_LASTNAME,
     cs.NAME SECONDARY_HOME_CLUB
 FROM
     RELATIVES rel
 join PERSONS pp on pp.CENTER = rel.CENTER and pp.ID  = rel.ID
 join PERSONS ps on ps.CENTER = rel.RELATIVECENTER and ps.ID  = rel.RELATIVEID
 join CENTERS cp on cp.ID = pp.CENTER
 join CENTERS cs on cs.ID = ps.CENTER
 JOIN SUBSCRIPTIONS ssec
 ON
     ssec.OWNER_CENTER = rel.CENTER
     AND ssec.OWNER_ID = rel.ID
     AND ssec.STATE IN (2,4,8)
 WHERE
     rel.RTYPE = 4
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             SUBSCRIPTIONS s
         WHERE
             s.OWNER_CENTER = rel.RELATIVECENTER
             AND s.OWNER_ID = rel.RELATIVEID
             AND s.STATE IN (2,4,8)
     )
 AND ssec.OWNER_CENTER in ($$scope$$)
