-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3265
 SELECT
   c.NAME AS CENTER,
   a.NAME AS PARTNERSHIP_NAME,
   TO_CHAR(r.EXPIREDATE, 'YYYY-MM-DD') AS Document_Expire_Date,
   p.CENTER||'p'||p.ID As MemberID,
   TO_CHAR(s.BINDING_END_DATE,'YYYY-MM-DD') AS Subscription_Binding_Date,
   TO_CHAR(s.END_DATE,'YYYY-MM-DD') AS Subscription_End_Date
 FROM
   PERSONS p
 JOIN
   RELATIVES r
 ON
   p.CENTER = r.CENTER
   AND p.ID = r.ID
   AND r.RTYPE = 3
   --AND r.STATUS in  (1)
 JOIN
   COMPANYAGREEMENTS a
 ON
   r.RELATIVECENTER = a.CENTER
   AND r.RELATIVEID = a.ID
   AND r.RELATIVESUBID = a.SUBID
 JOIN
   CENTERS c
 ON
   c.ID = p.CENTER
 JOIN
   SUBSCRIPTIONS s
 ON
   p.CENTER = s.OWNER_CENTER
   AND p.ID = s.OWNER_ID
   AND s.STATE in (2,4)
 WHERE
   c.ID in (:Scope)
   AND r.EXPIREDATE BETWEEN :DateFrom AND :DateTo
