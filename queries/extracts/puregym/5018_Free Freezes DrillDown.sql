-- The extract is extracted from Exerp on 2026-02-08
-- To find UNRESTRICTED freezes
SELECT
cen.NAME as CENTERNAME,
p.CENTER ||'p'|| p.ID as PREF,
p.FULLNAME as Customer_Name,
CASE  p.PERSONTYPE  
   WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  
   WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  
   WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' 
ELSE 'UNKNOWN' END                         AS PERSONTYPE,
pro.NAME as Subscription_Name,
s.SUBSCRIPTION_PRICE as Subscription_Price,
sfp.START_DATE as Freeze_Start_Date,
sfp.END_DATE as Freeze_End_Date,
pemp.FULLNAME as Employee_Name

FROM
    SUBSCRIPTION_FREEZE_PERIOD sfp
JOIN
    SUBSCRIPTIONS s
ON
    sfp.SUBSCRIPTION_CENTER = s.center
    AND sfp.SUBSCRIPTION_ID = s.id
    AND s.STATE = 4
JOIN
    (
        SELECT
            sfp2.SUBSCRIPTION_CENTER,
            sfp2.SUBSCRIPTION_ID,
            max(sfp2.START_DATE) START_DATE
        FROM
            SUBSCRIPTION_FREEZE_PERIOD sfp2
        GROUP BY
            sfp2.SUBSCRIPTION_CENTER,
            sfp2.SUBSCRIPTION_ID) Latest_freeze
ON
    Latest_freeze.SUBSCRIPTION_CENTER = sfp.SUBSCRIPTION_CENTER
    AND sfp.SUBSCRIPTION_ID = Latest_freeze.SUBSCRIPTION_ID
    AND sfp.START_DATE = Latest_freeze.START_DATE
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
    
LEFT JOIN 
     CENTERS cen
     on cen.ID = s.OWNER_CENTER
     
LEFT JOIN PRODUCTS pro
     on pro.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     and pro.ID = s.SUBSCRIPTIONTYPE_ID
     
LEFT JOIN EMPLOYEES emp
     on emp.CENTER= sfp.EMPLOYEE_CENTER
     and emp.ID = sfp.EMPLOYEE_ID

LEFT JOIN
      PERSONS pemp
      on pemp.CENTER = emp.PERSONCENTER
      and pemp.ID = emp.PERSONID
     
WHERE
    sfp.TYPE = 'UNRESTRICTED'
    and sfp.STATE = 'ACTIVE'
    and s.OWNER_CENTER in (:center)
