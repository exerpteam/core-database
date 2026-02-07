SELECT DISTINCT
    p.CURRENT_PERSON_CENTER || 'p' || p.CURRENT_PERSON_ID  AS old_remote_user_id,
    p.EXTERNAL_ID                                          AS new_remote_user_id,
	DECODE(pea.TXTVALUE,'true',1,0)                        AS SMSMARKETING
FROM
    PERSONS p
LEFT JOIN
    PERSON_EXT_ATTRS pea
ON
    p.CENTER = pea.PERSONCENTER
    AND p.ID = pea.PERSONID
    AND pea.NAME = 'SMSMARKETING'
WHERE 
    p.EXTERNAL_ID is not null 

