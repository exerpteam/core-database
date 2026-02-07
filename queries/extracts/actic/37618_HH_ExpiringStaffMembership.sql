SELECT
	DISTINCT p.center as center , p.id as id,
    sub.OWNER_CENTER || 'p' || sub.OWNER_ID AS PersonKey,
	p.FULLNAME AS Name,
	email.txtvalue AS Email,
	sub.END_DATE AS ExpirationDate,
	sub.STATE AS State,
	sub.SUB_STATE AS SubState
FROM
    SUBSCRIPTIONS sub
LEFT JOIN
    PERSONS p
ON
	p.CENTER = sub.OWNER_CENTER
    AND p.ID = sub.OWNER_ID
LEFT JOIN
  PERSON_EXT_ATTRS email
ON
  email.PERSONCENTER = p.CENTER
  AND email.PERSONID = p.ID
  AND email.NAME = '_eClub_Email'
WHERE
    sub.OWNER_CENTER IN (:center)
	AND p.PERSONTYPE = 2
	AND sub.STATE = 2
	AND sub.SUB_STATE !=5
  	AND (
			sub.END_DATE = TRUNC(exerpsysdate()+10)
			OR
			sub.END_DATE = TRUNC(exerpsysdate()+30)
		)
	/*AND (
			(p.CENTER = 45 AND p.ID = 47695)
			OR
			(p.CENTER = 45 AND p.ID = 2067)
		)*/