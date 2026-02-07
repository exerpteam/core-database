SELECT
	c.owner_center || 'p' || c.owner_id AS PersonID,
	*
FROM
	clipcards c
WHERE
	c.id IN
(
'10625',
'10626',
'10627'
)
AND
	c.finished IS TRUE
AND 
	c.clips_left > 0