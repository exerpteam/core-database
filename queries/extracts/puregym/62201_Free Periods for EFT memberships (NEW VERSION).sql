-- The extract is extracted from Exerp on 2026-02-08
--  
 /*
 PG free period due to corona virus problem
 1. Exlcude any clubs. Not at the moment.
 2. Add Free period for EFT subscription. From 16-03-2020 to 30-03-2020 both days included. Needs to confirm in the meeting.
 3. Exclude EFT subscription which are meeting following condition
 a. Already fully free/freeze period cover for the above period.
 b. Subscription starting after free period end date
 c. Subscription ended before free period start date.
 d. Subscription ended before above free period end date and already free period added until subscription end date. This is avoid those appear again in the extract.
 4. Exclude subscriptions from these product groups. Staff Subscription, GymFlex (reporting), Staff / PT Subscriptions MS
 */
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$FreeFromDate$$ AS StartDate,
             $$FreeToDate$$ AS EndDate,
             0          AS numberOfDays
         
     )
 SELECT
     s.owner_center || 'p' || s.owner_id AS PersonId,
     b.center ||'ss'|| b.id              AS SubscriptionId,
     s.start_date                        AS "Subscription Start date",
     s.end_date                          AS "Subscription End date",
     s.billed_until_date,
     pea.TXTVALUE AS PUREGYMATHOME--,
     --b.*
 FROM
     (
         SELECT DISTINCT
             -- gr.thread AS threadgroup,
             a.center,
             a.id,
             a.freezestart AS startdate,
             a.freezeend   AS enddate,
             'COVID-19'    AS Text,
             a.TransferDate,
             COALESCE(
                        (
                        SELECT
                            SUM(least(srd2.end_date,a.freezeend) - greatest(srd2.start_date,a.freezestart) + 1)
                        FROM
                            subscription_reduced_period srd2
                        WHERE
                            srd2.subscription_center = a.center
                            AND srd2.subscription_id = a.id
                            AND srd2.state = 'ACTIVE'
                            AND srd2.start_date <= a.freezeend
                            AND srd2.end_date >= a.freezestart), 0) AS free_actual_length,
             (a.freezeend - a.freezestart +1)                       AS free_theoric_length
         FROM
             (
                 SELECT
                     s.center,
                     s.id,
                     s.owner_center || 'p' || s.owner_id AS PersonId,
                     s.center || 'ss' || s.id            AS SubscriptionId,
                     s.start_date,
                     s.end_date,
                     s.billed_until_date,
                     s.refmain_center,
                     s.refmain_id,
                     least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate) AS freezeend,
                     --    greatest(s.start_date, params.StartDate) as freezestart_without_transfer,
                     greatest(greatest(s.start_date, to_date(COALESCE(TO_CHAR(longtodateC(scl.book_start_time, scl.center), 'YYYY-MM-DD'),'1900-01-01'), 'YYYY-MM-DD')), params.StartDate) AS freezestart,
                     to_date(TO_CHAR(longtodateC(scl.book_start_time, scl.center), 'YYYY-MM-DD'), 'YYYY-MM-DD')                                                                            AS TransferDate
                     --    COUNT(*)
                 FROM
                     subscriptions s
                 CROSS JOIN
                     params
                 JOIN
                     subscriptiontypes st
                 ON
                     st.center = s.SUBSCRIPTIONTYPE_CENTER
                     AND st.id = s.SUBSCRIPTIONTYPE_id
                     AND st.st_type = 1
                 JOIN
                      PRODUCTS pr ON
                         pr.center = st.center AND pr.id = st.id
                 LEFT JOIN
                     subscription_reduced_period srd
                 ON
                     srd.subscription_center = s.center
                     AND srd.subscription_id = s.id
                     AND srd.state = 'ACTIVE'
                     AND srd.start_date <= greatest(params.StartDate, s.start_date)
                     AND srd.end_date >= least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate)
                     /* for getting transfer date and move the free period start date if needed */
                 LEFT JOIN
                     state_change_log scl
                 ON
                     scl.center = s.center
                     AND scl.id = s.id
                     AND scl.stateid = 8
                     AND scl.sub_state = 6
                     AND scl.entry_type = 2
                     AND longtodateC(scl.book_start_time, scl.center) > s.start_date
                 WHERE
                     s.center IN ($$Scope$$)
                     AND s.state IN (2,4,8)
                     /* Exclude already fully period free/freeze/savedfree days member */
                     AND srd.id IS NULL
                     /* Exlcude subscription starting after free period end date */
                     AND s.start_date <= params.EndDate
                     /* Exclude subscription ended before free period start date */
                     AND (s.END_DATE IS NULL OR s.END_DATE >= params.StartDate)
                                         /* Exclude free subscription BUDDY_SUBSCRIPTION */
                     AND pr.GLOBALID != 'BUDDY_SUBSCRIPTION'
                     /* Exclude subscriptions from those product groups. Staff Subscription, GymFlex (reporting), Staff / PT Subscriptions MS */
                     AND NOT EXISTS
                     (
                         SELECT
                             1
                         FROM
                             PRODUCT_AND_PRODUCT_GROUP_LINK ppl
                         WHERE
                             ppl.product_center = st.center
                             AND ppl.product_id = st.id
                             AND ppl.PRODUCT_GROUP_ID IN (401,801,6409,11801))) a
     ) b
 JOIN
     subscriptions s
 ON
     s.center = b.center
     AND s.id = b.id
 LEFT JOIN PERSON_EXT_ATTRS pea
         ON pea.PERSONCENTER = s.OWNER_CENTER AND pea.PERSONID = s.OWNER_ID AND pea.NAME = 'PUREGYMATHOME'
 WHERE
     b.free_actual_length != b.free_theoric_length
         AND pea.TXTVALUE IS NULL
