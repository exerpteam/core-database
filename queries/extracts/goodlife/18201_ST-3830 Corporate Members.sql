SELECT
        (CASE p.persontype
                WHEN 0 THEN 'Private'
                WHEN 1 THEN 'Student'
                WHEN 2 THEN 'Staff'
                WHEN 4 THEN 'Corporate'
        END) AS "Person Type",
        comp.center || 'p' || comp.id AS "CompanyId",
        p.center || 'p' || p.id AS "PersonId",
        pd.name AS "SubscriptionName",
        r.relativecenter || 'p' || r.relativeid || 'rpt' || r.relativesubid AS "CompanyAgreementId",
        s.start_date AS "StartDate",
        s.end_date AS "EndDate",
        s.billed_until_date AS "BilledUntilDate",
        pag.individual_deduction_day AS "CompanyDeductionDay",
        (CASE 
                WHEN s.renewal_policy_override=9 THEN 'Prepaid'
                WHEN s.renewal_policy_override=10 THEN 'Postpaid'
                ELSE 'Unknown'
        END) AS "PaymentPolicy",
        s.center || 'ss' || s.id "SubscriptionId"
FROM goodlife.subscriptions s
JOIN goodlife.persons p ON s.owner_center = p.center AND s.owner_id = p.id
JOIN goodlife.products pd
        ON s.subscriptiontype_center = pd.center AND s.subscriptiontype_id = pd.id
LEFT JOIN goodlife.relatives r
        ON r.center = p.center AND r.id = p.id AND r.rtype IN (3) AND r.status = 1
LEFT JOIN goodlife.persons comp
        ON comp.center = r.relativecenter AND comp.id = r.relativeid
LEFT JOIN goodlife.account_receivables ar
        ON ar.customercenter = comp.center AND ar.customerid = comp.id AND ar.ar_type = 4
LEFT JOIN goodlife.payment_accounts pac
        ON pac.center = ar.center AND pac.id = ar.id
LEFT JOIN goodlife.payment_agreements pag
        ON pag.center = pac.active_agr_center AND pag.id = pac.active_agr_id AND pag.subid = pac.active_agr_subid   
WHERE
        pd.globalid = 'PAP_M_ALL_CLUB_KAFP'
        AND s.state IN (2,4,8)
        AND (:personId = 'All' OR (p.center || 'p' || p.id)=:personId)
		AND (:subscriptionId = 'All' OR (s.center || 'ss' || s.id)=:subscriptionId)
		AND (:subscriptionName = 'All' OR pd.name=:subscriptionName)
        AND (:CompanyAgreement = 'All' OR (r.relativecenter || 'p' || r.relativeid || 'rpt' || r.relativesubid)=:CompanyAgreement)
		AND 
                (s.end_date IS NULL OR s.billed_until_date IS NULL OR s.end_date != s.billed_until_date) 
        AND     
                s.payment_agreement_center IS NOT NULL
EXCEPT        
SELECT
        (CASE p.persontype
                WHEN 0 THEN 'Private'
                WHEN 1 THEN 'Student'
                WHEN 2 THEN 'Staff'
                WHEN 4 THEN 'Corporate'
        END) AS "Person Type",
        comp.center || 'p' || comp.id AS "CompanyId",
        p.center || 'p' || p.id AS "PersonId",
        pd.name AS "SubscriptionName",
        r.relativecenter || 'p' || r.relativeid || 'rpt' || r.relativesubid AS "CompanyAgreementId",
        s.start_date AS "StartDate",
        s.end_date AS "EndDate",
        s.billed_until_date AS "BilledUntilDate",
        pag.individual_deduction_day AS "CompanyDeductionDay",
        (CASE 
                WHEN s.renewal_policy_override=9 THEN 'Prepaid'
                WHEN s.renewal_policy_override=10 THEN 'Postpaid'
                ELSE 'Unknown'
        END) AS "PaymentPolicy",
        s.center || 'ss' || s.id "SubscriptionId"
FROM goodlife.subscriptions s
JOIN goodlife.persons p ON s.owner_center = p.center AND s.owner_id = p.id
JOIN goodlife.products pd
        ON s.subscriptiontype_center = pd.center AND s.subscriptiontype_id = pd.id
LEFT JOIN goodlife.relatives r
        ON r.center = p.center AND r.id = p.id AND r.rtype IN (3) AND r.status = 1
LEFT JOIN goodlife.persons comp
        ON comp.center = r.relativecenter AND comp.id = r.relativeid
LEFT JOIN goodlife.account_receivables ar
        ON ar.customercenter = comp.center AND ar.customerid = comp.id AND ar.ar_type = 4
LEFT JOIN goodlife.payment_accounts pac
        ON pac.center = ar.center AND pac.id = ar.id
LEFT JOIN goodlife.payment_agreements pag
        ON pag.center = pac.active_agr_center AND pag.id = pac.active_agr_id AND pag.subid = pac.active_agr_subid 
WHERE
        pd.globalid = 'PAP_M_ALL_CLUB_KAFP'
        AND s.state IN (2,4,8)
        AND
                (
                        (s.renewal_policy_override=9 AND s.billed_until_date=(date_trunc('MONTH',current_date) + INTERVAL '1 MONTH - 1 day') AND pag.individual_deduction_day=1)
                        OR
                        (s.renewal_policy_override=10 AND s.billed_until_date=(date_trunc('MONTH',current_date) + INTERVAL '- 1 day') AND pag.individual_deduction_day=1)
                        OR
                        (s.renewal_policy_override=9 AND pag.individual_deduction_day=15 AND s.billed_until_date=(CASE 
                                                                                                                        WHEN EXTRACT(DAY FROM CURRENT_DATE)<14 THEN
  																														   make_date(CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT),CAST(EXTRACT(MONTH FROM CURRENT_DATE) AS INT),14)
                                                                                                                        ELSE 
																														   CASE
																														     WHEN EXTRACT(MONTH FROM CURRENT_DATE) = 12
																															   THEN
																														          make_date(CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT)+1,1,14)
																															   ELSE
																															      make_date(CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT),CAST(EXTRACT(MONTH FROM CURRENT_DATE) AS INT)+1,14)
																															END
                                                                                                                  END) 
                        )
                        OR
                        (s.renewal_policy_override=10 AND pag.individual_deduction_day=15 AND s.billed_until_date=(CASE 
                                                                                                                        WHEN EXTRACT(DAY FROM CURRENT_DATE)<14 THEN 
																														   CASE  
																														       WHEN EXTRACT(MONTH FROM CURRENT_DATE) = 1
																														         THEN
																																    make_date(CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT)-1,12,14)
																																 ELSE
																														             make_date(CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT),CAST(EXTRACT(MONTH FROM CURRENT_DATE) AS INT)-1,14)
																														   END
                                                                                                                        ELSE 
																														   make_date(CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT),CAST(EXTRACT(MONTH FROM CURRENT_DATE) AS INT),14)
                                                                                                                  END) 
                        )
                )     
                

--(date_trunc('MONTH',current_date) + INTERVAL '1 MONTH - 1 day')