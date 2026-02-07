SELECT 
    persons.center                                                             
                            AS CENTER, 
    persons.id                                                                 
                                AS ID, 
    persons.firstname || ' ' || persons.middlename || ' ' || persons.lastname
as CustomerName , 
    persons.Address1 || '  ' || persons.address2                             
            as Address, 
    persons.Zipcode, 
    Zipcodes.City, 
    email.TxtValue                                AS email,
   DECODE ( PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND',
4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR',
8,'GUEST','UNKNOWN') AS PERSON_TYPE,
    Products.name                               AS SubscriptionName, 
    Subscriptions.Subscription_Price    AS IndividualPrice, 
    Subscriptions.End_Date                 AS EndDate 
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
JOIN 
    ZipCodes 
    ON 
    persons.Country     = Zipcodes.Country 
    AND persons.ZipCode = Zipcodes.Zipcode 
LEFT JOIN 
    Person_Ext_Attrs email 
    ON 
    persons.center = email.PersonCenter 
    AND persons.id = email.PersonId 
    AND email.Name = '_eClub_Email' 
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
ORDER BY
    persons.persontype
