SELECT
           p.CENTER,
           p.ID,
pr.name,
s.state
        FROM
persons p
 JOIN
            SUBSCRIPTIONS s
on p.id =  s.OWNER_ID
 and p.center = s.OWNER_CENTER
         
LEFT JOIN 
PRODUCTS Pr
 ON Pr.CENTER = S.SUBSCRIPTIONTYPE_CENTER AND Pr.ID = S.SUBSCRIPTIONTYPE_ID

where S.STATE = 8 and
pr.name in ( 'PT by DD 4 Pack' , 'PT by DD 8 Pack', 'PT by DD Master 4 Pack' , 'PT by DD Master 8 Pack' )