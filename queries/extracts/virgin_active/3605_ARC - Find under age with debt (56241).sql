-- The extract is extracted from Exerp on 2026-02-08
--  
 /* TEST */
 select * from
 (
 SELECT
     CASE
         WHEN PAYER_AGE < 18
             OR SUB_OWNER_AGE < 18
         THEN 'YES'
         ELSE 'NO'
     END WILL_BE_INCLUDED,
     i1.*,
     COALESCE(
          (
          SELECT
              MAX('YES')
          FROM
              AR_TRANS art2
          WHERE
              art2.CENTER = i1.CENTER
              AND art2.ID = i1.ID
              and art2.EMPLOYEECENTER = 100 and art2.EMPLOYEEID = 1
              and art2.REF_TYPE = 'ACCOUNT_TRANS'
              and art2.AMOUNT < 0),'NO') MIGRATED_DEBT,
     COALESCE(
          (
          SELECT
              MAX('YES')
          FROM
              AR_TRANS art2
          WHERE
              art2.CENTER = i1.CENTER
              AND art2.ID = i1.ID
              AND art2.TEXT LIKE '%Payment Reminder%'),'NO') REMINDER_FEE
 FROM
     (
         SELECT
             floor(months_between(TRUNC(MIN(art.DUE_DATE)),ap.BIRTHDATE)/12)                                                                                                         PAYER_AGE,
             floor(months_between(TRUNC(MIN(art.DUE_DATE)),op.BIRTHDATE)/12)                                                                                                         SUB_OWNER_AGE,
             s.CENTER || 'ss' || s.ID                                                                                                                                                ssid,
             s.OWNER_CENTER || 'p' || s.OWNER_ID                                                                                                                                     sub_owner_pid,
             ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID                                                                                                                               payer_pid,
             s.END_DATE                                                                                                                                                              sub_end_date,
             CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END                                                                                  AS SUBSCRIPTION_STATE,
             CASE  s.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' ELSE 'UNKNOWN' END AS SUBSCRIPTION_SUB_STATE,
             CASE
                 WHEN s.OWNER_CENTER != ar.CUSTOMERCENTER
                     OR s.OWNER_ID != ar.CUSTOMERID
                 THEN 'OTHER_PAYER'
                 ELSE 'MEMBER'
             END                   WHOS_PAYING,
             MIN(art.DUE_DATE)     OLDEST_DEBT,
             MIN(spp.FROM_DATE)- 1 PAID_UNTIL,
             s.BILLED_UNTIL_DATE,
             ABS(SUM(art.UNSETTLED_AMOUNT))                          total_debt_sub,
             ABS(SUM(art.AMOUNT))                                    total_amount,
             ABS(SUM(art.AMOUNT) - (1 * SUM(art.UNSETTLED_AMOUNT) )) part_paid,
             ar.BALANCE                                              balance_on_account,
             ar.center,
             ar.id,
             s.START_DATE,
             s.END_DATE
         FROM
             SUBSCRIPTIONS s
         JOIN
             PERSONS op
         ON
             op.CENTER = s.OWNER_CENTER
             AND op.ID = s.OWNER_ID
         JOIN
             SUBSCRIPTIONPERIODPARTS spp
         ON
             spp.CENTER = s.CENTER
             AND spp.ID = s.ID
         JOIN
             SPP_INVOICELINES_LINK link
         ON
             link.PERIOD_CENTER = spp.CENTER
             AND link.PERIOD_ID = spp.ID
             AND link.PERIOD_SUBID = spp.SUBID
         JOIN
             INVOICELINES invl
         ON
             invl.CENTER = link.INVOICELINE_CENTER
             AND invl.ID = link.INVOICELINE_ID
             AND invl.SUBID = link.INVOICELINE_SUBID
         JOIN
             AR_TRANS art
         ON
             art.REF_CENTER = invl.CENTER
             AND art.REF_ID = invl.ID
             AND art.REF_TYPE = 'INVOICE'
         JOIN
             ACCOUNT_RECEIVABLES ar
         ON
             ar.CENTER = art.CENTER
             AND ar.ID = art.ID
         JOIN
             PERSONS ap
         ON
             ap.CENTER = ar.CUSTOMERCENTER
             AND ap.ID = ar.CUSTOMERID
         WHERE
             art.UNSETTLED_AMOUNT < 0
             AND art.DUE_DATE < CURRENT_TIMESTAMP
                         and op.center in ($$scope$$)
         GROUP BY
             s.START_DATE,
             s.END_DATE,
             s.BILLED_UNTIL_DATE,
             s.CENTER,
             s.ID,
             s.OWNER_CENTER,
             s.OWNER_ID,
             ar.CUSTOMERCENTER,
             ar.CUSTOMERID,
             ar.BALANCE,
             op.BIRTHDATE,
             ap.BIRTHDATE,
             s.STATE,
             s.SUB_STATE,
             s.END_DATE,
             ar.center,
             ar.id ) i1
 ) t1 where WILL_BE_INCLUDED = 'YES'
