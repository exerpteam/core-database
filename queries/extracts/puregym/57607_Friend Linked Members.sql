-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-8474
 SELECT
     friend.FULLNAME                             AS "Member Name",
     friend.center||'p'||friend.id               AS "Member ID",
     staff.FULLNAME                              AS "Linked Staff Member",
     CASE WHEN staff.center is not null THEN staff.center||'p'||staff.id
                                        ELSE null    END         AS "Staff ID",
     pr.NAME                                     AS "Subscription Name",
     TO_CHAR(s.START_DATE,'DD/MM/YYYY')          AS "Subscription Start Date",
     CASE  s.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE 'Unknown' END AS "Subscription Status",
     CASE  sub_staff.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE null END AS "Subscription Status of Staff",
     COALESCE(sale_emp.FULLNAME,sale_emp2.FULLNAME)            AS "Set up by"
 FROM
     persons friend
 JOIN
     SUBSCRIPTIONS s
 ON
     friend.center = s.OWNER_CENTER
     AND friend.id = s.OWNER_ID
     AND s.STATE in (2,4,8)
 JOIN
     PRODUCTS pr
 ON
     s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
     AND s.SUBSCRIPTIONTYPE_ID = pr.ID
 LEFT JOIN
     SUBSCRIPTION_SALES ss
 ON
     s.center = ss.SUBSCRIPTION_CENTER
     AND s.id = ss.SUBSCRIPTION_ID
 LEFT JOIN
    EMPLOYEES emp
 ON
    ss.EMPLOYEE_CENTER = emp.CENTER
    AND ss.EMPLOYEE_ID = emp.ID
 LEFT JOIN
    Persons sale_emp
 ON
    emp.PERSONCENTER = sale_emp.CENTER
    AND emp.PERSONID = sale_emp.ID
 LEFT JOIN
    SUBSCRIPTION_CHANGE sc
 ON
    sc.NEW_SUBSCRIPTION_CENTER = s.center
    AND sc.NEW_SUBSCRIPTION_ID = s.id
    AND sc.TYPE = 'TRANSFER'
 LEFT JOIN
    SUBSCRIPTION_SALES ss_old
 ON
    sc.OLD_SUBSCRIPTION_CENTER = ss_old.SUBSCRIPTION_CENTER
    AND sc.OLD_SUBSCRIPTION_ID = ss_old.SUBSCRIPTION_ID
 LEFT JOIN
    EMPLOYEES emp2
 ON
    ss_old.EMPLOYEE_CENTER = emp2.CENTER
    AND ss_old.EMPLOYEE_ID = emp2.ID
 LEFT JOIN
    Persons sale_emp2
 ON
    emp2.PERSONCENTER = sale_emp2.CENTER
    AND emp2.PERSONID = sale_emp2.ID
 LEFT JOIN
     RELATIVES r
 ON
     r.center = friend.center
     AND r.id = friend.id
     AND r.RTYPE = 1  -- friend
     AND r.STATUS < 2 -- active
 LEFT JOIN
     PERSONS staff
 ON
     r.RELATIVECENTER = staff.center
     AND r.RELATIVEID = staff.id
 LEFT JOIN
     SUBSCRIPTIONS sub_staff
 ON
     staff.center = sub_staff.OWNER_CENTER
     AND staff.id = sub_staff.OWNER_ID
     AND sub_staff.STATE in (2,4,8)
 LEFT JOIN
     PRODUCTS  prod_staff
 ON
     sub_staff.SUBSCRIPTIONTYPE_CENTER = prod_staff.center
     AND sub_staff.SUBSCRIPTIONTYPE_ID = prod_staff.id
 WHERE
    pr.GLOBALID in ('FAMILY_FRIEND_COMPLIMENTARY','FREE_COMPLEMENTARY')
    AND (prod_staff.GLOBALID is null  OR prod_staff.GLOBALID NOT IN ('STAFF_BRAVINGTON_HOUSE_ACCESS', 'STAFF_ACCESS_BRADFORD_DR'))
