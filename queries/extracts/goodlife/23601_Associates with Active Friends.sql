-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 	friend.external_id AS FriendExternal,
		friend.fullname AS Friend,
		associate.external_id AS AssociateExternal,
		associate.fullname AS Associate
FROM
	PERSONS associate
JOIN
	RELATIVES r	
ON
	r.relativecenter = associate.center
AND
 	r.relativeid = associate.id
AND
	r.rtype = 1
AND
	r.status = 1
JOIN
	PERSONS friend
ON
	r.center = friend.center
AND 
	r.id = friend.id

WHERE
	associate.external_id IN ($$AssociateExternal$$)