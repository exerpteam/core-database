 SELECT
	C.Shortname,
     s.OWNER_CENTER || 'p' || s.OWNER_ID pid,
         p.fullname,
     s.CENTER || 'ss' || s.ID sid ,
     s.BINDING_PRICE,
     s.SUBSCRIPTION_PRICE,
     prod.NAME,
     prod.GLOBALID,
         s.end_date
 FROM
     SUBSCRIPTIONS s
 join 
	persons p 
	on p.center = s.owner_center and p.id = s.owner_id
 JOIN
	Centers C 
	ON C.ID = p.center
 JOIN 
	PRODUCTS prod
	ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 WHERE
 s.STATE IN (2,4,8)
 and s.OWNER_CENTER in (:Scope)
     /* No scheduled price change > zero in the future*/
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             SUBSCRIPTION_PRICE sp
         WHERE
             sp.SUBSCRIPTION_CENTER = s.CENTER
             AND sp.SUBSCRIPTION_ID = s.ID
             AND
             (
                 sp.TO_DATE > current_timestamp
                 OR sp.TO_DATE IS NULL
             )
             AND sp.PRICE > 0
             AND sp.CANCELLED = 0
     )
 and
 prod.NAME not like '%Gymflex%'
