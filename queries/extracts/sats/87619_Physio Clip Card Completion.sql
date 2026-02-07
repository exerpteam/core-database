WITH
    params AS
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE(:FROM_DATE, 'YYYY-MM-dd'),'YYYY-MM-dd')) AS bigint) AS from_date,
            CAST(datetolong(TO_CHAR(TO_DATE(:TO_DATE, 'YYYY-MM-dd'),'YYYY-MM-dd')) AS bigint)+1000*60*60*24 AS to_date,
            c.id AS centerid
        FROM centers c 
        WHERE c.id IN (:scope)
    )
        
    SELECT
        "Center ID",
        "Center Name",
        "Member ID",
        "Member name",
        "Clip card name",
        "Date of completion",
        "Name of the person that completed the clip"
    FROM (

SELECT 
cc.center                                                            AS "Center ID",
c.shortname                                                               AS "Center Name",
op.center||'p'||op.id                                                AS "Member ID",
op.fullname                                                          AS "Member name",
pr.name                                                              AS "Clip card name",
TO_CHAR (longtodateTZ (ccu.time, c.time_zone), 'DD-MM-YYYY HH24:MI') AS "Date of completion",
ep.fullname --- ||' ('||emp.center||'emp'||emp.id||')'                                                          
AS "Name of the person that completed the clip",
row_number() over (partition by ccu.card_center, ccu.card_id, ccu.card_subid order by time desc) r 

FROM CLIPCARDS cc 
JOIN params par ON par.centerid = cc.center 
JOIN products pr ON pr.center = cc.center AND pr.id = cc.id 
JOIN centers c ON cc. center = c.id 
JOIN persons op ON cc.owner_center = op.center AND cc.owner_id = op.id 
JOIN card_clip_usages ccu ON cc.center = ccu.card_center AND cc.id = ccu.card_id AND cc.subid = ccu.card_subid
JOIN employees emp ON ccu.employee_center = emp.center AND ccu.employee_id = emp.id 
JOIN persons ep ON emp.personcenter = ep.center AND emp.personid = ep.id

WHERE pr.globalid = 'PHYSIO_INCLUDED_CLIP_CARD'
AND ccu.time BETWEEN par.from_date AND par.to_date
        
        ) t1
        WHERE r = 1 ---get latest clip card usage