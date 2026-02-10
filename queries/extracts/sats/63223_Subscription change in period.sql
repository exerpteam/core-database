-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     s_new.OWNER_CENTER , s_new.OWNER_ID ,
     longToDate(sc.CHANGE_TIME)                  AS change_time,
     sc.employee_center                          AS employee_center,
     sc.employee_center||'emp'||sc.employee_id   AS employee,
     per.fullname                                AS employee_name,
     pro_new.GLOBALID                            AS changed_to,
     pro_old.globalid                            AS changed_from,
     s_old.SUBSCRIPTION_PRICE as Old_Price,
     s_new.SUBSCRIPTION_PRICE as New_Price
 FROM
     SUBSCRIPTION_CHANGE sc
 JOIN
     SUBSCRIPTIONS s_new
 ON
     s_new.CENTER = sc.NEW_SUBSCRIPTION_CENTER
     AND s_new.ID = sc.NEW_SUBSCRIPTION_ID
 JOIN
     subscriptiontypes s_new_type
 ON
     s_new.subscriptiontype_center = s_new_type.center
     AND s_new.subscriptiontype_id = s_new_type.id
 JOIN
     products pro_new
 ON
     s_new_type.center = pro_new.center
     AND s_new_type.id = pro_new.id
 JOIN
     SUBSCRIPTIONS s_old
 ON
     s_old.CENTER = sc.OLD_SUBSCRIPTION_CENTER
     AND s_old.ID = sc.OLD_SUBSCRIPTION_ID
 JOIN
     subscriptiontypes s_old_type
 ON
     s_old.subscriptiontype_center = s_old_type.center
     AND s_old.subscriptiontype_id = s_old_type.id
 JOIN
     products pro_old
 ON
     s_old_type.center = pro_old.center
     AND s_old_type.id = pro_old.id
 LEFT JOIN
     employees emp
 ON
     sc.employee_center = emp.center
     AND sc.employee_id = emp.id
 LEFT JOIN
     persons per
 ON
     emp.personcenter = per.center
     AND emp.personid = per.id
 WHERE
     sc.OLD_SUBSCRIPTION_CENTER IS NOT NULL
     AND sc.NEW_SUBSCRIPTION_CENTER IS NOT NULL
     AND s_new.OWNER_CENTER IN (:scope)
     AND sc.CHANGE_TIME BETWEEN (:from_date) AND (
         :to_date) + 86400000
     AND sc.type LIKE 'TYPE'
     AND sc.cancel_time IS NULL
 ORDER BY
     s_new.OWNER_CENTER,
     s_new.OWNER_ID
