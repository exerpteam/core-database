-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-11062
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
                         $$FreeFromDate$$ AS StartDate,
             $$FreeToDate$$ AS EndDate,
             ID                          AS Center,
             'COVID-19 '|| $$FreeFromDate$$ || ' - ' || $$FreeToDate$$  AS coment
                 FROM
                         CENTERS
                 WHERE
                     country = 'IT'
     )
 select --a.center - mod(a.center,20) as threadgroup,
 distinct
 --gr.thread as threadgroup,
 a.PersonId, a.SubscriptionId, a.freezestart as Freeze_Start_Date, a.freezeend as Freeze_End_Date, a.start_date, a.end_date
 --, 'CONDITIONAL' as type
 --, a.*, a.freezeend - a.freezestart + 1 as FreezeLength
 from (
 SELECT
     s.center, s.id,
     s.owner_center || 'p' || s.owner_id AS PersonId,
     s.center || 'ss' || s.id            AS SubscriptionId,
     s.start_date,
     s.end_date,
     s.billed_until_date,
     s.refmain_center, s.refmain_id,
 --    existsrd.start_date AS ExistingSavedFreezStart,
 --    existsrd.end_date   AS ExistingSavedFreezeEnd,
 --    existsrd.type       AS ExistingSavedFreezeType,
     case
         when srd_partial_end.id is not null then srd_partial_end.start_date - 1
         else
         least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate)
     end as freezeend,
     case
         when srd_partial_start.id is not null then srd_partial_start.end_date + 1
         else greatest(s.start_date, params.StartDate)
     end as freezestart
     --    COUNT(*)
 FROM
     subscriptions s
 JOIN
     params
 ON
         params.center = s.center
 JOIN
     subscriptiontypes st
 ON
     st.center = s.SUBSCRIPTIONTYPE_CENTER
     AND st.id = s.SUBSCRIPTIONTYPE_id
     AND st.st_type = 1
 JOIN
         PRODUCTS pr
 ON
         pr.center = st.center
         AND pr.id = st.id
 JOIN
         exerp_hy.ST11062_GLOBALID t
 ON
         t.GLOBALID = pr.GLOBALID
 /* LEFT JOIN
     subscription_reduced_period existsrd
 ON
     existsrd.subscription_center = s.center
     AND existsrd.subscription_id = s.id
     AND existsrd.state = 'ACTIVE'
     AND existsrd.start_date <= params.EndDate
     AND existsrd.end_date >= params.startdate */
 LEFT JOIN
     subscription_reduced_period srd
 ON
     srd.subscription_center = s.center
     AND srd.subscription_id = s.id
     AND srd.state = 'ACTIVE'
     AND srd.start_date <= greatest(params.StartDate, s.start_date)
     AND srd.end_date >= least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate)
 LEFT JOIN
     subscription_reduced_period srd_partial_start
 ON
     srd_partial_start.subscription_center = s.center
     AND srd_partial_start.subscription_id = s.id
     AND srd_partial_start.state = 'ACTIVE'
     AND srd_partial_start.start_date <= greatest(params.StartDate, s.start_date)
     AND srd_partial_start.end_date < least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate)
     AND srd_partial_start.end_date >= greatest(params.StartDate, s.start_date)
 LEFT JOIN
     subscription_reduced_period srd_partial_end
 ON
     srd_partial_end.subscription_center = s.center
     AND srd_partial_end.subscription_id = s.id
     AND srd_partial_end.state = 'ACTIVE'
     AND srd_partial_end.start_date > greatest(params.StartDate, s.start_date)
     AND srd_partial_end.start_date <= least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate)
     AND srd_partial_end.end_date >= least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate)
 WHERE
     s.center = params.Center
         AND s.center in (:Scope)
     AND s.state IN (2,4,8)
     /* Exclude already fully period free/freeze/savedfree days member */
     AND srd.id IS NULL
     /* only include those with one freeze/free period in the interval */
     AND (srd_partial_end.id is null OR srd_partial_start.id is null)
     /* Exlcude subscription starting after free period end date */
     AND s.start_date <= params.EndDate
     /* Exclude subscription ended before free period start date */
     AND (
         s.end_date IS NULL
         OR s.end_date >= params.StartDate)
     /* Include subscription end date is null or end date after BUD or end date is same as BUD and another EFT subscription starting X days from current subscription end date*/
 /*    AND (
         s.end_date IS NULL
         OR s.end_date >s.billed_until_date
         OR (
             EXISTS
             (
                 SELECT
                     1
                 FROM
                     subscriptions sub,
                     subscriptiontypes subst
                 WHERE
                     sub.owner_center = s.owner_center
                     AND sub.owner_id = s.owner_id
                     AND sub.state = 8
                     AND subst.center = sub.SUBSCRIPTIONTYPE_CENTER
                     AND subst.id = s.SUBSCRIPTIONTYPE_id
                     AND subst.st_type = 1
                     AND sub.start_date >= now()
                     AND sub.start_date <= s.end_date + params.numberOfDays)))
                     */
     /* Exclude partial free period added until subscription end date. Free period end date is same as subscription end date */
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             subscription_reduced_period srd1
         WHERE
             srd1.subscription_center = s.center
             AND srd1.subscription_id = s.id
             AND srd1.state = 'ACTIVE'
             AND srd1.start_date <= params.StartDate
             AND srd1.end_date = COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')))
 --and s.center in (27,132,266)
 --and s.id < 6
 ) a
 --cross join params
 --join d20200317_freeperiod_groups gr
 --on gr.center = a.center
 WHERE
         NOT EXISTS
     (
         SELECT
             1
         FROM
             subscription_reduced_period srd2
         WHERE
             srd2.subscription_center = a.center
             AND srd2.subscription_id = a.id
             AND srd2.state = 'ACTIVE'
             AND srd2.start_date <= a.freezestart
             AND srd2.end_date >= a.freezeend )
