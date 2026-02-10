-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4595
Show discount for ZUR
SELECT
    p.center || 'p' || p.id as "PersonId",
    sub.center || 'ss' || sub.id as "SubscriptionId",
    sp.FROM_DATE "PriceUpdateFromDate",
    sp.price "PriceUpdatePrice",
    (CASE sub.state
        WHEN 2 THEN 'Active'
        WHEN 4 THEN 'Frozen'
        WHEN 8 THEN 'Created'
    END) AS "SubscriptionCurrentState",
    (CASE
        WHEN (sub.BINDING_END_DATE IS NOT null AND sub.BINDING_END_DATE > to_date('2018-08-31', 'YYYY-MM-DD'))
                THEN sub.BINDING_PRICE 
                ELSE sub.SUBSCRIPTION_PRICE 
    END) AS "CurrentPrice",
    (CASE
        WHEN (sub.BINDING_END_DATE IS NOT null AND sub.BINDING_END_DATE > to_date('2018-08-31', 'YYYY-MM-DD'))
                THEN 'True'
                ELSE 'False'
    END) AS "InBindingPeriod",
    sub.BINDING_END_DATE AS "BindingEndDate",
    pr.NAME AS "ProductName",
    sub.START_DATE "SubscriptionStartDate",
    sub.END_DATE "SubscriptionEndDate"
FROM
    persons p
JOIN
    subscriptions sub ON sub.owner_center = p.center AND sub.owner_id = p.id
JOIN
    subscriptiontypes st ON sub.subscriptiontype_center = st.center AND sub.subscriptiontype_id = st.id
JOIN
    products pr ON st.center = pr.center AND st.id = pr.id
LEFT JOIN
        SUBSCRIPTION_PRICE sp ON sp.SUBSCRIPTION_CENTER  = sub.CENTER AND sp.SUBSCRIPTION_ID = sub.id AND sp.FROM_DATE = to_date('2018-09-01', 'YYYY-MM-DD') AND sp.CANCELLED = 0
WHERE
    p.center = 5
    AND p.PERSONTYPE != 2
    AND p.SEX = 'M'
    AND (sub.END_DATE IS NULL OR sub.END_DATE > to_date('2018-08-31', 'YYYY-MM-DD'))
    AND sub.state IN (2,4,8)
    AND SYSDATE < to_date('2018-10-01','yyyy-MM-dd')
    AND st.st_type = 1
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            HP.SUBSCRIPTION_REDUCED_PERIOD csfp
        WHERE
            csfp.SUBSCRIPTION_CENTER = sub.CENTER
            AND csfp.SUBSCRIPTION_ID = sub.ID
            AND csfp.STATE = 'ACTIVE'
            AND csfp.START_DATE <= to_date('2018-10-01','yyyy-MM-dd')
            AND csfp.END_DATE >= to_date('2018-09-01','yyyy-MM-dd')
            AND csfp.type NOT IN ('SUBS_PERIOD'))
ORDER BY pr.NAME