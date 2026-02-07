SELECT DISTINCT
    oldsub.center || 'ss' || oldsub.id AS "Originating Subscription Number",
    newsub.center || 'ss' || newsub.id AS "Destination Subscription Number",
    sc.effect_date                     AS "Transfer Date",
    fromcenter.id                      AS "Originating Club Number",
    fromcenter.NAME                    AS "Originating Club Name",
    tocenter.id                        AS "Destination Club Number",
    tocenter.NAME                      AS "Destination Club Name",
    'EFT/PAP'                          AS "Subscription Type",
    pg.name                            AS "Primary Product Group",
    pd.name                            AS "Product Name",
    newsub.subscription_price          AS "Billing Amount Gross",
    CASE
        WHEN newst.periodunit = 0
        THEN 'BI-Weekly'
        ELSE 'Monthly'
    END AS "Billing Cycle",
    CASE
        WHEN oldsub.renewal_policy_override = 9
        THEN 'Pre-Pay'
        WHEN oldsub.renewal_policy_override IN (6,10)
        THEN 'Post-Pay'
        ELSE 'Unknown'
    END AS "Renewal Policy"
        

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
    AND oldst.st_type = 1
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
    AND sc.effect_date BETWEEN $$TransferDateFrom$$ and $$TransferDateTo$$
    