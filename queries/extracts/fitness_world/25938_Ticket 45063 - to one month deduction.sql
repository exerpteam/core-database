-- This is the version from 2026-02-05
--  
SELECT
    s.OWNER_CENTER || 'p' || s.OWNER_ID                     pid,
    TO_CHAR(s.BILLED_UNTIL_DATE,'YYYY-MM-DD')               billed_until,
    TO_CHAR(s.BILLED_UNTIL_DATE + 1,'YYYY-MM-DD')           next_period_start,
    TO_CHAR(add_months(s.BILLED_UNTIL_DATE,2),'YYYY-MM-DD') next_period_end,
    TO_CHAR(sfp.START_DATE,'YYYY-MM-DD')                    freeze_start,
    TO_CHAR(sfp.END_DATE,'YYYY-MM-DD')                      freeze_end,
    CASE
        WHEN (( sfp.START_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,2))
                OR sfp.END_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,2))
        THEN 1
        ELSE 0
    END AS "START OR END IN NEXT PERIOD",
    CASE
        WHEN NOT ( sfp.START_DATE = s.BILLED_UNTIL_DATE + 1
                AND sfp.END_DATE = add_months(s.BILLED_UNTIL_DATE,2))
        THEN 1
        ELSE 0
    END AS "FREEZE NOT COVERING PERIOD",
    CASE
        WHEN NOT(( sfp.START_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,1))
                OR sfp.END_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,1))
        THEN 1
        ELSE 0
    END AS "NO FREEZE IN NEXT MONTH",
    CASE
        WHEN (( sfp.START_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,2))
                OR sfp.END_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,2))
            -- not freezes exactly covering the new invoicing period
            AND NOT ( sfp.START_DATE = s.BILLED_UNTIL_DATE + 1
                AND sfp.END_DATE = add_months(s.BILLED_UNTIL_DATE,2))
            -- There should be no freeze in the next comming month (should be free)
            AND NOT(( sfp.START_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,1))
                OR sfp.END_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,1))
        THEN 1
        ELSE 0
    END AS "WILL BE INCLUDED"
FROM
    SUBSCRIPTION_FREEZE_PERIOD sfp
JOIN
    SUBSCRIPTIONS s
ON
    s.CENTER = sfp.SUBSCRIPTION_CENTER
    AND s.ID = sfp.SUBSCRIPTION_ID
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = s.SUBSCRIPTIONTYPE_ID
    AND st.ST_TYPE = 1
WHERE
    sfp.STATE = 'ACTIVE'
    -- rules
    -- No renewal policy override (on 2 month deduction)
    AND s.RENEWAL_POLICY_OVERRIDE IS NULL
    AND s.STATE IN (1,4,8)
    -- Sub end date null or end date > billed until date
    AND (
        s.END_DATE IS NULL
        OR s.END_DATE > s.BILLED_UNTIL_DATE)
	and s.center in ($$scope$$)
    /*
    -- Start or end of freeze between next billign period
    AND ((
    sfp.START_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,2))
    OR sfp.END_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,2))
    -- not freezes exactly covering the new invoicing period
    AND NOT (
    sfp.START_DATE = s.BILLED_UNTIL_DATE + 1
    AND sfp.END_DATE = add_months(s.BILLED_UNTIL_DATE,2))
    -- There should be no freeze in the next comming month (should be free)
    AND NOT((
    sfp.START_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,1))
    OR sfp.END_DATE BETWEEN s.BILLED_UNTIL_DATE + 1 AND add_months(s.BILLED_UNTIL_DATE,1))
    */
    