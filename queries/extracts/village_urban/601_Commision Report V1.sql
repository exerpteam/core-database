-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     p.FULLNAME,
     p.center||'p'||p.id AS MemberID,
     emp.FULLNAME        AS "Sales Person Name",
     sa.SALES_DATE,
     pr.NAME AS "Subscription Name"
 FROM
     SUBSCRIPTION_SALES sa
 JOIN
     PRODUCTS pr
 ON
     pr.center = sa.SUBSCRIPTION_TYPE_CENTER
     AND pr.id = sa.SUBSCRIPTION_TYPE_ID
 JOIN
     PERSONS p
 ON
     p.center = sa.OWNER_CENTER
     AND p.id = sa.OWNER_ID
 JOIN
     PERSONS emp
 ON
     emp.center = sa.EMPLOYEE_CENTER
     AND emp.id = sa.EMPLOYEE_ID
 WHERE
     sa.SALES_DATE BETWEEN $$from_date$$ AND $$to_date$$
