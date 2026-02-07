SELECT
    p.CENTER||'p'||p.ID                                                                    AS "Member ID",
    p.FULLNAME                                                                             AS "Member Name",
    s.CENTER||'ss'||s.ID                                                                   AS "Subscription ID",
    products.name as "Subscription name",
   s.STATE AS "Subscription State",
    p2.FULLNAME                                                                            AS "Employee Name",
    sp.EMPLOYEE_CENTER||'emp'||sp.EMPLOYEE_ID                                              AS "Employee ID",
    sp.FROM_DATE                                                                           AS "Price Change: FromDate",
	sp.TO_DATE                                                                             AS "Price Change: ToDate",
    longtodate(sp.ENTRY_TIME)                                                      AS "Price Change: EntryTime",
    s.SUBSCRIPTION_PRICE                                                                   AS "Current price"

FROM
    persons p
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND p.ID = s.OWNER_ID  
left JOIN
    SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.CENTER
    AND sp.SUBSCRIPTION_ID = s.id 
and sp.from_date = (:date)
and sp.CANCELLED = 0

   
left JOIN 
    SubscriptionTypes 
    ON 
    s.SubscriptionType_Center = SubscriptionTypes.Center 
    AND s.SubscriptionType_ID = SubscriptionTypes.ID 
left JOIN 
    Products 
    ON 
    SubscriptionTypes.Center = Products.Center 
    AND SubscriptionTypes.Id = Products.Id 
    
left JOIN
    EMPLOYEES e
ON
    e.CENTER = sp.EMPLOYEE_CENTER
    AND e.ID = sp.EMPLOYEE_ID
left JOIN
    persons p2
ON
    e.PERSONCENTER = p2.CENTER
    AND e.PERSONID = p2.ID
WHERE
--sp.FROM_DATE = to_date('2020-02-01', 'yyyy-MM-dd')
 s.state in (2,4)
and (p.center) in (:scope)