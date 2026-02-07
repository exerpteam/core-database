 SELECT
         s.OWNER_CENTER || 'p' || s.OWNER_ID AS "P Number",
                 s.CENTER || 'ss' || s.ID AS "SubscriptionId",
         p.FULLNAME AS "Name",
         bi_decode_field('PERSONS','STATUS',p.STATUS) AS "State",
         spNew.FROM_DATE AS "Transferred Date"
 FROM
         SUBSCRIPTIONS s
 JOIN    PERSONS p
         ON
                 s.OWNER_CENTER = p.CENTER
                 AND s.OWNER_ID = p.ID
 JOIN
         SUBSCRIPTION_PRICE spNew
         ON
                 spNew.SUBSCRIPTION_CENTER = s.CENTER AND spNew.SUBSCRIPTION_ID = s.ID
 JOIN
         SUBSCRIPTION_PRICE spOld
         ON
                 spOld.SUBSCRIPTION_CENTER = spNew.SUBSCRIPTION_CENTER
                 AND spOld.SUBSCRIPTION_ID = spNew.SUBSCRIPTION_ID
                 AND spOld.TO_DATE = spNew.FROM_DATE-1
 WHERE
         spNew.TYPE = 'TRANSFER'
         AND spNew.EMPLOYEE_CENTER = 100
         AND spNew.EMPLOYEE_ID = 17401
         AND spNew.PRICE != spOld.PRICE
         AND spNew.FROM_DATE >= :fromDate
         AND spNew.FROM_DATE <= :toDate
