-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4147
SELECT 
  TO_CHAR((SALES_DATE), 'YYYY-MM-DD') AS "date_objective",
  MEMBER_TYPE AS "name_objective",
  to_CHAR(COUNT(distinct "Member id"),'FM9990') AS "count_objective",
  '1416' AS "value_objective"
--  'dkk' AS "currency_objective"
FROM
(  
SELECT DISTINCT
  'Members' AS MEMBER_TYPE,
    p.CENTER || 'p' || p.ID "Member id",
    p.SEX                                                "Sex",
    floor(months_between(TRUNC(current_timestamp),p.BIRTHDATE)/12) "Age",
    p.ZIPCODE "Postal number",
    p.CITY "City",
    ss.SUBSCRIPTION_CENTER "Signup club",
    ss.SALES_DATE,
    CASE
        WHEN ( ss.EMPLOYEE_CENTER,ss.EMPLOYEE_ID ) IN ((114,813))
        THEN 'API'
        ELSE 'Club'
    END AS "Signup method",
    CASE WHEN scl.CENTER IS NOT NULL THEN 0 ELSE 1 END "New member",
    prod.NAME "Subscription name",
    ss.price_new joining_fee,
    ss.PRICE_PERIOD "Subscription price"
FROM
    SUBSCRIPTION_SALES ss
JOIN
    PRODUCTS prod
ON
    prod.CENTER = ss.SUBSCRIPTION_TYPE_CENTER
    AND prod.ID = ss.SUBSCRIPTION_TYPE_ID
JOIN
    product_and_product_group_link pg_link
ON
    pg_link.product_center = prod.center
    AND pg_link.product_id = prod.id
JOIN
    product_group pg
ON
    pg.id = pg_link.product_group_id
    OR pg.top_node_id = pg_link.product_group_id
JOIN
    PERSONS p
ON
    p.CENTER = ss.OWNER_CENTER
    AND p.ID = ss.OWNER_ID
LEFT JOIN
    STATE_CHANGE_LOG scl
ON
    scl.CENTER = p.CENTER
    AND scl.ID = p.ID
    AND scl.STATEID = 1
    AND scl.ENTRY_TYPE = 1
    AND scl.ENTRY_END_TIME IS NOT NULL
LEFT JOIN
    PERSONS oldp
ON
    oldp.CURRENT_PERSON_CENTER = p.CENTER
    AND oldp.CURRENT_PERSON_ID = p.ID
LEFT JOIN
    STATE_CHANGE_LOG act
ON
    act.CENTER = oldp.CENTER
    AND act.ID = oldp.ID
    AND act.ENTRY_TYPE = 1
    AND act.STATEID = 1
WHERE
    ss.SALES_DATE BETWEEN $$fromDate$$ AND $$toDate$$
    AND ss.SUBSCRIPTION_CENTER IN ($$scope$$)
    AND ss.TYPE = 1
    AND pg.name IN ('Medlemskaber, Betalingsservice',
                    'Medlemskaber, Kontant')
) t1
GROUP BY
  SALES_DATE, MEMBER_TYPE
