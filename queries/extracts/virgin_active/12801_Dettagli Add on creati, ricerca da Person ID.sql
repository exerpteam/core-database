 SELECT
     p.center ||'p'|| p.id AS "Member ID",
     p.FULLNAME,
     ap.NAME AS Addon,
     sa.START_DATE,
     sa.END_DATE,
     sa.BINDING_END_DATE,
 longtodate(sa.CREATION_TIME)                      AS "Creation Time",
 -- sa.CREATION_TIME,
     sa.EMPLOYEE_CREATOR_CENTER||'emp'||sa.EMPLOYEE_CREATOR_ID AS Emp_ID,
     p2.FULLNAME                                               AS Emp_Name
 --,art.*
     --    DECODE (p.persontype, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS "Person Type",
     --    DECODE (s.state, 2,'Active', 3,'Ended', 4,'Frozen', 7,'Window', 8,'Created','Unknown')                                                                  AS "Subscription State"
 FROM
     PERSONS p
 LEFT JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.CENTER
     AND s.OWNER_ID = p.id
  JOIN
     SUBSCRIPTION_ADDON sa
 ON
     sa.SUBSCRIPTION_CENTER = s.CENTER
     AND sa.SUBSCRIPTION_ID = s.id
 JOIN
     MASTERPRODUCTREGISTER mpr
 ON
     mpr.ID = sa.ADDON_PRODUCT_ID
 JOIN
     PRODUCTS ap
 ON
     ap.CENTER = s.CENTER
     AND ap.GLOBALID = mpr.GLOBALID
 JOIN
     EMPLOYEES em
 ON
     sa.EMPLOYEE_CREATOR_CENTER = em.CENTER
     AND sa.EMPLOYEE_CREATOR_ID = em.id
 JOIN
     persons p2
 ON
     em.PERSONCENTER = p2.CENTER
     AND em.PERSONID = p2.id
     --join VA.SUBSCRIPTION_ADDON_PRODUCT sap on sa.ADDON_PRODUCT_ID = sap.ADDON_PRODUCT_ID
 left join INVOICELINES il on ap.CENTER = il.PRODUCTCENTER and ap.id = il.PRODUCTID and p.CENTER = il.PERSON_CENTER and p.id = il.PERSON_ID
 --join VA.AR_TRANS art on art.CENTER = ap.CENTER and art.EMPLOYEECENTER = sa.EMPLOYEE_CREATOR_CENTER and art.EMPLOYEEID = sa.EMPLOYEE_CREATOR_ID and art.TEXT = ap.NAME
 WHERE
 p.center ||'p'|| p.id in (:Members)
