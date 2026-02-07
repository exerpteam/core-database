--FT 1 "15 Days"
SELECT
        p.center ||'p'|| p.id AS "Member ID"
        ,p.firstname AS "Member first name"
        ,p.lastname AS "Member last name"
        ,s.start_date AS "Subscription Start Date"
        ,longtodatec(F1.start_time,s.center) AS "FT booking start date"
        ,F1.state AS "FT booking state"
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
                b.activity = 603
                AND
                part.state IN ('PARTICIPATION','BOOKED')
        )F1                                 
        ON p.center = F1.participant_center
        AND p.id = F1.participant_id 
WHERE
        s.state IN (2,4)
        AND 
        s.start_date = CURRENT_DATE - 15 
        --Should be added when ready 
        --AND
        --F1.participant_center IS NULL       
       
        
  
                            