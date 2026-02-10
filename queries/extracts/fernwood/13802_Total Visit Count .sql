-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-1247
WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )  
SELECT
        p.center AS "Member Home Club ID"
        ,p.external_id AS "External ID"
        ,p.firstname AS "First Name"
        ,p.lastname AS "Last name"
        ,Mobile.txtvalue AS "Mobile Number"
        ,Email.txtvalue AS "Email Address"
        ,CASE
                WHEN p.status = 1 THEN 'Active' 
				WHEN p.status = 2 THEN 'Inactive' 
				WHEN p.status = 3 THEN 'Temporary Inactive'
                ELSE ''
         END AS "Person Status"       
        ,count(*) AS "Total Number of visits"
FROM 
        persons p 

JOIN
        (
        SELECT DISTINCT
                s.owner_center
                ,s.owner_id
        FROM
                subscriptions s
        JOIN
                subscriptiontypes st
                        ON s.subscriptiontype_center = st.center
                        AND s.subscriptiontype_id = st.id
        JOIN
                PRODUCTS pd
                        ON st.center=pd.center
                        AND st.id=pd.id
        JOIN
                product_and_product_group_link pgp
                        ON pgp.product_center = pd.center
                        AND pgp.product_id = pd.id
                        AND pgp.product_group_id = 4602
        )t1                        
        ON t1.owner_center = p.center
        AND t1.owner_id = p.id        
JOIN
        checkins CK
        ON p.center = ck.person_center
        AND p.id = ck.person_id
JOIN    
        params
        ON params.CENTER_ID = ck.checkin_center  
LEFT JOIN
        person_ext_attrs Email
               on Email.personcenter = p.center
               and Email.personid = p.id
               and Email.name = '_eClub_Email'
LEFT JOIN
        person_ext_attrs Mobile
               on Mobile.personcenter = p.center
               and Mobile.personid = p.id
               and Mobile.name = '_eClub_PhoneSMS'
WHERE
        ck.checkin_time BETWEEN params.FromDate AND params.ToDate            
        AND
        p.status in (1,3,2)
        AND
        p.center in (:Scope)
        AND
        p.persontype != 6
GROUP BY
        p.center
        ,p.external_id
        ,p.firstname
        ,p.lastname
        ,Mobile.txtvalue
        ,Email.txtvalue
        ,p.status