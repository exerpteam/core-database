SELECT 
p.center || 'p' || p.id AS personid, 
p.firstname AS firstname, 
p.lastname AS lastname, 
p.ssn AS ssn, 
TO_CHAR(p.birthdate, 'DD-MM-YYYY') AS birthdate, 
p.sex AS sex, 
p.ADDRESS1 AS AddressLine1, 
p.ADDRESS2 AS AddressLine2, 
p.zipcode AS zipcode, 
p.country AS country, 
home.txtvalue AS homephone, 
mobile.txtvalue AS mobilephone, 
email.txtvalue AS email, 
DECODE (p.PERSONTYPE, 0, 'private', 1, 'student', 2, 'private', 4, 'corporate', 7, 'senior', 'private' ) AS 
persontype, 
DECODE (p.PERSONTYPE, 0, 'PRIVATE', 1, 'STUDENT', 2, 'STAFF', 3, 'FRIEND', 4, 'CORPORATE', 5, 'ONEMANCORPORATE', 6, 
'FAMILY', 7, 'SENIOR', 8, 'GUEST', 'UNKNOWN' ) AS OldPersonType, 
CASE 
WHEN comp.center IS NOT NULL 
THEN comp.center || 'p' || comp.id 
ELSE NULL 
END AS CORPORATE_ID, 
REPLACE(comp.lastname, ';', '') AS CompanyName, 
REPLACE(cag.NAME, ';', '') AS CompanyAgreement, 
-- OTHER PAYER DETAILS 
( 
CASE 
WHEN op.center IS NOT NULL 
THEN op.center || 'p' || op.id 
ELSE NULL 
END) AS OTHERPAYERID, 
( 
CASE 
WHEN op.center IS NOT NULL 
THEN op.FIRSTNAME || ' ' || op.LASTNAME 
ELSE NULL 
END) AS OTHERPAYERNAME, 
op.ssn AS OTHERPAYERSSN 
FROM 
persons p 
LEFT JOIN 
PERSON_EXT_ATTRS home 
ON 
p.center=home.PERSONCENTER 
AND p.id=home.PERSONID 
AND home.name='_eClub_PhoneHome' 
LEFT JOIN 
PERSON_EXT_ATTRS mobile 
ON 
p.center=mobile.PERSONCENTER 
AND p.id=mobile.PERSONID 
AND mobile.name='_eClub_PhoneSMS' 
LEFT JOIN 
PERSON_EXT_ATTRS email 
ON 
p.center=email.PERSONCENTER 
AND p.id=email.PERSONID 
AND email.name='_eClub_Email' 
LEFT JOIN 
PERSON_EXT_ATTRS personcomment 
ON 
p.center=personcomment.PERSONCENTER 
AND p.id=personcomment.PERSONID 
AND personcomment.name='_eClub_Comment' 
LEFT JOIN 
RELATIVES comp_rel 
ON 
comp_rel.center=p.center 
AND comp_rel.id=p.id 
AND comp_rel.RTYPE = 3 
AND comp_rel.STATUS < 3 
LEFT JOIN 
COMPANYAGREEMENTS cag 
ON 
cag.center= comp_rel.RELATIVECENTER 
AND cag.id=comp_rel.RELATIVEID 
AND cag.subid = comp_rel.RELATIVESUBID 
LEFT JOIN 
persons comp 
ON 
comp.center = cag.center 
AND comp.id=cag.id 
LEFT JOIN 
RELATIVES op_rel 
ON 
op_rel.relativecenter=p.center 
AND op_rel.relativeid=p.id 
AND op_rel.RTYPE = 12 
AND op_rel.STATUS < 3 
LEFT JOIN 
PERSONS op 
ON 
op.center = op_rel.center 
AND op.id = op_rel.id 
-- other payer 
LEFT JOIN 
( 
SELECT DISTINCT 
rel.center AS PAYER_CENTER, 
rel.id AS PAYER_ID 
FROM 
PERSONS mem 
JOIN 
SUBSCRIPTIONS sub 
ON 
mem.center = sub.OWNER_CENTER 
AND mem.id = sub.OWNER_ID 
AND sub.STATE IN (2,4,8) 
AND ( 
sub.end_date IS NULL 
OR sub.end_date > sub.BILLED_UNTIL_DATE) 
JOIN 
SUBSCRIPTIONTYPES st 
ON 
st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER 
AND st.id = sub.SUBSCRIPTIONTYPE_ID 
JOIN 
RELATIVES rel 
ON 
rel.RELATIVECENTER = mem.center 
AND rel.RELATIVEID = mem.id 
AND rel.RTYPE = 12 
AND rel.STATUS < 3 
WHERE 
st.ST_TYPE = 1 --and mem.center = 125 and mem.persontype not in (2,8) 
) pay_for 
ON 
pay_for.payer_center = p.center 
AND pay_for.payer_id = p.id 
WHERE 
p.sex != 'C' 
AND p.center IN (708, 
709) 
AND ( 
op.center IS NOT NULL 
OR comp_rel.center IS NOT NULL ) 
