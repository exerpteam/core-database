-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        pea.txtvalue AS PersonId,
        pr.globalid AS NewMembershipType,
        sp.from_date,
        sp.to_date,
        sp.price
FROM evolutionwellness.persons p
JOIN evolutionwellness.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId' AND pea.txtvalue IS NOT NULL
JOIN evolutionwellness.subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id
JOIN evolutionwellness.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id
JOIN evolutionwellness.products pr On st.center = pr.center AND st.id = pr.id
JOIN evolutionwellness.subscription_price sp ON sp.subscription_center = s.center AND sp.subscription_id = s.id
WHERE
        s.sub_comment IS NOT NULL
        AND p.center IN (:Scope)
ORDER BY 1,3