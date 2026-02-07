SELECT *
 FROM
		PERSON_EXT_ATTR pa
	WHERE
		--pa.NAME = 'eClub_IsAcceptingThirdPartyOffers'
		--AND p.CENTRE = pa.PERSONCENTER
		--AND p.ID = pa.PERSONID
		P.CENTRE = 4
		AND P.ID = 37808