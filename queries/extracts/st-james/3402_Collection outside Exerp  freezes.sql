SELECT
        longtodatec(sfp.entry_time, sfp.subscription_center) freeze_entry_time,
        pea.txtvalue AS legacy_id,
        p.external_id,
        p.center || 'p' || p.id AS personId,
        sfp.start_date freeze_from,
        sfp.end_date freeze_to,
        sfp.type,
        p.fullname,
        empp.fullname employeename,
        s.center || 'ss' || s.id AS subscription_id,
        pr.name
        
FROM stjames.subscription_freeze_period sfp
JOIN stjames.subscriptions s ON sfp.subscription_center = s.center AND sfp.subscription_id = s.id
JOIN stjames.employees e ON sfp.employee_center = e.center AND sfp.employee_id = e.id
JOIN stjames.persons empp ON empp.center = e.personcenter AND empp.id = e.personid
JOIN stjames.persons p ON p.center = s.owner_center AND p.id = s.owner_id
JOIN stjames.subscriptiontypes st ON st.center = s.subscriptiontype_center AND s.subscriptiontype_id = st.id
JOIN stjames.products pr ON st.center = pr.center AND st.id = pr.id
LEFT JOIN stjames.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
WHERE
        (sfp.employee_center, sfp.employee_id) NOT IN ((100,1))
        AND sfp.state NOT IN ('CANCELLED')
        AND s.sub_comment is not null