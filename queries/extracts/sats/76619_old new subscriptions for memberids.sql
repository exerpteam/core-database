Select distinct
p.center ||'p'|| p.id as memberid,
p.fullname,
TRUNC(SYSDATE - p.LAST_ACTIVE_START_DATE) + 1 AS UNBROKEN_DAYS,
ext.TXTVALUE,
s.START_DATE,
s.END_DATE,
pr.name

FROM 
    persons p
JOIN 
   Subscriptions s
    ON 
    S.owner_center = p.center 
    AND S.owner_id = p.id 
JOIN 
    SubscriptionTypes st 
    ON 
    S.SubscriptionType_Center = St.Center 
    AND S.SubscriptionType_ID = St.ID 
JOIN 
    Products pr
    ON 
    St.Center = Pr.Center 
    AND St.Id = Pr.Id 

JOIN
                            PERSON_EXT_ATTRS ext
                        ON
                            ext.PERSONCENTER = p.CENTER
                        AND ext.PERSONID = p.ID
                        AND ext.NAME = 'UNBROKENMEMBERSHIPGROUPALL'

where 
p.FIRST_ACTIVE_START_DATE != p.LAST_ACTIVE_START_DATE
and p.status in (1,3) 
and ext.TXTVALUE not in ('Platinum')
and (p.center,p.id) in (:memberid)
