WITH params AS MATERIALIZED
(
  SELECT 
     datetolongTZ(TO_CHAR(CAST($$fromdate$$ AS DATE),'YYYY-MM-DD HH24:MI'),'Europe/London') AS fromdate,
     datetolongTZ(TO_CHAR(CAST($$todate$$ AS DATE)+1,'YYYY-MM-DD HH24:MI'), 'Europe/London') AS todate
  
)
 SELECT
     ss.owner_center||'p'||ss.owner_id             AS "Person ID",
     sa.SUBSCRIPTION_CENTER ||'ss'|| sa.SUBSCRIPTION_id as "Subscription ID",
     prod.name                                    AS "Bolt-on",
     to_char(longtodate(sa.CREATION_TIME),'dd-MM-yyyy')                 as "Entry date",
     emp.center ||'emp'|| emp.id as "Employee ID",
     empp.fullname               as "Employee name"
 FROM
     PARAMS,
     SUBSCRIPTION_ADDON sa
 JOIN masterproductregister m
 ON
     sa.addon_product_id = m.id
 JOIN products prod
 ON
     m.globalid = prod.globalid
 JOIN subscription_sales ss
 ON
     sa.subscription_center = ss.subscription_center
 AND sa.subscription_id= ss.subscription_id
 JOIN subscriptions s
 ON
     ss.owner_center = s.owner_center
 AND ss.owner_id = s.owner_id
 JOIN persons per
 ON
     per.center = s.owner_center
 AND per.id = s.owner_id
 join EMPLOYEES emp
 on
 emp.center = sa.EMPLOYEE_CREATOR_CENTER
 and
 emp.id = sa.EMPLOYEE_CREATOR_ID
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
 emp.PERSONCENTER = empp.center
 and
 emp.PERSONID = empp.id
 WHERE
     ss.owner_center  in ($$scope$$)
 and sa.cancelled = 0
 and (sa.START_DATE < sa.END_DATE or sa.END_DATE is NULL)
 AND sa.INDIVIDUAL_PRICE_PER_UNIT = 0
 and sa.CREATION_TIME between params.fromdate and params.todate
 GROUP BY
         per.center,
         per.id,
     ss.owner_center,
     ss.owner_id,
         sa.center_id,
     sa.cancelled,
     prod.name,
     sa.SUBSCRIPTION_CENTER,
     sa.SUBSCRIPTION_id,
     sa.INDIVIDUAL_PRICE_PER_UNIT,
     sa.START_DATE,
     emp.center ||'emp'|| emp.id,
     empp.fullname,
     sa.CREATION_TIME
 ORDER BY
     ss.owner_center,
     ss.owner_id
