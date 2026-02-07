SELECT 
  ip.ID AS "ID",
	CASE
		WHEN P.SEX != 'C'
		THEN
			CASE
				WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
						OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
				THEN
					(
						SELECT
							EXTERNAL_ID
						FROM
							PERSONS
						WHERE
							CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
							AND ID = p.TRANSFERS_CURRENT_PRS_ID)
				ELSE p.EXTERNAL_ID
			END
		ELSE NULL
	END AS "PERSON_ID",
	CASE
		WHEN P.SEX = 'C'
		THEN
			CASE
				WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
						OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
				THEN
					(
						SELECT
							EXTERNAL_ID
						FROM
							PERSONS
						WHERE
							CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
							AND ID = p.TRANSFERS_CURRENT_PRS_ID)
				ELSE p.EXTERNAL_ID
			END
		ELSE NULL
	END AS "COMPANY_ID",
  ip.creation_time              AS "CREATION_DATETIME",
  ip.end_date                   AS "END_DATE",
  ip.amount                     AS "TOTAL_AMOUNT",
  ip.installements_count        AS "INSTALLMENT_COUNT",
  ip.collect_agreement_center||'ar'||ip.collect_agreement_id||'agr'||ip.collect_agreement_subid  "PAYMENT_AGREEMENT_ID",
  ip.person_center              AS "CENTER_ID",
  ip.last_modified              AS "ETS"
FROM 
  installment_plans ip  
LEFT JOIN
  persons p
ON
  ip.person_center = p.center
  AND ip.person_id = p.id    

