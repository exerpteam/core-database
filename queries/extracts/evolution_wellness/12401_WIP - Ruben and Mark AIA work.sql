WITH params AS MATERIALIZED
(
        SELECT
                datetolongC(TO_CHAR(TO_DATE(:FromDate,'YYYY-MM-DD'), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                c.id AS center_id,
                CAST((datetolongC(TO_CHAR((TO_DATE(:ToDate,'YYYY-MM-DD') + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate,
                c.name
        FROM centers c
        WHERE
                c.ID IN (:Scope)
),
attribute_changes AS
(
        SELECT
                pcl.person_center,
                pcl.person_id,
                pcl.change_attribute,
                pcl.entry_time
                ,longtodatec(pcl.entry_time, pcl.person_center) AS change_time
                ,pcl.new_value
                ,pcl.id AS pclid
        FROM evolutionwellness.person_change_logs pcl
        JOIN params par ON par.center_id = pcl.person_center
        WHERE
                pcl.change_attribute = 'AIACheckInEventNumber'
                AND pcl.entry_time between par.fromDate AND par.toDate
)

SELECT
        r1."Member Full Name"
        ,r1."Member ID"
        ,r1."External ID"
        ,r1."Home CLub"
        ,r1."Checkin club"
        ,r1."Person Type"
        ,r1."Person Status"
        ,r1."Member date joined corporate"
        ,r1."Partner PersonID"
        ,r1."Checkin Date and Time"
        ,r1."Checkout Date and Time",
        ac.person_center,
        ac.person_id,
        ac.change_attribute,
        ac.entry_time,
        ac.change_time,
        ac.new_value,
        rank() over (partition by r1."Member ID",r1."Checkin Date and Time"  ORDER BY ac.pclid) ranking,
        r1.ranking_checkin
FROM
(
        SELECT DISTINCT
                t."Member Full Name"
                ,t."Member ID"
                ,t."External ID"
                ,t."Home CLub"
                ,t."Checkin club"
                ,t."Person Type"
                ,t."Person Status"
                ,t."Member date joined corporate"
                ,t."Partner PersonID"
                ,t."Checkin Date and Time"
                ,t."Checkout Date and Time"     
                ,t.checkin_time  
                ,t.center
                ,t.id 
                ,t.ranking_checkin
        FROM
        (
                SELECT
                        s1."Member Full Name"
                        ,s1."Member ID"
                        ,s1."External ID"
                        ,s1."Home CLub"
                        ,s1."Checkin club"
                        ,s1."Person Type"
                        ,s1."Person Status"
                        ,longtodatec(MAX(s1.last_edit_time),s1.center) AS "Member date joined corporate"
                        ,s1."Partner PersonID"
                        ,s1."Checkin Date and Time"
                        ,s1."Checkout Date and Time"
                        ,s1.checkin_time
                        ,s1.center
                        ,s1.id
                        ,rank() over (partition by s1."Member ID",s1.Checkin_date  ORDER BY s1.checkin_time) ranking_checkin
                FROM
                (
                        SELECT
                                p.fullname AS "Member Full Name"
                                ,p.center||'p'||p.id AS "Member ID"
                                ,p.external_id AS "External ID"
                                ,par.name AS "Home CLub"
                                ,ckp.name AS "Checkin club"
                                ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type"
                                ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status"
                                ,aia.last_edit_time
                                ,aia.txtvalue AS "Partner PersonID"
                                ,longtodatec(ck.checkin_time,ck.checkin_center) AS "Checkin Date and Time"
                                ,longtodatec(ck.checkout_time,ck.checkin_center) AS "Checkout Date and Time"
                                ,TO_CHAR(longtodatec(ck.checkout_time,ck.checkin_center),'YYYY-MM-DD') AS Checkin_date
                                ,ck.checkin_time,
                                p.center,
                                p.id
                        FROM evolutionwellness.persons p
                        JOIN params par
                                ON p.center = par.center_id
                        JOIN evolutionwellness.person_ext_attrs aia
                                ON aia.personcenter = p.center
                                AND aia.personid = p.id
                                AND aia.name = '_eClub_PBLookupPartnerPersonId'--Internal     
                                AND aia.txtvalue IS NOT NULL       
                        JOIN evolutionwellness.checkins ck 
                                ON ck.person_center = p.center
                                AND ck.person_id = p.id  
                        JOIN evolutionwellness.centers ckp
                                ON ckp.id = ck.checkin_center                
                        WHERE
                                ck.checkin_time BETWEEN par.FromDate AND par.ToDate
                        UNION ALL
                        SELECT
                                p.fullname AS "Member Full Name"
                                ,p.center||'p'||p.id AS "Member ID"
                                ,p.external_id AS "External ID"
                                ,par.name AS "Home CLub"
                                ,ckp.name AS "Checkin club"
                                ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type"
                                ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status"
                                ,aia.last_edit_time
                                ,aia.txtvalue AS "Partner PersonID"
                                ,longtodatec(ck.checkin_time,ck.checkin_center) AS "Checkin Date and Time"
                                ,longtodatec(ck.checkout_time,ck.checkin_center) AS "Checkout Date and Time"
                                ,TO_CHAR(longtodatec(ck.checkout_time,ck.checkin_center),'YYYY-MM-DD') AS Checkin_date
                                ,ck.checkin_time,
                                p.center,
                                p.id
                        FROM evolutionwellness.persons p
                        JOIN params par
                                ON p.center = par.center_id
                        JOIN evolutionwellness.person_ext_attrs aia
                                ON aia.personcenter = p.center
                                AND aia.personid = p.id
                                AND aia.name = 'VitalityCheckin' --Singapore      
                                AND aia.txtvalue IS NOT NULL          
                        JOIN evolutionwellness.checkins ck 
                                ON ck.person_center = p.center
                                AND ck.person_id = p.id  
                        JOIN evolutionwellness.centers ckp
                                ON ckp.id = ck.checkin_center                   
                        WHERE
                                ck.checkin_time BETWEEN par.FromDate AND par.ToDate 
                        UNION ALL
                        SELECT
                                p.fullname AS "Member Full Name"
                                ,p.center||'p'||p.id AS "Member ID"
                                ,p.external_id AS "External ID"
                                ,par.name AS "Home CLub"
                                ,ckp.name AS "Checkin club"
                                ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type"
                                ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status"
                                ,aia.last_edit_time
                                ,aia.txtvalue AS "Partner PersonID"
                                ,longtodatec(ck.checkin_time,ck.checkin_center) AS "Checkin Date and Time"
                                ,longtodatec(ck.checkout_time,ck.checkin_center) AS "Checkout Date and Time"
                                ,TO_CHAR(longtodatec(ck.checkout_time,ck.checkin_center),'YYYY-MM-DD') AS Checkin_date
                                ,ck.checkin_time,
                                p.center,
                                p.id
                        FROM evolutionwellness.persons p
                        JOIN params par
                                ON p.center = par.center_id
                        JOIN evolutionwellness.person_ext_attrs aia
                                ON aia.personcenter = p.center
                                AND aia.personid = p.id
                                AND aia.name = 'VitalityCheckinID' --Indonesia      
                                AND aia.txtvalue IS NOT NULL          
                        JOIN evolutionwellness.checkins ck 
                                ON ck.person_center = p.center
                                AND ck.person_id = p.id  
                        JOIN evolutionwellness.centers ckp
                                ON ckp.id = ck.checkin_center                  
                        WHERE
                                ck.checkin_time BETWEEN par.FromDate AND par.ToDate  
                        UNION ALL
                        SELECT
                                p.fullname AS "Member Full Name"
                                ,p.center||'p'||p.id AS "Member ID"
                                ,p.external_id AS "External ID"
                                ,par.name AS "Home CLub"
                                ,ckp.name AS "Checkin club"
                                ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type"
                                ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status"
                                ,aia.last_edit_time
                                ,aia.txtvalue AS "Partner PersonID"
                                ,longtodatec(ck.checkin_time,ck.checkin_center) AS "Checkin Date and Time"
                                ,longtodatec(ck.checkout_time,ck.checkin_center) AS "Checkout Date and Time"
                                ,TO_CHAR(longtodatec(ck.checkout_time,ck.checkin_center),'YYYY-MM-DD') AS Checkin_date
                                ,ck.checkin_time,
                                p.center,
                                p.id
                        FROM evolutionwellness.persons p
                        JOIN params par
                                ON p.center = par.center_id
                        JOIN evolutionwellness.person_ext_attrs aia
                                ON aia.personcenter = p.center
                                AND aia.personid = p.id
                                AND aia.name = 'VitalityCheckinMY' --Malaysia       
                                AND aia.txtvalue IS NOT NULL         
                        JOIN evolutionwellness.checkins ck 
                                ON ck.person_center = p.center
                                AND ck.person_id = p.id  
                        JOIN evolutionwellness.centers ckp
                                ON ckp.id = ck.checkin_center                  
                        WHERE
                                ck.checkin_time BETWEEN par.FromDate AND par.ToDate 
                                UNION ALL
                        SELECT
                                p.fullname AS "Member Full Name"
                                ,p.center||'p'||p.id AS "Member ID"
                                ,p.external_id AS "External ID"
                                ,par.name AS "Home CLub"
                                ,ckp.name AS "Checkin club"
                                ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type"
                                ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status"
                                ,aia.last_edit_time
                                ,aia.txtvalue AS "Partner PersonID"
                                ,longtodatec(ck.checkin_time,ck.checkin_center) AS "Checkin Date and Time"
                                ,longtodatec(ck.checkout_time,ck.checkin_center) AS "Checkout Date and Time"
                                ,TO_CHAR(longtodatec(ck.checkout_time,ck.checkin_center),'YYYY-MM-DD') AS Checkin_date
                                ,ck.checkin_time,
                                p.center,
                                p.id
                        FROM evolutionwellness.persons p
                        JOIN params par
                                ON p.center = par.center_id
                        JOIN evolutionwellness.person_ext_attrs aia
                                ON aia.personcenter = p.center
                                AND aia.personid = p.id
                                AND aia.name = 'VitalityCheckinID' --Indonesia      
                                AND aia.txtvalue IS NOT NULL          
                        JOIN evolutionwellness.checkins ck 
                                ON ck.person_center = p.center
                                AND ck.person_id = p.id  
                        JOIN evolutionwellness.centers ckp
                                ON ckp.id = ck.checkin_center                  
                        WHERE
                                ck.checkin_time BETWEEN par.FromDate AND par.ToDate  
                        UNION ALL
                        SELECT
                                p.fullname AS "Member Full Name"
                                ,p.center||'p'||p.id AS "Member ID"
                                ,p.external_id AS "External ID"
                                ,par.name AS "Home CLub"
                                ,ckp.name AS "Checkin club"
                                ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type"
                                ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status"
                                ,aia.last_edit_time
                                ,aia.txtvalue AS "Partner PersonID"
                                ,longtodatec(ck.checkin_time,ck.checkin_center) AS "Checkin Date and Time"
                                ,longtodatec(ck.checkout_time,ck.checkin_center) AS "Checkout Date and Time"
                                ,TO_CHAR(longtodatec(ck.checkout_time,ck.checkin_center),'YYYY-MM-DD') AS Checkin_date
                                ,ck.checkin_time,
                                p.center,
                                p.id
                        FROM evolutionwellness.persons p
                        JOIN params par
                                ON p.center = par.center_id
                        JOIN evolutionwellness.person_ext_attrs aia
                                ON aia.personcenter = p.center
                                AND aia.personid = p.id
                                AND aia.name = 'VitalityCheckinTH' --Thailand      
                                AND aia.txtvalue IS NOT NULL         
                        JOIN evolutionwellness.checkins ck 
                                ON ck.person_center = p.center
                                AND ck.person_id = p.id  
                        JOIN evolutionwellness.centers ckp
                                ON ckp.id = ck.checkin_center                  
                        WHERE
                                ck.checkin_time BETWEEN par.FromDate AND par.ToDate 
                ) s1
                GROUP BY
                        s1."Member Full Name"
                        ,s1."Member ID"
                        ,s1."External ID"
                        ,s1."Home CLub"
                        ,s1."Checkin club"
                        ,s1."Person Type"
                        ,s1."Person Status"
                        ,s1."Partner PersonID"
                        ,s1."Checkin Date and Time"
                        ,s1."Checkout Date and Time"
                        ,s1.checkin_time
                        ,s1.center
                        ,s1.id
                        ,s1.Checkin_date
                        
         ) t
) r1
LEFT JOIN attribute_changes ac
        ON ac.person_center = r1.center AND ac.person_id = r1.id AND ac.entry_time between (r1.checkin_time - (15*60*1000)) AND (r1.checkin_time + (15*60*1000))
WHERE
        r1.ranking_checkin = 1