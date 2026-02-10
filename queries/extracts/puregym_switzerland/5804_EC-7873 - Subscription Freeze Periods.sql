-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        s.owner_center AS "Member Center",
        CAST(s.owner_id AS TEXT) AS "Member ID",
        sfp.start_date AS "Start",
        sfp.end_date AS "Stop",
        TO_CHAR(longtodateC(sfp.entry_time, s.owner_center), 'dd-MM-YYYY') AS "Date of registration",
        sfp.text AS "Text",
        TO_CHAR(longtodateC(sfp.last_modified, s.owner_center), 'dd-MM-YYYY') AS "Latest adjustment",
        s.binding_end_date AS "Binding period ended",
        s.binding_price AS "Binding price",
        s.subscription_price AS "Membership price"
FROM subscriptions s
JOIN subscription_freeze_period sfp
        ON sfp.subscription_center = s.center
        AND sfp.subscription_id = s.id
WHERE
        (s.owner_center,s.owner_id) IN (:memberid)