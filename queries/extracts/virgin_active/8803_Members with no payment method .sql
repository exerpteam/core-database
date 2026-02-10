-- The extract is extracted from Exerp on 2026-02-08
-- Highlights member who have DD or other payer on their account.
 SELECT
     C.ID as ClubID ,
     c.NAME as ClubName,
     p.center||'p'||p.id AS memberID,
     p.FULLNAME as MemberName,
     ar.BALANCE as Currentbalance,
     CASE  WHEN pa.CENTER IS NULL THEN 'no' ELSE 'yes' END AS "Has agreement",
     case r.RELATIVECENTER||'p'||r.RELATIVEID when 'p' then null else r.RELATIVECENTER||'p'||r.RELATIVEID end HeadFamilyMember
 FROM
     PERSONS p
 join
 CENTERS c
 on
 p.CENTER = c.ID
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.CENTER
     AND s.OWNER_ID = p.id
     AND s.STATE IN(2,4)
     AND s.SUBSCRIPTION_PRICE > 0
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND st.id = s.SUBSCRIPTIONTYPE_ID
     AND st.ST_TYPE=1
 LEFT JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p.center
     AND ar.CUSTOMERID =p.id
     AND ar.AR_TYPE = 4
 LEFT JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.center=ar.center
     AND pac.id =ar.id
 LEFT JOIN
     PAYMENT_AGREEMENTS pa
 ON
     pac.ACTIVE_AGR_CENTER = pa.CENTER
     AND pa.id = pac.ACTIVE_AGR_ID
     AND pa.SUBID = pac.ACTIVE_AGR_SUBID
 left join
 RELATIVES r
 on
 r.center = p.center
             AND r.id = p.id
             AND r.rtype = 4
             AND r.STATUS = 1
 WHERE
     floor(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE) / 12) < 16
     AND p.STATUS IN (1,3)
     and pa.center is null
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             RELATIVES r
         WHERE
             r.RELATIVECENTER = p.center
             AND r.RELATIVEID = p.id
             AND r.rtype in (2,12)
             AND r.STATUS = 1)
         AND p.center in ($$club$$)
