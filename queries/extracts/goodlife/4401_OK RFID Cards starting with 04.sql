SELECT  
        e.ref_center || 'p' || e.ref_id as "PersonId",
        e.identity AS "MembercardId"
FROM goodlife.entityidentifiers e
WHERE e.identity LIKE '04%'
AND e.idmethod=4