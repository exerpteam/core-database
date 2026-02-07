-- This is the version from 2026-02-05
--  
SELECT 
    persons.*,
    persons.center ||'p'|| persons.id                                                           
                            AS Memberid,     
    Products.name                               AS SubscriptionName, 
    Subscriptions.Subscription_Price    AS IndividualPrice 
   
FROM 
    Subscriptions 
JOIN 
    persons 
    ON 
    Subscriptions.owner_center = persons.center 
    AND Subscriptions.owner_id = persons.id 
JOIN 
    SubscriptionTypes 
    ON 
    Subscriptions.SubscriptionType_Center = SubscriptionTypes.Center 
    AND Subscriptions.SubscriptionType_ID = SubscriptionTypes.ID 
JOIN 
    Products 
    ON 
    SubscriptionTypes.Center = Products.Center 
    AND SubscriptionTypes.Id = Products.Id 


WHERE 
    /* Only active subscriptions */ 
    Subscriptions.state in (2 ,4, 8)
    AND
    (
        persons.center,persons.id
    )
    IN
    (
        SELECT
            p2.center,
            p2.id
        FROM
            PERSONS p2
        LEFT JOIN PERSONS p3
        ON
            p3.CURRENT_PERSON_CENTER = p2.CENTER
            AND p3.CURRENT_PERSON_ID = p2.CURRENT_PERSON_ID
        WHERE
            (
                p2.CENTER,p2.ID
            )
            IN (:person)
            OR
            (
                p3.CENTER,p3.id
            )
            IN (:person)
    )
