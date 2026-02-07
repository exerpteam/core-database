select
r1."PersonKey", r1."Email Address", 
CASE   WHEN PERSONTYPE = 0 THEN 'PRIVATE' WHEN PERSONTYPE = 1 THEN 'STUDENT' WHEN PERSONTYPE = 2 THEN 'STAFF' WHEN PERSONTYPE = 3 THEN 'FRIEND' WHEN PERSONTYPE = 4 THEN 'CORPORATE' WHEN PERSONTYPE = 5 THEN 'ONEMANCORPORATE' WHEN PERSONTYPE = 6 THEN 'FAMILY' WHEN PERSONTYPE = 7 THEN 'SENIOR' WHEN PERSONTYPE = 8 THEN 'GUEST' WHEN PERSONTYPE = 9 THEN 'CHILD' WHEN PERSONTYPE = 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS  "Person Type",
CASE per.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS  "Person Status",
per.NATIONAL_ID "National ID",
 per.RESIDENT_ID "Resident ID",
 (select p1.txtvalue from person_ext_attrs p1 where p1.name = '_eClub_PassportNumber' and p1.personcenter = per.center and p1.personid=per.id  ) "Passport Number",
(select p2.txtvalue from person_ext_attrs p2 where p2.name = '_eClub_PhoneSMS' and p2.personcenter = per.center and p2.personid=per.id ) "Mobile No",  ((select je.creatorcenter||'emp'||je.creatorid from journalentries je where je.person_Center = per.center and je.person_id=per.id and je.jetype=3 and trim(upper(je.name)) in (trim(upper('Person created')),trim(upper('Company created')))))"Person Created By",
sub.center||'ss'||sub.id "Subscription Key" ,    
sub.start_date "Subscription Start Date",
sub.end_date "Subscription End Date",
(select cen.name from centers cen where cen.id = sub.center) "Subscription center Name",
CASE sub.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS "Subscription State"

 from (SELECT
                    p.personcenter||'p'||p.personid "PersonKey" ,
                    p.txtvalue "Email Address"
                FROM
                    person_ext_attrs p 

                WHERE
                   p.name in ( '_eClub_Email') AND TRIM(UPPER(p.txtvalue)) IN (SELECT TRIM(UPPER(pea.txtvalue)) FROM  person_ext_attrs pea  WHERE pea.name in ( '_eClub_Email') GROUP BY pea.name,TRIM(UPPER(pea.txtvalue)) HAVING   COUNT(*) >1   )
 )r1 join subscriptions sub on sub.owner_center||'p'||sub.owner_id = r1."PersonKey" and sub.state in (2,4,8) join persons per on per.center||'p'||per.id =  r1."PersonKey" 
order by r1."Email Address"