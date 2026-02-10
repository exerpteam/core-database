-- The extract is extracted from Exerp on 2026-02-08
--  
-- PARAMS
-- ------------
-- ClubId : integer
-- PersonId : integer
-- StartDate : date
-- EndDate : date

SELECT 

    -- Corporate Cases
    (
    SELECT 
        CASE
            WHEN (COUNT(rel.*) > 0) THEN 
                TRUE
            ELSE 
                FALSE
        END AS CorporateCases

    FROM persons p
    
    JOIN relatives rel
        ON rel.center = p.center
        AND rel.id = p.id
        AND rel.rtype = 3

    JOIN state_change_log scl
        ON scl.center = rel.center
        AND scl.id = rel.id
        AND scl.subid = rel.subid
        AND scl.entry_type = 4
        AND scl.stateid = 1
        AND 
            (
                CAST(TO_CHAR(Longtodatec(scl.book_start_time, scl.center), 'YYYY-MM-DD') AS DATE) <= :EndDate
                AND 
                ( 
                    scl.book_end_time IS NULL
                    OR 
                    CAST(TO_CHAR(Longtodatec(scl.book_end_time, scl.center), 'YYYY-MM-DD') AS DATE) >= :StartDate 
                ) 
            )

    JOIN persons rperson
        ON rperson.center = rel.relativecenter
        AND rperson.id = rel.relativeid

    JOIN person_ext_attrs pea
        ON rperson.id = pea.personid
        AND rperson.center = pea.personcenter
        AND pea.NAME = 'COMPANYTYPE'
        AND pea.txtvalue NOT IN ('CIP', 'CERT', 'CORPTENDISC')

    WHERE p.center = :ClubId 
        AND p.id = :PersonId

    ) AS CorporateCase,

    -- PIF (Paid in Full) subscription transferred during the request period
    (
    SELECT 
      CASE
          WHEN (COUNT(st.*) > 0) THEN 
              TRUE
          ELSE 
              FALSE
      END AS PIFTransfer

    FROM subscriptions s

    JOIN subscription_change sc    
      ON sc.old_subscription_center = s.center 
      AND sc.old_subscription_id = s.id 
      AND sc.type = 'TRANSFER'

    JOIN subscriptiontypes st
      ON st.center = s.subscriptiontype_center
      AND st.id = s.subscriptiontype_id
      AND st.st_type = 0 -- Zero is PIF subscription type

    JOIN persons p
      ON p.center = s.owner_center
      AND p.id = s.owner_id
      AND p.center = :ClubId
      AND p.id = :PersonId
     
    WHERE s.state = 3 -- subscription ended
      AND s.sub_state = 6 -- subscription tranferred
      AND 
         (s.end_date BETWEEN :StartDate AND :EndDate -- prevents sending receipt when the transfer occurred
         OR
         s.start_date BETWEEN :StartDate AND :EndDate) -- prevents sending the receipt when the subscription was bought

    ) AS PIFTransfer,

    -- Reserved for future cases yet to be determined
    (FALSE) AS OverrideCase