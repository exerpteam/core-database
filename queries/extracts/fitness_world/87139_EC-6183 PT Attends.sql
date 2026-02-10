-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    INSTRUCTORS AS
    (
        SELECT
            emp.CENTER,
            emp.ID,
            p.FULLNAME
        FROM
            PERSON_STAFF_GROUPS psg
        JOIN
            PERSONS p
        ON
            p.center = psg.PERSON_CENTER
        AND p.id = psg.PERSON_ID
        JOIN
            EMPLOYEES emp
        ON
            emp.PERSONCENTER = psg.PERSON_CENTER
        AND emp.PERSONID = psg.PERSON_ID
        WHERE
            psg.STAFF_GROUP_ID = 1
    )
SELECT
    c.OWNER_CENTER ||'p'|| c.OWNER_ID                  AS MedlemsId,
    curr_p.FULLNAME                                    AS Medlemsnavn,
    TO_CHAR(longtodate(cu.TIME), 'dd-MM-YYYY HH24:MI') AS Benyttelsestid,
    cu.CLIPS                                           AS "ANTAL BRUGTE KLIP",
    --cu.TYPE,
    cu.DESCRIPTION Beskrivelse,
    pr.NAME        AS "PRODUKT NAVN",
    CASE
        WHEN cu.EMPLOYEE_CENTER IS NULL
        THEN NULL
        ELSE cu.EMPLOYEE_CENTER ||'emp'|| cu.EMPLOYEE_ID
    END         AS PERSONALEID,
    pt.fullname AS PT_Navn,
    pu.TARGET_CENTER AS Benyttelsescenter,
    cen.NAME    AS "BENYTTELSESCENTER NAVN"
FROM
    CLIPCARDS c
JOIN
    CARD_CLIP_USAGES cu
ON
    cu.CARD_CENTER = c.CENTER
AND cu.CARD_ID = c.ID
AND cu.CARD_SUBID = c.SUBID
AND (
        cu.DESCRIPTION LIKE 'Personlig træning%'
    OR  cu.DESCRIPTION LIKE 'Personlig Træning%'
    OR  cu.DESCRIPTION LIKE 'Personlig træner%')
AND cu.DESCRIPTION NOT LIKE '%uddannelse%'
    --AND cu.EMPLOYEE_CENTER is not null
    --AND cu.TYPE != 'PRIVILEGE'
JOIN
    PRIVILEGE_USAGES pu
ON
    pu.ID = cu.REF
JOIN
    CENTERS cen
ON
    cen.ID = pu.TARGET_CENTER
JOIN
    PERSONS p
ON
    p.CENTER = c.OWNER_CENTER
AND p.ID = c.OWNER_ID
JOIN
    INVOICELINES invl
ON
    invl.CENTER = c.INVOICELINE_CENTER
AND invl.ID = c.INVOICELINE_ID
AND invl.SUBID = c.INVOICELINE_SUBID
JOIN
    PRODUCTS pr
ON
    pr.CENTER = invl.PRODUCTCENTER
AND pr.ID = invl.PRODUCTID
JOIN
    PERSONS curr_p
ON
    curr_p.CENTER = p.CURRENT_PERSON_CENTER
AND curr_p.ID = p.CURRENT_PERSON_ID
LEFT JOIN
    INSTRUCTORS pt
ON
    pt.CENTER = cu.EMPLOYEE_CENTER
AND pt.ID = cu.EMPLOYEE_ID
WHERE
    cu.TIME BETWEEN :USAGE_FROM AND :USAGE_TO +86400000
AND pu.TARGET_CENTER IN (:scope)
UNION
SELECT DISTINCT
    invl.PERSON_CENTER || 'p' || invl.PERSON_ID                 medlemsid,
    curr_p2.FULLNAME                                            medlemsnavn,
    TO_CHAR(longtodate(inv.TRANS_TIME),'DD-MM-YYYY HH24:MI') AS benyttelsestid,
    NULL::int                                                     AS "ANTAL BRUGTE KLIP",
    inv.TEXT                                                 beskrivelse,
    prod.NAME                                                AS "PRODUKT NAVN",
    CASE
        WHEN inv.EMPLOYEE_CENTER IS NULL
        THEN NULL
        ELSE inv.EMPLOYEE_CENTER ||'emp'|| inv.EMPLOYEE_ID
    END         AS PERSONALEID,
    pt.fullname AS PT_Navn,
    invl.PRODUCTCENTER Benyttelsescenter,
    c.NAME      AS "BENYTTELSESCENTER NAVN"
FROM
    INVOICELINES invl
JOIN
    INVOICES inv
ON
    inv.CENTER = invl.CENTER
AND inv.ID = invl.ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
AND prod.ID = invl.PRODUCTID
JOIN
    PERSONS p2
ON
    invl.PERSON_CENTER = p2.CENTER
AND invl.PERSON_ID = p2.ID
JOIN
    PERSONS curr_p2
ON
    p2.CURRENT_PERSON_CENTER = curr_p2.CENTER
AND p2.CURRENT_PERSON_ID = curr_p2.ID
JOIN
    CENTERS c
ON
    c.ID = invl.PRODUCTCENTER
LEFT JOIN
    INSTRUCTORS pt
ON
    pt.CENTER = inv.EMPLOYEE_CENTER
AND pt.ID = inv.EMPLOYEE_ID
WHERE
    prod.GLOBALID = 'PT_SESSION'
AND inv.TRANS_TIME BETWEEN :USAGE_FROM AND :USAGE_TO +86400000
AND invl.PRODUCTCENTER IN (:scope)
