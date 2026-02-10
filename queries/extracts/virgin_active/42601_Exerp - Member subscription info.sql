-- The extract is extracted from Exerp on 2026-02-08
-- Subscription information needed by MWC to create multiple subscription
 SELECT
     persons.center || 'p' || persons.id
                             AS memberid,
     persons.id
                                 AS ID,
    CASE  PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'
  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'
  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSON_TYPE,
     persons.first_active_start_date AS FirstActiveStartDate,
     Products.name                               AS SubscriptionName,
     Subscriptions.CENTER || 'ss' || Subscriptions.ID AS SubscirptionID,
     Subscriptions.End_Date                 AS EndDate,
 Subscriptions.BILLED_UNTIL_DATE as billeduntil,
 Subscriptions.START_DATE as startdate
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
     Subscriptions.state in (2 ,4, 7, 8)
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
