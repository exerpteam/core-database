-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS (
    SELECT
        c.id,
        (CURRENT_TIMESTAMP AT TIME ZONE c.time_zone)::DATE AS today_center
    FROM centers c
),

base AS (
    SELECT
        p.center || 'p' || p.id AS person_key,
        s.center || 'ss' || s.id AS trial_subscription_key,
        s.state AS trial_state_code,
        s_check.id AS rollover_subscription_id,
        CASE
            WHEN (
                (
                    s.start_date + m.change_interval < c.today_center
                    AND scStop.old_subscription_center IS NULL
                )
                OR (
                    s.start_date + m.change_interval + interval '1 days' < c.today_center
                    AND s_check.center IS NULL
                )
            ) THEN 'Failed'
            WHEN (
                s.start_date + m.change_interval >= c.today_center
              
                AND scStop.old_subscription_center IS NULL
            ) THEN 'Subscription stop event on ' || (s.start_date + m.change_interval)::date::text
            WHEN (
                s.start_date + m.change_interval = c.today_center
                AND s_check.center IS NULL
                AND scStop.old_subscription_center IS NOT NULL
            ) THEN 'Subscription sale event tomorrow'
            WHEN (
                s.start_date + m.change_interval < c.today_center
                AND s_check.center IS NOT NULL
                AND scStop.old_subscription_center IS NOT NULL
            ) THEN 'Subscription sold'
            ELSE 'NA'
        END AS rollover_status,
        (s.start_date + m.change_interval)::date AS stop_event_date,
        s.center AS trial_center,
        s.id AS trial_id,
        CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE,
        CASE s.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUBSCRIPTION_SUB_STATE,
        s.start_date AS trial_start,
        s.end_date AS trial_end,
        s.billed_until_date AS trial_billed_until,
        pd.name AS trial_product,
        pd.globalid AS trial_product_id,
        p.center AS person_center,
        p.id AS person_id,
        p.status AS person_status_code,
CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
        pd_check.center AS product_center,
        pd_check.id AS product_id,
        pd_check.name AS rollover_product,
        pd_check.globalid AS rollover_id,
        (c.today_center + SUM(
            CASE
                WHEN sfp.start_date <= c.today_center
                THEN (sfp.end_date - sfp.start_date)
                ELSE 0
            END
        ) * INTERVAL '1 day')::date AS end_date_with_freeze,
        ((c.today_center + SUM(
            CASE
                WHEN sfp.start_date <= c.today_center
                THEN (sfp.end_date - sfp.start_date)
                ELSE 0
            END
        ) * INTERVAL '1 day') + INTERVAL '1 day')::date AS start_date_with_freeze,
        (sfp.start_date <= c.today_center OR sfp.start_date IS NULL) AS no_future_freeze,
        s_check.start_date AS subscription_start,
        s_check.center || 'ss' || s_check.id AS subscription_key,
		CASE s_check.state  WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE
    FROM public.EC8489_map_for_process_automation m
    JOIN hp.products pd
        ON pd.globalid = m.freemium_global_id
    JOIN hp.subscriptions s
        ON s.subscriptiontype_center = pd.center
       AND s.subscriptiontype_id = pd.id
    JOIN hp.persons p
        ON s.owner_center = p.center
       AND s.owner_id = p.id
    JOIN params c
        ON p.center = c.id
    LEFT JOIN hp.products pd_check
        ON m.rollover_global_id = pd_check.globalid
       AND pd_check.center = s.center
       AND pd_check.blocked = false
       AND pd_check.ptype = 10
    LEFT JOIN hp.subscriptions s_check
        ON p.center = s_check.owner_center
       AND p.id = s_check.owner_id
       AND s_check.subscriptiontype_center = pd_check.center
       AND s_check.subscriptiontype_id = pd_check.id
       AND s_check.creator_center || 'emp' || s_check.creator_id = '100emp19206'
    LEFT JOIN hp.subscription_freeze_period sfp
        ON sfp.subscription_center = s.center
       AND sfp.subscription_id = s.id
       AND sfp.state = 'ACTIVE'
       AND sfp.cancel_time IS NULL
       AND sfp.end_date > c.today_center
    LEFT JOIN subscription_change scStop
        ON s.center = scStop.old_subscription_center
       AND s.id = scStop.old_subscription_id
       AND scStop.type = 'END_DATE'
       AND scStop.cancel_time IS NULL
       AND scStop.employee_center || 'emp' || scStop.employee_id = '100emp19206'
    WHERE
        s.start_date + m.change_interval - interval '2 month' <= c.today_center
    AND s.start_date + m.change_interval + interval '2 month' >= c.today_center
    AND (s.end_date IS NULL OR scStop.old_subscription_center IS NOT NULL)
    GROUP BY
        p.center, p.id,
        s.center, s.id, s.state, s.sub_state,
        s.start_date, s.end_date, s.billed_until_date,
        pd.name, pd.globalid,
        p.status,
        pd_check.center, pd_check.id, pd_check.name, pd_check.globalid,
        sfp.id, sfp.start_date, sfp.end_date,
        s_check.center, s_check.id, s_check.start_date,
        c.today_center, scStop.old_subscription_center,
        m.change_interval
)

SELECT *
FROM base
WHERE
    trial_state_code IN (2,4,8)

UNION ALL

SELECT *
FROM base
WHERE
    trial_state_code NOT IN (2,4,8)
AND rollover_subscription_id IS NOT NULL;
