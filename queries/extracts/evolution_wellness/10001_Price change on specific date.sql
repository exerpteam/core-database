SELECT
    Case when oldid.txtvalue is not null
    then oldid.txtvalue
    else p.external_id end
    as "External ID",  
    p.CENTER||'p'||p.ID                                                                      AS "Membership Number",
    c.name                                                                            as "Centre name of member",
    p.firstname                                                                             AS "First name",
    p.lastname                                                                             AS "Last name",        
    products.name as "Subscription name",
      sp.FROM_DATE                                                                           AS "Date of price increase amt",
      sp2.price                                                                              as "Original price amount",
      sp.price-sp2.price                                                                     as "Price increase amount amt",
      sp.price                                                                               as "After price increase amt", 
      longtodate(sp.ENTRY_TIME)                                                      AS "Price Change: EntryTime",
     p2.FULLNAME                                                                            AS "Price change Employee Name",
    sp.EMPLOYEE_CENTER||'emp'||sp.EMPLOYEE_ID                                              AS "Price change Employee ID",
sp.coment as "Comment",
sp.type as "Type",
comp.lastname as "Corporate Name"

FROM
    SUBSCRIPTION_PRICE sp
JOIN
    SUBSCRIPTIONS s
ON
    sp.SUBSCRIPTION_CENTER = s.CENTER
    AND sp.SUBSCRIPTION_ID = s.id   
JOIN
    persons p
ON
    s.OWNER_CENTER = p.CENTER
    AND p.ID = s.OWNER_ID
JOIN centers c    
on
p.center = c.id    
    
JOIN 
    SubscriptionTypes 
    ON 
    s.SubscriptionType_Center = SubscriptionTypes.Center 
    AND s.SubscriptionType_ID = SubscriptionTypes.ID 
JOIN 
    Products 
    ON 
    SubscriptionTypes.Center = Products.Center 
    AND SubscriptionTypes.Id = Products.Id 
    
    JOIN
    EMPLOYEES e
ON
    e.CENTER = sp.EMPLOYEE_CENTER
    AND e.ID = sp.EMPLOYEE_ID
JOIN
    persons p2
ON
    e.PERSONCENTER = p2.CENTER
    AND e.PERSONID = p2.ID
left join SUBSCRIPTION_PRICE sp2
on    
sp.SUBSCRIPTION_CENTER = sp2.SUBSCRIPTION_CENTER
    AND sp.SUBSCRIPTION_ID = sp2.SUBSCRIPTION_ID    
    and sp.from_date = sp2.to_date+1
left join person_ext_attrs oldid    
on
oldid.personcenter = p.center
and
oldid.personid = p.id
and
oldid.name = '_eClub_OldSystemPersonId'
left JOIN
             RELATIVES r
         ON
             p.CENTER = r.CENTER
             AND p.ID = r.ID
             AND r.RTYPE = 3
             AND r.STATUS < 2
left JOIN
             PERSONS comp
         ON
             comp.CENTER = r.relativecenter
             AND comp.ID = r.relativeid             
    
WHERE
--sp.FROM_DATE = to_date('2020-02-01', 'yyyy-MM-dd')
sp.CANCELLED = 0
--and s.state in (2,4)
and p.center in (:scope)
and sp.from_date = (:date)
and sp2.price is not NULL