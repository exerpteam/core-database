SELECT DISTINCT
    oldsub.center || 'ss' || oldsub.id AS "Originating Subscription Number",
    newsub.center || 'ss' || newsub.id AS "Destination Subscription Number",
    sc.effect_date                     AS "Transfer Date",
    fromcenter.id                      AS "Originating Club Number",
    fromcenter.NAME                    AS "Originating Club Name",
    tocenter.id                        AS "Destination Club Number",
    tocenter.NAME                      AS "Destination Club Name",
    'Recurring Clip Card Subscriptions'AS "Subscription Type",
    pg.name                            AS "Primary Product Group",
    pd.name                            AS "Product Name",
    newsub.subscription_price          AS "Billing Amount Gross",
    CASE
        WHEN newst.periodunit = 0
        THEN 'BI-Weekly'
        ELSE 'Monthly'
    END AS "Billing Cycle"
FROM
    subscriptions oldsub
JOIN
    subscription_change sc
ON
    sc.old_subscription_center = oldsub.center
    AND sc.old_subscription_id = oldsub.id
    AND sc.type = 'TRANSFER'
JOIN
    subscriptiontypes oldst
ON
    oldst.center = oldsub.subscriptiontype_center
    AND oldst.id = oldsub.subscriptiontype_id
    AND oldst.st_type = 2
JOIN
    subscriptions newsub
ON
    newsub.center = oldsub.transferred_center
    AND newsub.id = oldsub.transferred_id
JOIN
    subscriptiontypes newst
ON
    newst.center = newsub.subscriptiontype_center
    AND newst.id = newsub.subscriptiontype_id
JOIN
    centers fromcenter
ON
    fromcenter.ID=oldsub.owner_center
JOIN
    centers tocenter
ON
    tocenter.ID=newsub.owner_center
JOIN
    products pd
ON
    pd.center = newst.center
    AND pd.id = newst.id
JOIN
    product_group pg
ON
    pg.id = pd.primary_product_group_id
WHERE
    oldsub.sub_state = 6
    AND newsub.center IN ($$Scope$$)
    AND sc.effect_date BETWEEN $$TransferDateFrom$$  AND $$TransferDateTo$$
    