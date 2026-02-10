-- The extract is extracted from Exerp on 2026-02-08
-- Amount of sales made by the GymPass API User
SELECT
        pr.name,
        emp.center || 'emp' || emp.id as emp_number,
        longtodatec(s.creation_time, s.center) as creation_datime,
        p.fullname,
        CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE,
        CASE s.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUBSCRIPTION_SUB_STATE

FROM vivagym.subscriptions s
JOIN vivagym.centers c ON s.center = c.id AND c.country = 'ES'
JOIN vivagym.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id
JOIN vivagym.products pr ON st.center = pr.center AND st.id = pr.id
JOIN vivagym.employees emp ON emp.center = s.creator_center AND emp.id = s.creator_id
JOIN vivagym.persons p ON emp.personcenter = p.center AND emp.personid = p.id
WHERE
        pr.globalid = 'GYMPASS'
        AND emp.center = 100
        AND emp.id = 10801
