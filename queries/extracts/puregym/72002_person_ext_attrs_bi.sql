SELECT p.personid
FROM PERSONS P_DIS 
JOIN  PERSON_EXT_ATTRS P 
on P_DIS.center = P.PERSONCENTER
and P_DIS.id = p.PERSONID 
AND p.NAME = 'DISABLED_ACCESS'
WHERE decode(nvl(txtvalue, 'false'), 'true', 1, 'false', 0) = 1
