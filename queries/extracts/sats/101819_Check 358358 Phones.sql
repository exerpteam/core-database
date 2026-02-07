select      
      *,      
      length(new_home) as len_new_home,
      length(new_mobile) as len_new_mobile,
      length(new_work) as len_new_work  
   from (          
select 
   p.center||'p'||p.id as member_key,
   pea_home.txtvalue as current_home,
   replace(pea_home.txtvalue, '+358358', '+358') as new_home,
   pea_mobile.txtvalue as current_mobile,
   replace(pea_mobile.txtvalue, '+358358', '+358') as new_mobile,
   pea_work.txtvalue as current_work,
   replace(pea_work.txtvalue, '+358358', '+358') as new_work
   
   --CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE

   
   from persons p
   
   join person_ext_attrs 
   pea_home on p.center = 
   pea_home.personcenter and 
   pea_home.personid = p.id and
   pea_home.name = '_eClub_PhoneHome'
   
   join person_ext_attrs 
   pea_mobile on p.center = 
   pea_mobile.personcenter and 
   pea_mobile.personid = p.id and
   pea_mobile.name = '_eClub_PhoneSMS'
   
   join person_ext_attrs 
   pea_work on p.center = 
   pea_work.personcenter and 
   pea_work.personid = p.id and
   pea_work.name = '_eClub_PhoneWork'
   
   where (
   pea_home.txtvalue like '+358358%' or
   pea_mobile.txtvalue like '+358358%' or
   pea_work.txtvalue like '+358358%')
   and p.sex != 'C'
   and p.status not in (4,5,7,8) --- 4 TRANSFERRED. 5 DUPLICATE. 7 DELETED. 8 ANONYMIZED

)t1