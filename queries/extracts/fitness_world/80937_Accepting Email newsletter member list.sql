-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT * FROM PERSON_EXT_ATTRS 
WHERE PERSONCENTER= P.CENTER 
AND PERSONID = P.ID 
AND NAME = 'eClubIsAcceptingEmailNewsLetters'
and TXTVALUE = true
and NAME = 'AllowSurvey'
and TXTVALUE = true
AND p.center IN ($$scope$$)