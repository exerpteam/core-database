SELECT
ca.center||'p'||ca.id as companyid,
ca.subid as agreementid, 
c.lastname as company, 
c.Address1 as Address1, 
c.address2 as Address2, 
c.zipcode, 
c.SSN,
DECODE(ca.STATE, 0, 'Under target', 1, 'Active', 2, 'Stop new', 3, 'Old', 4, 'Awaiting activation', 5, 'Blocked', 6, 'Slettet') as State, 
/*DECODE (c.PERSONTYPE, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS "Person Type",*/
mc.LASTNAME as MotherCompany,
mc.center||'p'||mc.id as MotherId 

FROM 
        COMPANYAGREEMENTS ca, 
        PERSONS c

        LEFT JOIN PERSON_EXT_ATTRS ext ON 
                 c.CENTER = ext.PERSONCENTER AND
                 c.ID = ext.PERSONID  AND
                 ext.NAME = '_eClub_Comment' 
        LEFT JOIN 
                 RELATIVES rel ON
                 rel.RELATIVECENTER = c.CENTER AND
                 rel.RELATIVEID = c.ID 
        LEFT JOIN 
                PERSONS mc ON
                mc.CENTER = rel.CENTER AND
                mc.ID = rel.ID
		/* persons under agreement
		LEFT JOIN PERSONS p ON 
				rel.CENTER = p.CENTER AND 
				rel.ID = p.ID  AND 
				rel.RTYPE = 3*/
                                                                        
 WHERE
    ca.CENTER = c.CENTER AND
    ca.ID = c.ID AND
    c.SEX = 'C' AND
   (rel.RTYPE IS NULL OR rel.RTYPE = 6) 

