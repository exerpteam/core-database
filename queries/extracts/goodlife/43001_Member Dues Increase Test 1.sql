
SELECT *
		FROM JOURNALENTRIES JE
	WHERE JE.PERSON_CENTER = P.CENTER AND JE.PERSON_ID = P.ID [p.id]
		AND JE.JETYPE = 3 AND 
		( JE.NAME [je.name] LIKE 'Subscription price updat%' OR JE.NAME [je.name] LIKE  'Binding price updat%' )
		AND JE.CREATION_TIME BETWEEN :PriceChangeFromDate 
		AND :PriceChangeToDate