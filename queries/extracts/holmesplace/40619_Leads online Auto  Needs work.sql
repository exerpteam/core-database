
WITH
PARAMS AS
    (
        SELECT
            date_trunc('month' , par.ParamDate) AS CreatedSince
            
        FROM
            (
                SELECT
                    date_trunc('day',CURRENT_DATE - 1 -$$offset$$) AS ParamDate ) par
    )


SELECT
	c.Shortname AS "Club",
  	p.CENTER AS "Center",
	p.CENTER || 'p' || p.ID     AS "PersonId",
    p.FULLNAME                  AS "Fullname",
	email.TXTVALUE AS "Email",
	CASE p.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS "PStatus",
	cdate.TXTVALUE AS "Created",
CASE createdBy.ID 
	WHEN 2801 THEN 'OSP'
	WHEN 21013 THEN 'MWEB'
END AS "Createdby"
	
    
FROM 
    PERSONS p 

LEFT JOIN CENTERS c
ON
	c.ID = p.CENTER

LEFT JOIN
	RELATIVES r
ON
    r.CENTER = p.CENTER
    AND r.ID = p.ID
    AND r.RTYPE = 8
    AND r.STATUS < 2
LEFT JOIN
    PERSONS createdBy
ON
    r.RELATIVECENTER = createdBy.CENTER
    AND r.RELATIVEID = createdBy.ID

LEFT JOIN	
     PERSON_EXT_ATTRS cdate	
ON	
     cdate.PERSONCENTER = p.CENTER	
     AND cdate.PERSONID = p.ID 	
     AND cdate.name = 'CREATION_DATE'	

LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     p.center=email.PERSONCENTER
     AND p.id=email.PERSONID
     AND email.name='_eClub_Email'

WHERE 
    p.CENTER IN (:scope)
	AND p.STATUS IN (0,6,9)
	AND createdBy.ID IN (2801,21013)--apiteststaff and member web
	

