-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        pea.txtvalue AS PersonId,
        pr.globalid AS NewMembershipType,
        mpr.cached_productname AS AddonName,
        sa.start_date AS AddonStartDate,
        sa.end_date AS AddonEndDate,
        sa.individual_price_per_unit AS AddonPrice,
        CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
        CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE,
        c.name as club_name,
        cao.name as Addon_club_name
FROM evolutionwellness.persons p
JOIN evolutionwellness.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId' AND pea.txtvalue IS NOT NULL
JOIN evolutionwellness.subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id
JOIN evolutionwellness.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id
JOIN evolutionwellness.products pr On st.center = pr.center AND st.id = pr.id
JOIN evolutionwellness.subscription_addon sa ON s.center = sa.subscription_center AND s.id = sa.subscription_id
JOIN evolutionwellness.masterproductregister mpr ON mpr.id = sa.addon_product_id 
JOIN evolutionwellness.centers c ON c.id = p.center
JOIN evolutionwellness.centers cao ON cao.id = sa.center_id
WHERE
        s.sub_comment IS NOT NULL
		AND p.center IN (:scope)