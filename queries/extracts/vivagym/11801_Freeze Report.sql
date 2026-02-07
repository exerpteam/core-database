SELECT
        s.owner_center || 'p' || s.owner_id AS personId,
        s.center || 'ss' || s.id AS subscriptionId,
        pr.globalid,
        pr.name AS product_name,
        sfp.start_date,
        sfp.end_date,
        sfp.entry_time,
		sfp.subscription_center,
        longtodateC(sfp.entry_time, s.center) as freeze_creation_time,
        sfp.text,
        sfp.type,
        sfp.state,
        longtodateC(sfp.cancel_time, s.center) AS freeze_cancelation_time
FROM vivagym.subscriptions s
JOIN centers c ON s.center = c.id AND c.country = 'ES'
JOIN vivagym.products pr ON s.subscriptiontype_center = pr.center AND s.subscriptiontype_id = pr.id
JOIN vivagym.subscription_freeze_period sfp 
        ON s.center = sfp.subscription_center AND s.id = sfp.subscription_id
WHERE
        sfp.end_date >= TO_DATE(:FromDate,'YYYY-MM-DD') 
		AND sfp.start_date <= TO_DATE(:ToDate,'YYYY-MM-DD')