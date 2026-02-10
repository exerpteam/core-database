-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.FIRSTNAME,
    p.LASTNAME,
    p.CENTER || 'p' || p.ID                                         AS Pref,
    p.BIRTHDATE                                                     AS Birthdate,
    CAST (EXTRACT(YEAR FROM AGE(now(), CAST(p.birthdate AS TIMESTAMP))) AS INT)    AS Age,	
    CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL STAFF'
        ELSE 'UNKNOWN'
    END AS PERSONTYPE,
	p.sex															AS Gender,
    e.IDENTITY                                                      AS Pin,
    cen.NAME                                                        AS HomeClub,
    cen2.NAME                                                       AS VisitClub,
    br.NAME                                                         AS AccessPoint,
    TO_CHAR(longtodatec(att.START_TIME,att.PERSON_CENTER),'dd-MM-YYYY') AS "Visit date",
    TO_CHAR(longtodatec(att.START_TIME,att.PERSON_CENTER),'HH24:MI:SS') AS "Time"
FROM
    PERSONS p
JOIN
    ATTENDS att
ON
    p.CENTER = att.PERSON_CENTER
    AND p.ID = att.PERSON_ID
JOIN
    BOOKING_RESOURCES br
ON
    br.CENTER = att.BOOKING_RESOURCE_CENTER
    AND br.ID = att.BOOKING_RESOURCE_ID
JOIN
    CENTERS cen
ON
    cen.ID = p.CENTER
JOIN
    CENTERS cen2
ON
    cen2.ID = att.BOOKING_RESOURCE_CENTER
LEFT JOIN
    ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER=p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
WHERE
    att.CENTER IN ($$Scope$$)
    AND att.START_TIME BETWEEN $$StartDate$$ AND $$EndDate$$