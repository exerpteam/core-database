-- The extract is extracted from Exerp on 2026-02-08
--  
--FT 2 "21 Days"
SELECT
        p.center ||'p'|| p.id AS "Member ID"
        ,p.firstname AS "Member first name"
        ,p.lastname AS "Member last name"
        ,s.start_date AS "Subscription Start Date"
        ,longtodatec(F1.start_time,s.center) AS "FT1 booking start date"
        ,F1.state AS "FT1 booking state"
        ,longtodatec(F2.start_time,s.center) AS "FT2 booking start date"
        ,F2.state AS "FT2 booking state"
FROM
        leejam.subscriptions s
JOIN
        leejam.subscriptiontypes st
        ON st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
JOIN
        leejam.products prod
        ON prod.center = st.center
        AND prod.id = st.id
JOIN
        leejam.product_and_product_group_link prg
        ON prg.product_center = prod.center
        AND prg.product_id = prod.id
        AND prg.product_group_id = 2801
JOIN
        leejam.persons p
        ON p.center = s.owner_center
        AND p.id = s.owner_id        
JOIN
        (
        SELECT
                part.participant_center
                ,part.participant_id
                ,part.state
                ,part.start_time
        FROM
                leejam.participations part
        JOIN
                leejam.bookings b
                ON b.center = part.booking_center
                AND b.id = part.booking_id
        WHERE
                b.activity = 603
                AND
                part.state = 'PARTICIPATION'
                AND
                CAST(longtodatec(part.start_time,part.center) AS date) = Current_date - 21
        )F1                                 
        ON p.center = F1.participant_center
        AND p.id = F1.participant_id 
LEFT JOIN
        (
        SELECT
                part.participant_center
                ,part.participant_id
                ,part.state
                ,part.start_time
        FROM
                leejam.participations part
        JOIN
                leejam.bookings b
                ON b.center = part.booking_center
                AND b.id = part.booking_id
        WHERE
                b.activity = 407
                AND
                part.state IN ('PARTICIPATION','BOOKED')
        )F2                                 
        ON p.center = F2.participant_center
        AND p.id = F2.participant_id         
WHERE
        s.state IN (2,4)       
        --Should be added when ready 
        --AND
        --F2.participant_center IS NULL        
  
                              