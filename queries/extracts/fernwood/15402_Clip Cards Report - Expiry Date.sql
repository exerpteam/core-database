WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate         
      FROM
          centers c
  )
SELECT distinct
        p.center ||'p'||p.id AS "PersonID"
        ,p.external_id AS "ExternalID"
        ,c.shortname AS "Club Name"
        ,p.firstname AS "First Name"
        ,p.lastname AS "Last Name"
        ,CASE
                p.persontype
                WHEN 0 THEN 'Private'
                WHEN 1 THEN 'Student'
                WHEN 2 THEN 'Staff'
                WHEN 3 THEN 'Friend'
                WHEN 4 THEN 'Corporate'
                WHEN 5 THEN 'One Man Corporate'
                WHEN 6 THEN 'Family'
                WHEN 7 THEN 'Senior'
                WHEN 8 THEN 'Guest'
                WHEN 9 THEN 'Child'
                WHEN 10 THEN 'External Staff' 
        END AS "Person type" 
        ,pro.name AS "Clip Card Name"
        ,longtodatec(cc.valid_from,cc.center) AS "Start Date"
        ,longtodatec(cc.valid_until,cc.center) AS "End Date"
        ,cc.clips_initial AS "Original Clips"
        ,cc.clips_left AS "Remaining Clips"
        ,CASE
                WHEN cc.cancelled = 'true' AND cc.finished = 'true' THEN 'Cancelled'
                WHEN cc.blocked = 'true' AND cc.finished = 'true' THEN 'Blocked'
                WHEN cc.finished = 'true' AND cc.cancelled = 'false' AND cc.blocked = 'false' THEN 'Finished'
                ELSE 'Active'
         END AS "State"
,cc.center||'cc'||cc.id||'cc'||cc.subid
FROM 
        fernwood.persons p
JOIN 
        fernwood.clipcards cc 
        ON cc.owner_center = p.center 
        AND cc.owner_id = p.id
JOIN 
        fernwood.centers c 
        ON c.id = p.center
JOIN 
        fernwood.products pro 
        ON pro.center = cc.center
        AND pro.id = cc.ID
JOIN 
        params 
        ON params.CENTER_ID = c.id              
WHERE 
        cc.valid_until BETWEEN params.FromDate AND params.ToDate
        AND 
        p.CENTER IN (:Scope)