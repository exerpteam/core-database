-- The extract is extracted from Exerp on 2026-02-08
-- Showing EFT members who has an binding enddate expires in 30 days  
SELECT DISTINCT
	cen.EXTERNAL_ID 								AS Cost,
	cen.ID 											AS CenterId,
	cen.name,
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
	p.FIRSTNAME,
	p.LASTNAME,
	p.ADDRESS1,
	p.ZIPCODE,
	p.CITY,
	pea_email.txtvalue AS Email,
	prod.name,

	TO_CHAR(trunc(months_between(TRUNC(exerpsysdate()), p.birthdate)/12)) AS Age,
    DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS subscription_STATE,
    DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUBSCRIPTION_SUB_STATE,
	DECODE (st.ST_TYPE, 0,'CASH', 1,'EFT') 			AS St_Type,
	TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') 			AS start_DATE,	
	TO_CHAR(sub.BINDING_END_DATE, 'YYYY-MM-DD') 	AS binding_END_DATE,
	TO_CHAR(sub.END_DATE, 'YYYY-MM-DD')				AS end_DATE,
	sub.BINDING_PRICE,
	sub.EXTENDED_TO_CENTER,
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
TO_CHAR(exerpsysdate(), 'YYYY-MM-DD') AS TODAYS_DATE

FROM 
	SUBSCRIPTIONS sub
LEFT JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = sub.SUBSCRIPTIONTYPE_ID

LEFT JOIN PRODUCTS prod
ON
    st.CENTER = prod.CENTER
    AND st.ID = prod.ID

LEFT JOIN PRODUCT_AND_PRODUCT_GROUP_LINK pgl
ON
 			prod.CENTER = pgl.PRODUCT_CENTER
                    AND prod.ID = pgl.PRODUCT_ID
	
LEFT JOIN PRODUCT_GROUP pg
ON
     pgl.PRODUCT_GROUP_ID = pg.ID
                           

LEFT JOIN CENTERS cen
ON
	sub.OWNER_CENTER = cen.ID
LEFT JOIN PERSONS p
ON
	sub.OWNER_CENTER = p.CENTER
	AND sub.OWNER_ID = p.ID


LEFT JOIN PERSON_EXT_ATTRS pea_email
ON
    pea_email.PERSONCENTER = p.center
AND pea_email.PERSONID = p.id
AND pea_email.NAME = '_eClub_Email'


WHERE 
	sub.CENTER IN (:ChosenScope)
	
	AND p.PERSONTYPE != 2
	AND st.st_type = 1 
	AND sub.BINDING_END_DATE BETWEEN TRUNC(exerpsysdate() +30) AND TRUNC(exerpsysdate() +30)
	AND sub.SUB_STATE NOT IN (7, 8, 9) 
	AND sub.STATE = 2
	AND sub.end_date IS Null
	AND pg.ID IN (3639, 4224, 4225, 4226, 3631, 3629, 2624, 3643, 3644, 4227, 4228, 4229)
-- 12224 Benify
	

--ProductGroups included
--3639EFTLocal 12 months
--4224EFTLocal 24 months
--4225EFTLocalMax 24 months
--4226EFTMax 24 months
--3631EFTMax 12 months
--3629EFTLocalMax 12 months
--2624WEBLocal 12 months 
--3643WEBLocalMax 12 months
--3644WEBMax 12 Months
--4227WEBLocal 24 months
--4228WEBLocalMax 24 months
--4229WEBMax 24 months




