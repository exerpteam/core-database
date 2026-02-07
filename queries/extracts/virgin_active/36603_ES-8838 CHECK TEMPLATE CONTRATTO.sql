 SELECT DISTINCT
     COALESCE(c.shortname,('AREA: '||a.name)) AS "Override scope",
     mpr.GLOBALID                        AS "Produt Global ID",
     mpr.CACHED_PRODUCTNAME              AS "Product Name",
     CASE mpr.USE_CONTRACT_TEMPLATE WHEN 1 THEN COALESCE(t.DESCRIPTION,'>>>DEFAULT CONTRACT<<<')  ELSE 'NO CONTRACT' END
     AS "Customer Contract"
 FROM
     MASTERPRODUCTREGISTER mpr
 LEFT JOIN
     centers c
 ON
     c.id = mpr.SCOPE_ID
 AND mpr.SCOPE_TYPE = 'C'
 LEFT JOIN
     areas a
 ON
     a.id = mpr.SCOPE_ID
 AND mpr.SCOPE_TYPE = 'A'
 LEFT JOIN
     TEMPLATES t
 ON
     t.ID = mpr.CONTRACT_TEMPLATE_ID
 WHERE mpr.GLOBALID in ($$GLOBAL_ID$$)
