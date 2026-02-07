 select distinct * from (
 SELECT
     mpr.ID "Master Product ID",
     prod.CENTER,
     c.NAME "center name",
     prod.GLOBALID "Global Name",
     prod.NAME "Product Name",
     pjf.show_in_sale,
	
      r.ROLENAME "Required Role",
     pjf.NEEDS_PRIVILEGE "Purchase Require Privilege",
     pa.scope_type || pa.scope_id "Scope level",
     
CASE
        WHEN pa.scope_type = 'A'
                
        THEN
            (
                SELECT
                    a.name
                FROM
                    areas a
                where
                a.id = pa.scope_id)
                
        ELSE (
                SELECT
                    c.name
                FROM
                    centers c
                where
                c.id = pa.scope_id)
    END AS "Scope name"
    
 FROM
     SUBSCRIPTIONTYPES st
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = st.CENTER
     AND prod.ID = st.ID
         and prod.blocked = 0
 JOIN
     CENTERS c
 ON
     c.id = prod.CENTER

 JOIN
     MASTERPRODUCTREGISTER mpr
 ON
     mpr.GLOBALID = prod.GLOBALID
      LEFT JOIN
     PRODUCTS pjf
 ON
     pjf.CENTER = prod.CENTER
     AND pjf.GLOBALID = 'CREATION_' || prod.GLOBALID
 
 LEFT JOIN
     ROLES r
 ON
     r.ID = pjf.REQUIREDROLE
 join
 product_availability pa
 on
 pa.product_master_key = mpr.id
 JOIN
     LICENSES li
 ON
     li.CENTER_ID = c.id
     AND li.FEATURE = 'clubLead'
 where
 prod.center in (:scope)
 
 

 ORDER BY
     mpr.id,
     prod.name,
     prod.globalid,
     pa.scope_type,
     pa.scope_id
     ) t1
