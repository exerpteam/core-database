-- The extract is extracted from Exerp on 2026-02-08
-- Get list of members who start in the future and have a blocked period though they have no outstanding balance anymore
 SELECT
     sub.CENTER,
     sub.ID,
     sub.OWNER_CENTER || 'p' || sub.OWNER_ID    PersonId,
     sbp.START_DATE                          AS BlockedStartDate,
     sub.START_DATE                             SubscriptionStartDate
 FROM
     SUBSCRIPTION_BLOCKED_PERIOD sbp
 JOIN
     SUBSCRIPTIONS sub
 ON
     sub.CENTER = sbp.SUBSCRIPTION_CENTER
     AND sub.id = sbp.SUBSCRIPTION_ID
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = sub.OWNER_CENTER
     AND ar.CUSTOMERID = sub.OWNER_ID
     AND ar.BALANCE >= 0
     AND ar.AR_TYPE = 4
 WHERE
     sbp.FREEZE_PERIOD IS NULL
     AND sbp.STATE = 'ACTIVE'
     AND sbp.END_DATE IS NULL
     AND sub.STATE IN (2,4,8)
     AND sbp.type = 'DEBT_COLLECTION'
         AND sub.CENTER != 149
