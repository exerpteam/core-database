-- The extract is extracted from Exerp on 2026-02-08
-- Find members with persontype Family and list information about membership and relationship.
SELECT 
	child.CENTER||'p'||child.ID,
	child.FULLNAME,
	child.STATUS,
	parent.CENTER||'p'||parent.ID,
	parent.FULLNAME,
	re.relativesubid,
	re.rtype,
	re.status,
	child.PERSONTYPE

FROM PERSONS child
JOIN RELATIVES re
	ON re.CENTER = child.CENTER
	AND re.ID = child.ID
JOIN PERSONS parent
	ON re.RELATIVECENTER = parent.CENTER
	AND re.RELATIVEID = parent.ID
WHERE 
	child.CENTER IN(:center)
	AND child.PERSONTYPE = 6
	AND re.RTYPE != 8
	AND child.STATUS NOT IN (4,5,7,8)
	AND parent.STATUS NOT IN (4,5,7,8)	
ORDER by parent.FULLNAME