WITH
    params AS
    (
        SELECT
            s.changed_to_center,
            s.changed_to_id
        FROM
            goodlife.subscriptions s
        WHERE
            s.sub_state IN (3,4)
        AND s.state = 3
        AND EXTRACT(YEAR FROM (longtodateC(s.creation_time, s.owner_center))) = 2022
    )
SELECT
    s.owner_center||'p'||s.owner_id AS personid,
    s.center||'ss'||s.id            AS new_subscription,
    p.name                          AS subscription_name
FROM
    goodlife.subscriptions s
JOIN
    params
ON
    s.center = params.changed_to_center
AND s.id = params.changed_to_id
AND s.state IN (2,8)
JOIN
    goodlife.products p
ON
    s.subscriptiontype_center = p.center
AND s.subscriptiontype_id = p.id
LEFT JOIN
    goodlife.journalentries je
ON
    s.center = je.ref_center
AND s.id = je.ref_id
AND je.jetype = 1
WHERE
    je.id IS NULL ;