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
SELECT
        p.center,
		p.id
		,p.fullname AS "Member Full Name"
        ,p.center||'p'||p.id AS "Member ID"
        ,p.external_id AS "External ID"
        ,c.name AS "Home CLub"
        ,ckp.name AS "Checkin club"
        ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type"
        ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status"
        ,longtodatec(aia.last_edit_time,aia.personcenter) AS "Member date joined corporate"
        ,aia.txtvalue AS "Partner PersonID"
        ,TO_CHAR(longtodatec(ck.checkin_time,ck.checkin_center), 'YYYY-MM-dd') AS "Checkin Date"
		,TO_CHAR(longtodatetz(ck.CHECKIN_TIME, c.time_zone),'HH24:MI:SS') AS "Check-In Time"
FROM
        evolutionwellness.persons p
JOIN
        evolutionwellness.person_ext_attrs aia
        ON aia.personcenter = p.center
        AND aia.personid = p.id
        AND aia.name = '_eClub_PBLookupPartnerPersonId'     
        AND aia.txtvalue IS NOT NULL
JOIN
        evolutionwellness.centers c
        ON c.id = p.center            
JOIN 
        evolutionwellness.checkins ck 
        ON ck.person_center = p.center
        AND ck.person_id = p.id  
JOIN
        evolutionwellness.centers ckp
        ON ckp.id = ck.checkin_center 
JOIN
        params
        ON params.center_id = p.center                  
WHERE
        p.center IN (:Scope)
        AND
        ck.checkin_time BETWEEN params.FromDate AND params.ToDate