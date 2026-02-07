SELECT
 p.center ||'p'|| p.id                                   AS "Person ID",
s.center ||'ss'|| s.id as "Subscription ID",
to_char(longtodate(sp.entry_time),'yyyy-mm-dd') as "Entry date",
to_char(sp.FROM_DATE,'yyyy-mm-dd')  as "Start date",
to_char(sp.TO_DATE,'yyyy-mm-dd') as "End date",
sp.coment as "Comment",
sp.EMPLOYEE_CENTER ||'emp'|| sp.EMPLOYEE_ID as "Employee ID",
empp.fullname as "Employee name",
 --   p.firstname || ' ' || p.middlename || ' ' || p.lastname AS CustomerName ,
           -- pr.name                                           AS SubscriptionName,
 sp.price as "Price override",
            pr.price as "Live product price",
(sp.price-pr.price) as "Difference"          
 
   
      
FROM
    Subscriptions s
JOIN
    persons p
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    SubscriptionTypes st
ON
    s.SubscriptionType_Center = st.Center
AND s.SubscriptionType_ID = st.ID
JOIN
    Products pr
ON
    st.Center = pr.Center
AND st.Id = pr.Id

join SUBSCRIPTION_PRICE sp
on
s.center = sp.SUBSCRIPTION_CENTER
and
s.id  = sp.SUBSCRIPTION_ID

join EMPLOYEES emp
on
emp.center = sp.employee_center
and emp.id = sp.employee_id

join EMPLOYEESROLES empr
on
empr.center = emp.center
and
empr.id = emp.id
join ROLES ro
on
ro.id = empr.ROLEID
and
ro.rolename = 'MS Audit'

join persons empp 
on
empp.center = emp.PERSONCENTER
and
empp.id = emp.PERSONID 


left join SUBSCRIPTION_SALES ss
on
 ss.SUBSCRIPTION_CENTER = s.center
 and
ss.SUBSCRIPTION_ID = s.id

left JOIN
 PRIVILEGE_USAGES pu
on
sp.ID = pu.TARGET_ID
AND pu.TARGET_SERVICE = 'SubscriptionPrice'

WHERE
    /* Only active subscriptions */
    s.state IN (2,4,8)
AND s.center in (:scope)
   
AND sp.ENTRY_TIME >= :from_date 
AND sp.ENTRY_TIME <= :to_date
and sp.TYPE not in  ('NORMAL') 
and pu.TARGET_SERVICE is Null
and pr.price != sp.price
and sp.coment is not NULL