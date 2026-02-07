SELECT 
        pea.txtvalue AS legacy_id,
        p.external_id,
        p.center || 'p' || p.id AS personId,
        p.fullname,
        empp.fullname AS employeename,
        sp.subscription_center || 'ss' || sp.subscription_id AS subscriptionid,
        longtodatec(sp.entry_time, sp.subscription_center) AS entrytime,
        sp.from_date,
        sp.to_date,
        sp.type,
        sp.price,
        s.center || 'ss' || s.id AS subscriptionid,
        pr.name AS productname
FROM stjames.subscription_price sp
JOIN stjames.subscriptions s ON s.center = sp.subscription_center AND s.id = sp.subscription_id
JOIN stjames.persons p ON p.center = s.owner_center AND p.id = s.owner_id
JOIN stjames.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
JOIN stjames.employees e ON sp.employee_center = e.center AND sp.employee_id = e.id
JOIN stjames.persons empp ON empp.center = e.personcenter AND empp.id = e.personid
JOIN stjames.subscriptiontypes st ON st.center = s.subscriptiontype_center AND s.subscriptiontype_id = st.id
JOIN stjames.products pr ON st.center = pr.center AND st.id = pr.id
WHERE
        sp.from_date >= TO_DATe('2025-10-21','YYYY-MM-DD')
        and sp.from_date < TO_DATe('2025-12-01','YYYY-MM-DD')
        AND s.sub_comment IS NOT NULL
        AND sp.cancelled = false
        AND
        (
                s.end_date IS NULL
                OR
                s.end_date > TO_DATe('2025-10-31','YYYY-MM-DD')
        )
        AND
        (sp.employee_center, sp.employee_id) NOT IN ((100,1))