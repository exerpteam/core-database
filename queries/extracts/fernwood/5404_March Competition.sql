WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST('2020-03-01' AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST('2020-03-31' AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )

SELECT 
        p.center||'p'||p.id AS "PersonID"
		,peaOLDID.txtvalue AS "Person Old System ID"
        ,p.fullname AS "Member Full Name"
        ,c.shortname AS "Member Home Club"
        ,s.start_date AS "Subscription Start Date"
        ,prod.name AS "Subscription Name"
        ,peaEmail.txtvalue AS "Person Email"
        ,peaMobile.txtvalue AS "Person Mobile"
        ,peaHome.txtvalue AS "Person Home"
        ,pe.center||'p'||p.id AS "Referred By Person ID"
		,peeaOLDID.txtvalue AS "Referred By Old System ID"
        ,pe.fullname AS "Referred By Full Name"
        ,ce.shortname AS "Referred By Home Club"
        ,peeaEmail.txtvalue AS "Referred By Person Email"
        ,peeaMobile.txtvalue AS "Referred By Person Mobile"
        ,peeaHome.txtvalue AS "Referred By Person Home"        
FROM 
        fernwood.subscriptions s
JOIN 
        params 
        ON params.CENTER_ID = s.center  
JOIN
        fernwood.subscriptiontypes st
        ON st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
JOIN
        fernwood.products prod
        ON prod.center = st.center
        AND prod.id = st.id
        AND prod.globalid in ('12_MONTH_FIXED_TERM_MEMBERSHIP','12_MONTH_ONGOING_MEMBERSHIP','12_MONTH_PIF_MEMBERSHIP','18_MONTH_FIXED_TERM_MEMBERSHIP','18_MONTH_ONGOING_MEMBERSHIP_1','18_MONTH_ONGOING_MEMBERSHIP')  
JOIN 
        fernwood.persons p
        ON p.center = s.owner_center
        AND p.id = s.owner_id
JOIN 
        fernwood.centers c
        ON c.id = p.center          
LEFT JOIN 
        fernwood.relatives re
        ON p.center = re.center AND p.id = re.id
        AND rtype = 13
LEFT JOIN 
        fernwood.persons pe 
        ON pe.center = re.relativecenter 
        AND pe.id = re.relativeid
LEFT JOIN
        fernwood.centers ce
        ON ce.id = pe.center          
LEFT JOIN 
        fernwood.person_ext_attrs peaEmail
        ON peaEmail.personcenter = p.center
        AND peaEmail.personid = p.id
        AND peaEmail.name = '_eClub_Email'
LEFT JOIN 
         fernwood.person_ext_attrs peaMobile
        ON peaMobile.personcenter = p.center
        AND peaMobile.personid = p.id
        AND peaMobile.name = '_eClub_PhoneSMS' 
LEFT JOIN 
         fernwood.person_ext_attrs peaHome
        ON peaHome.personcenter = p.center
        AND peaHome.personid = p.id
        AND peaHome.name = '_eClub_PhoneHome'  
LEFT JOIN
        fernwood.person_ext_attrs peaOLDID
        ON peaOLDID.personcenter = p.center
        AND peaOLDID.personid = p.id 
        AND peaOLDID.name = '_eClub_OldSystemPersonId' 
LEFT JOIN 
        fernwood.person_ext_attrs peeaEmail
        ON peeaEmail.personcenter = pe.center
        AND peeaEmail.personid = pe.id
        AND peeaEmail.name = '_eClub_Email'
LEFT JOIN 
         fernwood.person_ext_attrs peeaMobile
        ON peeaMobile.personcenter = pe.center
        AND peeaMobile.personid = pe.id
        AND peeaMobile.name = '_eClub_PhoneSMS' 
LEFT JOIN 
         fernwood.person_ext_attrs peeaHome
        ON peeaHome.personcenter = pe.center
        AND peeaHome.personid = pe.id
        AND peeaHome.name = '_eClub_PhoneHome' 
LEFT JOIN
        fernwood.person_ext_attrs peeaOLDID
        ON peeaOLDID.personcenter = pe.center
        AND peeaOLDID.personid = pe.id 
        AND peeaOLDID.name = '_eClub_OldSystemPersonId'                                                                
WHERE
        s.state in (2,4,8)
        AND 
        s.creation_time BETWEEN params.FromDate AND params.ToDate 
        AND 
        s.start_date >= '2020-03-01'
        AND 
        p.persontype <> 2

        