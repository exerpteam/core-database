SELECT
    p.external_id
	
FROM 
	persons p
    
LEFT JOIN
        vivagym.person_ext_attrs peac
        ON p.center = peac.personcenter AND p.id = peac.personid AND peac.name = '_eClub_PassportIssuanceCountry'
LEFT JOIN
        vivagym.person_ext_attrs pean
        ON p.center = pean.personcenter AND p.id = pean.personid AND pean.name = '_eClub_PassportNumber'

WHERE
    
        (peac.txtvalue IN (:PassportCountry)
        AND 
        pean.txtvalue IN (:PassportNumber))