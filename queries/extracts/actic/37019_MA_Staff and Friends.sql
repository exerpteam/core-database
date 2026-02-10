-- The extract is extracted from Exerp on 2026-02-08
--  
Select
staff.fullname as Staff_Fullname,
friend.fullname as Friend_Fullname,
friend.center||'p'||friend.id as FriendID,
 DECODE (Friend.STATUS, 0,'Lead', 1,'Active', 2,'Inactive', 3,'Temporary inactive', 4,'Transferred', 5,'Duplicate', 6,'Prospect', 7,'Deleted', 8, 'Anonimized', 9, 'Contact', 'Unknown') AS Friend_Status



From PERSONS staff


LEFT JOIN
  RELATIVES r
ON
  r.RTYPE = 1
  AND r.RELATIVECENTER = staff.CENTER
  AND r.RELATIVEID = staff.ID

LEFT JOIN
  PERSONS friend
ON
  friend.CENTER = r.CENTER
  AND friend.ID = r.ID
  
WHERE staff.CENTER IN (:Scope) 
AND staff.PERSONTYPE =  2
AND friend.STATUS IN (1,3)
  