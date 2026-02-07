SELECT

    emp.CENTER || 'emp' || emp.ID AS "Employee ID",
    pemp.FULLNAME AS "Employee name",
    ss.SALES_DATE AS "Sale date",
    ss.START_DATE AS "Start date",
    ss.PRICE_PERIOD AS "Price",
    p.CENTER || 'p' || p.ID AS "Person ID",
    p.FULLNAME AS "Person",
    CASE  p.STATUS 
        WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' ELSE 'UNKNOWN'
        END AS "Person state",
    CASE  p.PERSONTYPE
        WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN'
        END AS "Person type",
    pem.txtvalue AS "Email"

FROM

    SUBSCRIPTION_SALES ss
    JOIN CENTERS c
        ON c.ID = ss.OWNER_CENTER
    JOIN EMPLOYEES emp
        ON emp.CENTER = ss.EMPLOYEE_CENTER
        AND emp.ID = ss.EMPLOYEE_ID
    JOIN PERSONS pemp
        ON pemp.CENTER = emp.PERSONCENTER
        AND pemp.ID = emp.PERSONID
    JOIN PERSONS p
        ON p.CENTER = ss.OWNER_CENTER
        AND p.ID = ss.OWNER_ID
    LEFT JOIN RELATIVES r
        ON p.center = r.relativecenter
        AND p.id = r.relativeid
        AND r.rtype = 2
        AND r.status <> 3
    LEFT JOIN person_ext_attrs pem
        ON pem.personcenter = p.center
        AND pem.personid = p.id
        AND pem.name = '_eClub_Email'

WHERE p.CENTER IN (:Scope)
AND ss.SALES_DATE BETWEEN :SalesFrom AND :SalesTo
AND emp.CENTER = 100
    AND emp.ID = 132201