-- The extract is extracted from Exerp on 2026-02-08
-- former "Ticket 72108 - price change 01.02.16"
SELECT
    p.center || 'p' || p.id AS "Member ID",
    p.fullname AS "Member Name",
    s.center || 'ss' || s.id AS "Subscription ID",
    products.name AS "Subscription name",

    CASE 
        WHEN s.state = 2 THEN 'ACTIVE'
        WHEN s.state = 3 THEN 'ENDED'
        WHEN s.state = 4 THEN 'FROZEN'
        WHEN s.state = 7 THEN 'WINDOW'
        WHEN s.state = 8 THEN 'CREATED'
        ELSE 'UNKNOWN'
    END AS "Subscription State",

    p2.fullname AS "Employee Name",
    sp.employee_center || 'emp' || sp.employee_id AS "Employee ID",
    sp.from_date AS "Price Change: FromDate",
    sp.to_date AS "Price Change: ToDate",
    to_timestamp(sp.entry_time / 1000) AS "Price Change: EntryTime", -- hvis entry_time er i ms
    s.subscription_price AS "Current price",
    sp.price AS "ny pris"

FROM subscription_price sp
JOIN subscriptions s
    ON sp.subscription_center = s.center
   AND sp.subscription_id = s.id
JOIN persons p
    ON s.owner_center = p.center
   AND s.owner_id = p.id
JOIN subscriptiontypes st
    ON s.subscriptiontype_center = st.center
   AND s.subscriptiontype_id = st.id
JOIN products
    ON st.center = products.center
   AND st.id = products.id
JOIN employees e
    ON e.center = sp.employee_center
   AND e.id = sp.employee_id
JOIN persons p2
    ON e.personcenter = p2.center
   AND e.personid = p2.id
WHERE sp.cancelled = 0
  AND s.state IN (2,4)
  AND p.center IN (:scope)
  AND sp.from_date >= DATE '2026-01-16'  -- her filtreres kun fra 1/1-2026 og frem
