SELECT
        pea.txtvalue AS legacy_id,
        p.external_id,
        p.center || 'p' || p.id AS personId,
        p.fullname,
        s.center || 'ss' || s.id AS subscriptionid,
        pr.name AS productname,
        s.subscription_price,
CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE
FROM stjames.subscriptions s
JOIN stjames.persons p ON p.center = s.owner_center AND p.id = s.owner_id
JOIN stjames.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
JOIN stjames.subscriptiontypes st ON st.center = s.subscriptiontype_center AND s.subscriptiontype_id = st.id
JOIN stjames.products pr ON st.center = pr.center AND st.id = pr.id
WHERE
        s.sub_comment IS NOT NULL
        AND s.state IN (2,4,8)