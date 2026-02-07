SELECT
        longtodatec(sc.cancel_time,sc.old_subscription_center) AS cancellation_of_cancellation_req,
        pea.txtvalue AS legacy_id,
        p.external_id,
        p.center || 'p' || p.id AS personId,
        p.fullname,
        s.center || 'ss' || s.id AS subscriptionid,
        pr.name AS productname,
        sc.type    
FROM stjames.subscription_change sc
JOIN stjames.subscriptions s ON sc.old_subscription_center = s.center AND sc.old_subscription_id = s.id
JOIN stjames.persons p ON p.center = s.owner_center AND p.id = s.owner_id
JOIN stjames.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
JOIN stjames.subscriptiontypes st ON st.center = s.subscriptiontype_center AND s.subscriptiontype_id = st.id
JOIN stjames.products pr ON st.center = pr.center AND st.id = pr.id
WHERE
        (sc.employee_center, sc.employee_id) IN ((100,1))
        --AND sc.type NOT IN ('ASSIGNED_EMPLOYEE','SALES_EMPLOYEE','EXTENSION','TYPE')
        AND sc.cancel_time IS NOT NULL
        AND s.sub_comment IS NOT NULL
        AND s.end_date IS NULL