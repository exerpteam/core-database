-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-9823
WITH
    params AS
    (
        SELECT
            c.name AS center,
            c.id   AS CENTER_ID,
            getstartofday((:DateFrom)::DATE::TEXT, c.id) AS fromDate,
            getendofday((:DateTo)::DATE::TEXT, c.id) AS toDate , 
            c.id,
        c.time_zone,
        c.name
        FROM 
            centers c
            where c.id in (:Scope)
    )
    ,
salaries as 
(
 SELECT DISTINCT ON
    ("PERSON_ID", "STAFF_GROUP_ID","CENTER_ID")
        "PERSON_ID",
    "STAFF_GROUP_ID",
    "CENTER_ID",
    "SALARY"
FROM
    (
        SELECT
    p.EXTERNAL_ID      AS "PERSON_ID",
    psg.staff_group_id AS "STAFF_GROUP_ID",
    CASE
        WHEN psg.scope_type = 'C' -- override on center
        THEN psg.scope_id
        ELSE
            CASE
                WHEN c.id IS NOT NULL -- override on tree
                THEN c.ID
                ELSE ac.center
            END
    END AS "CENTER_ID",
    cast(psg.salary as numeric(1000,2)) AS "SALARY" ,
    ---using levels from the recursive clause and assigning here null for center overrides to find lowest scope in next query
    CASE psg.scope_type
        WHEN 'C'
        THEN null
        else
        coalesce(Scope_Level, 0)
    END AS Override_Level 
FROM
    person_staff_groups psg
LEFT JOIN
    (
        WITH
            RECURSIVE centers_in_area AS
            (
                SELECT
                    a.id,
                    a.parent,
                    ARRAY[id] AS chain_of_command_ids,
                    1         AS level
                FROM
                    areas a
                WHERE
                    a.types LIKE '%system%'
                AND a.parent IS NULL
                UNION ALL
                SELECT
                    a.id,
                    a.parent,
                    array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids,
                    cin.level + 1                                AS level
                FROM
                    areas a
                JOIN
                    centers_in_area cin
                ON
                    cin.id = a.parent
            )
        SELECT
            cin.id                                      AS ID,
            cin.level                                   as Scope_Level,
            unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
        FROM
            centers_in_area cin
        LEFT JOIN
            centers_in_area AS b -- join provides subordinates
        ON
            cin.id = ANY (b.chain_of_command_ids)
        AND cin.level <= b.level
        GROUP BY
            cin.id,
            cin.level ) areas_total
ON
    areas_total.id = psg.scope_id
AND psg.scope_type = 'A'
LEFT JOIN
    area_centers ac
ON
    ac.area = areas_total.sub_areas
JOIN
    centers c
ON
    psg.scope_type IN ('T',
                       'G')
OR  (
        psg.scope_type = 'C'
    AND psg.scope_id = c.id)
OR  (
        psg.scope_type = 'A'
    AND ac.CENTER = c.id)
JOIN
    persons p
ON
    p.center = psg.person_center
AND p.id = psg.person_id
AND p.external_id is not null
    ) t
order by
    "PERSON_ID",
    "STAFF_GROUP_ID",
    "CENTER_ID",
    Override_Level DESC   
)        
SELECT
    b.center||'book'||b.id                                  AS Booking_ID ,
    par.participant_center||'p'||par.participant_id         AS Member_ID ,
    p.fullname                                              AS Member_Name ,
    trainer.center||'p'||trainer.id                         AS Trainer_ID ,
    trainer.fullname                                        AS Trainer_Name ,
    TO_CHAR(LONGTODATEC(b.starttime,b.center),'MM/DD/YYYY HH24:MI') AS Start_Date ,
    TO_CHAR(LONGTODATEC(b.stoptime,b.center),'MM/DD/YYYY HH24:MI')  AS End_Date ,
    b.name                                                  AS Description ,
    b.coment                                                AS Comments,
    sa."SALARY"                                             AS Salary,
    CASE WHEN par.state <> 'CANCELLED' OR misuse_state = 'PUNISHED' THEN 
       ROUND(il.total_amount / coalesce(cc.clips_initial,1),2)  
       ELSE null 
    END                                                     AS Price_Per_Clip,
    c.shortname                                             AS Location ,
    par.state                                               AS Participation_State ,
    pu.state                                                AS Privilege_Usage_State ,
    pu.misuse_state                                         AS Misuse_State 
FROM
    params
JOIN
    participations par
ON
    par.center = params.CENTER_ID
JOIN
    persons p
ON
    par.participant_center = p.center
AND par.participant_id = p.id
JOIN
    bookings b
ON
    par.booking_center = b.center
AND par.booking_id = b.id
JOIN
    activity a
ON
    b.activity = a.id
AND a.activity_group_id = 4 --Sports sessions
JOIN
    privilege_usages pu
ON
    pu.target_center = par.center
AND pu.target_id = par.id
AND pu.target_service = 'Participation'
LEFT JOIN
    clipcards cc
ON
    pu.source_center = cc.center
    AND pu.source_id = cc.id
    AND pu.source_subid = cc.subid
LEFT join
    invoice_lines_mt il
ON
   cc.invoiceline_center = il.center
   AND cc.invoiceline_id = il.id
   AND cc.invoiceline_subid = il.subid   
LEFT JOIN
    staff_usage su
ON
    b.center = su.booking_center
AND b.id = su.booking_id
AND su.state = 'ACTIVE' 
LEFT JOIN
    persons trainer
ON
    su.person_center = trainer.center
AND su.person_id = trainer.id
LEFT JOIN
    centers c
ON
    B.Center = C.ID
LEFT JOIN
    products pr
ON
    pu.source_center = pr.center
    AND pu.source_id = pr.id    
LEFT JOIN 
    activity_staff_configurations asco
ON  
    asco.activity_id = a.id        
LEFT JOIN
    salaries sa
ON
    sa."PERSON_ID" = trainer.external_id
    AND sa."CENTER_ID" = trainer.center
    AND sa."STAFF_GROUP_ID" =  asco.staff_group_id        
WHERE
    b.starttime >= params.fromdate
AND b.starttime <= params.todate
AND a.id IN (:Activity)
ORDER BY
    trainer.center,
    trainer.id,
    b.starttime ASC 