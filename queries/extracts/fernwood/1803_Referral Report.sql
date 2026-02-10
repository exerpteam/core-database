-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-2421
https://clublead.atlassian.net/browse/EC-4665
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
  ),
  referrer AS
  (
        SELECT
                s.center
                ,s.id
                ,s.owner_center
                ,s.owner_id
                ,CASE
                        WHEN st.st_type = 0 THEN 'Cash' 
                        ELSE 'EFT'
                END AS st_type 
                ,prod.name AS sub_name
        FROM
                subscriptions s
        JOIN
                subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id
        JOIN
                products prod
                ON prod.center = st.center
                AND prod.id = st.id                                
        WHERE 
                s.state IN (1,2,4,7,8) 
                AND
                st.st_type IN (0,1)
        UNION ALL
        SELECT
                s.center
                ,s.id
                ,s.owner_center
                ,s.owner_id
                ,'Clipcard' AS st_type
                ,prod.name AS sub_name
        FROM
                subscriptions s
        JOIN
                subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id 
        JOIN
                products prod
                ON prod.center = st.center
                AND prod.id = st.id               
        WHERE 
                s.state IN (1,2,4,7,8) 
                AND
                st.st_type = 2    
                AND s.owner_center||'p'||s.owner_id NOT IN 
                                                        (SELECT
                                                                s.owner_center||'p'||s.owner_id
                                                        FROM
                                                                subscriptions s
                                                        JOIN
                                                                subscriptiontypes st
                                                                ON st.center = s.subscriptiontype_center
                                                                AND st.id = s.subscriptiontype_id                
                                                        WHERE 
                                                                s.state IN (1,2,4,7,8) 
                                                                AND
                                                                st.st_type IN (0,1)
                                                        )                                                                                          
 ),
 subscription AS
 (
        SELECT
                s.creation_time
                ,s.owner_center
                ,s.owner_id
                ,prod.name
        FROM
                subscriptions s
        JOIN
                subscriptiontypes st
                ON s.subscriptiontype_center = st.center
                AND s.subscriptiontype_id = st.id
        JOIN
                products prod
                ON prod.center = st.center
                AND prod.id = st.id
 )                       
SELECT 
        p.center ||'p'||p.id AS "Referred PersonID"
        ,p.fullname AS "Referred Name"
        ,pe.center ||'p'||pe.id AS "Referee PersonID"
        ,pe.fullname AS "Referee Name"
        ,longtodatec(scl.entry_start_time,scl.center) AS "Referral Date"
        ,empp.center ||'p'||empp.id AS "Employee PersonID"
        ,empp.fullname AS "Employee Name"
        ,subscription.name AS "Membership Sold" 
        ,longtodatec(subscription.creation_time,subscription.owner_center) AS "Subscription created date"
        ,referrer.center||'ss'||referrer.id AS "Subscription ID of referrer"
        ,referrer.sub_name AS "Subscription Name of referrer"
FROM relatives re
JOIN persons p 
        ON p.center = re.center 
        AND p.id = re.id
JOIN persons pe 
        ON pe.center = re.relativecenter 
        AND pe.id = re.relativeid
JOIN state_change_log scl 
        ON scl.center = re.center 
        AND scl.id = re.id 
        AND scl.subid = re.subid 
        AND scl.entry_type = 4 
        AND scl.entry_end_time IS NULL
JOIN employees emp 
        ON emp.center = scl.employee_center 
        AND emp.id = scl.employee_id
JOIN persons empp 
        ON empp.center = emp.personcenter 
        AND empp.id = emp.personid
JOIN params 
        ON params.CENTER_ID = scl.center
LEFT JOIN
        subscription
        ON subscription.owner_center = p.center
        AND subscription.owner_id = p.id
        AND subscription.creation_time >= scl.entry_start_time 
LEFT JOIN
        referrer 
        ON referrer.owner_center = re.relativecenter
        AND referrer.owner_id = re.relativeid     
WHERE 
        rtype = 13
        AND
        re.status = 1
        AND 
        p.center in (:Scope)
        AND 
        scl.entry_start_time BETWEEN params.FromDate AND params.ToDate