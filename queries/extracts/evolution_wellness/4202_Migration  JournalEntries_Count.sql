SELECT
        pea.txtvalue AS PersonId,
        SUM(CASE WHEN je.name = 'PreviousLegacyMembershipNumber' THEN 1 ELSE 0 END) AS total_type_PreviousLegacyMembershipNumber,
        SUM(CASE WHEN je.name = 'ReferralCode' THEN 1 ELSE 0 END) AS total_type_ReferralCode,
        SUM(CASE WHEN je.name = 'SubscriptionAdjustments' THEN 1 ELSE 0 END) AS total_type_SubscriptionAdjustments,
        SUM(CASE WHEN je.name IN ('PreviousLegacyMembershipNumber','ReferralCode','SubscriptionAdjustments') THEN 0 ELSE 1 END) AS total_journal_entries_received
FROM evolutionwellness.persons p
JOIN evolutionwellness.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
JOIN evolutionwellness.journalentries je ON je.person_center = p.center AND je.person_id = p.id
WHERE
        p.center IN (:Scope)
		AND p.sex NOT IN ('C')
        AND je.creatorcenter = 100
        AND je.creatorid = 1
        AND je.name NOT IN ('Person created')
GROUP BY
        pea.txtvalue
	