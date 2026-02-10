-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
      SELECT
          datetolongC(TO_CHAR(CAST('2025-04-01' AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST('2025-04-30' AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c  
)
SELECT DISTINCT 
        t1.center||'p'||t1.id AS PersonID
        ,t1.external_id
        ,t1.fullname
        ,t1."LegacyID"
        ,t1.PERSONTYPE
        ,t1.PERSON_STATUS
        ,t1."Club ID"
        ,t1."Club"
        ,t1."Subscription Name"
        ,t1.start_date
        ,t1.end_date
        ,t1.SUBSCRIPTION_STATE
        ,t1.SUBSCRIPTION_SUB_STATE
        ,t1."Created By"
       -- ,longtodatec(s.creation_time,s.center) AS creationdate
       -- longtodatec(s.creation_time,s.center),
       -- longtodatec(str.creation_time,str.center),
        ,longtodatec(t1.Creation_time,t1.center) AS creation_date
        ,t1."Payment Agreement state"
       -- ,t1.status
FROM
(SELECT
        p.center
        ,p.id
        ,p.external_id
        ,p.fullname
        ,pea.txtvalue AS "LegacyID"
        ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE
        ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS
        ,c.id AS "Club ID"
        ,c.name AS "Club"
        ,pr.name AS "Subscription Name"
        ,s.start_date
        ,s.end_date
        ,CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE
        ,CASE s.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUBSCRIPTION_SUB_STATE
        ,s.creator_center||'emp'||s.creator_id AS "Created By"
       -- ,longtodatec(s.creation_time,s.center) AS creationdate
       -- longtodatec(s.creation_time,s.center),
       -- longtodatec(str.creation_time,str.center),
        ,CASE
                WHEN str.creation_time IS NULL THEN s.creation_time
                ELSE str.creation_time
        END AS Creation_time
        ,CASE
                WHEN st.st_type  = 0 then NULL
                ELSE
                        CASE pa.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing'
                        END
        END AS "Payment Agreement state"                        
        ,pa.state as status

FROM
        evolutionwellness.persons p
JOIN 
        params par 
        ON p.center = par.CENTER_ID
LEFT JOIN 
        evolutionwellness.person_ext_attrs pea
        ON p.center = pea.personcenter 
        AND p.id = pea.personid 
        AND pea.name = '_eClub_OldSystemPersonId' 
        AND pea.txtvalue IS NOT NULL
JOIN 
        evolutionwellness.subscriptions s 
        ON p.center = s.owner_center 
        AND p.id = s.owner_id
JOIN 
        evolutionwellness.subscriptiontypes st 
        ON s.subscriptiontype_center = st.center 
        AND s.subscriptiontype_id = st.id
JOIN 
        evolutionwellness.products pr 
        ON st.center = pr.center 
        AND st.id = pr.id
JOIN
        evolutionwellness.centers c 
        ON c.id = p.center   
LEFT JOIN evolutionwellness.subscriptions str
        ON str.transferred_center = s.center AND str.transferred_id = s.id
LEFT JOIN
        evolutionwellness.product_and_product_group_link pgl
        ON pgl.product_center = pr.center
        AND pgl.product_id = pr.id
        AND pgl.product_group_id IN (205,1601,3401,455,682,4012)   
LEFT JOIN
        evolutionwellness.account_receivables ac
        ON ac.customercenter = p.center
        AND ac.customerid = p.id
LEFT JOIN
        evolutionwellness.payment_agreements pa
        ON pa.center = ac.center
        AND pa.id = ac.id
        and pa.state IN (1,4)                                              
WHERE
        s.center IN (303,304,305,306,307,308,310,311,312,313,314,315,316,317,318,319,320,321,322,324,325,326,327,329,332,334,336,337,342,345,346,347,349,350,351)
--        AND
--        s.creation_time BETWEEN par.FromDate AND par.ToDate
        AND
        p.external_id IS NOT NULL
        AND 
        pgl.product_group_id IS NULL
        --AND 
        --trd.txtvalue IS NULL
        AND
        s.state IN (1,2,4,7,8)
ORDER BY s.start_date 
)t1
JOIN 
        params par 
        ON t1.center = par.CENTER_ID 
WHERE 
        t1.Creation_time BETWEEN par.FromDate AND par.ToDate
        AND
        t1.start_date > '2025-04-23' 
     