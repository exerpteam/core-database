/**
* Extract to fetch all companyagreements without stopdate.
* 2020-03-16 modified by Henrik Håkanson, added restrictions for ca.STATE and p.STATUS in order to exclude unecessary data.
*/
SELECT 
    ca.center                           as companycenter, 
    ca.id                               as id, 
	p.center || 'p' || p.id				as companyId,
    p.lastname                          as company, 
    ca.subid                            as agreementid, 
    ca.name 							as agreement
FROM 
    COMPANYAGREEMENTS ca
JOIN PERSONS p 
     ON ca.CENTER = p.CENTER 
        AND ca.ID = p.ID
WHERE 
    p.SEX = 'C' 
	and ca.STATE = 1 -- Only include State = Activ
	and p.STATUS != 7 -- Exclude deleted
    and ca.STOP_NEW_DATE is null
ORDER BY 
    ca.center, 
    ca.id, 
    ca.subid
