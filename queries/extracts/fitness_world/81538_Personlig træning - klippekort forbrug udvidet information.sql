-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    c.OWNER_CENTER ||'p'|| c.OWNER_ID AS MedlemsId,
    curr_p.FULLNAME AS Medlemsnavn,

    CASE
        WHEN curr_p.SEX = 'M' THEN 'Mand'
        WHEN curr_p.SEX = 'F' THEN 'Kvinde'
        ELSE 'Ukendt'
    END AS Køn,

    floor(months_between(current_timestamp, curr_p.birthdate) / 12) AS Alder,
    TO_CHAR(longtodate(cu.TIME), 'dd-MM-YYYY HH24:MI') AS Benyttelsestid,
    cu.CLIPS AS "ANTAL BRUGTE KLIP",
    cu.DESCRIPTION AS Beskrivelse,
    pu.TARGET_CENTER AS Benyttelsescenter,
    cen.NAME AS "BENYTTELSESCENTER NAVN",

    CASE
        WHEN cu.EMPLOYEE_CENTER IS NULL
        THEN NULL
        ELSE cu.EMPLOYEE_CENTER || 'emp' || cu.EMPLOYEE_ID
    END AS PERSONALEID,

    pemp.FIRSTNAME || ' ' || pemp.LASTNAME AS PERSONALE_NAVN,
    pemp.SSN AS PERSONALE_SSN,

    pr.NAME AS "KLIPPEKORT NAVN",
    c.CENTER || 'cc' || c.ID || 'sub' || c.SUBID AS "KLIPPEKORT ID",
    pr.PRICE AS "NORMAL PRIS",
    invl.TOTAL_AMOUNT AS "SALGS PRIS",
    c.CLIPS_INITIAL AS "INDLEDENDE ANTAL KLIP",
    c.CLIPS_LEFT AS "RESTERENDE ANTAL KLIP"

FROM CLIPCARDS c
JOIN CARD_CLIP_USAGES cu
    ON cu.CARD_CENTER = c.CENTER
   AND cu.CARD_ID = c.ID
   AND cu.CARD_SUBID = c.SUBID
   AND (
        cu.DESCRIPTION LIKE 'Personlig træning%'
        OR cu.DESCRIPTION LIKE 'Personlig Træning%'
        OR cu.DESCRIPTION LIKE 'Personlig træner%'
        OR cu.DESCRIPTION LIKE '%PT-competition%'
       )
   AND cu.DESCRIPTION NOT LIKE '%uddannelse%'

JOIN PRIVILEGE_USAGES pu
    ON pu.ID = cu.REF

JOIN CENTERS cen
    ON cen.ID = pu.TARGET_CENTER

JOIN PERSONS p
    ON p.CENTER = c.OWNER_CENTER
   AND p.ID = c.OWNER_ID

JOIN PERSONS curr_p
    ON curr_p.CENTER = p.CURRENT_PERSON_CENTER
   AND curr_p.ID = p.CURRENT_PERSON_ID

JOIN INVOICELINES invl
    ON invl.CENTER = c.INVOICELINE_CENTER
   AND invl.ID = c.INVOICELINE_ID
   AND invl.SUBID = c.INVOICELINE_SUBID

JOIN PRODUCTS pr
    ON pr.CENTER = invl.PRODUCTCENTER
   AND pr.ID = invl.PRODUCTID

LEFT JOIN EMPLOYEES emp
    ON emp.CENTER = cu.EMPLOYEE_CENTER
   AND emp.ID = cu.EMPLOYEE_ID

LEFT JOIN PERSONS pemp
    ON pemp.CENTER = emp.PERSONCENTER
   AND pemp.ID = emp.PERSONID

WHERE
    cu.TIME BETWEEN :USAGE_FROM AND :USAGE_TO + 86400000
    AND pu.TARGET_CENTER IN (:scope)

UNION

SELECT DISTINCT
    invl.PERSON_CENTER || 'p' || invl.PERSON_ID AS MedlemsId,
    curr_p2.FULLNAME AS Medlemsnavn,

    CASE
        WHEN curr_p2.SEX = 'M' THEN 'Mand'
        WHEN curr_p2.SEX = 'F' THEN 'Kvinde'
        ELSE 'Ukendt'
    END AS Køn,

    floor(months_between(current_timestamp, curr_p2.birthdate) / 12) AS Alder,
    TO_CHAR(longtodate(inv.TRANS_TIME),'DD-MM-YYYY HH24:MI') AS Benyttelsestid,
    NULL::int AS "ANTAL BRUGTE KLIP",
    inv.TEXT AS Beskrivelse,
    c.ID AS Benyttelsescenter,
    c.NAME AS "BENYTTELSESCENTER NAVN",

    CASE
        WHEN inv.EMPLOYEE_CENTER IS NULL
        THEN NULL
        ELSE inv.EMPLOYEE_CENTER || 'emp' || inv.EMPLOYEE_ID
    END AS PERSONALEID,

    pemp2.FIRSTNAME || ' ' || pemp2.LASTNAME AS PERSONALE_NAVN,
    pemp2.SSN AS PERSONALE_SSN,

    prod.NAME AS "KLIPPEKORT NAVN",
    NULL AS "KLIPPEKORT ID",
    prod.PRICE AS "NORMAL PRIS",
    invl.TOTAL_AMOUNT AS "SALGS PRIS",
    NULL::int AS "INDLEDENDE ANTAL KLIP",
    NULL::int AS "RESTERENDE ANTAL KLIP"

FROM INVOICELINES invl
JOIN INVOICES inv
    ON inv.CENTER = invl.CENTER
   AND inv.ID = invl.ID

JOIN PRODUCTS prod
    ON prod.CENTER = invl.PRODUCTCENTER
   AND prod.ID = invl.PRODUCTID

JOIN PERSONS p2
    ON invl.PERSON_CENTER = p2.CENTER
   AND invl.PERSON_ID = p2.ID

JOIN PERSONS curr_p2
    ON p2.CURRENT_PERSON_CENTER = curr_p2.CENTER
   AND p2.CURRENT_PERSON_ID = curr_p2.ID

JOIN ATTENDS a
    ON p2.CENTER = a.PERSON_CENTER
   AND p2.ID = a.PERSON_ID

JOIN CENTERS c
    ON c.ID = a.CENTER
   AND TO_CHAR(longtodate(a.START_TIME), 'DD-MM-YYYY') =
       TO_CHAR(longtodate(inv.TRANS_TIME), 'DD-MM-YYYY')

LEFT JOIN EMPLOYEES emp2
    ON emp2.CENTER = inv.EMPLOYEE_CENTER
   AND emp2.ID = inv.EMPLOYEE_ID

LEFT JOIN PERSONS pemp2
    ON pemp2.CENTER = emp2.PERSONCENTER
   AND pemp2.ID = emp2.PERSONID

WHERE
    prod.GLOBALID = 'PT_SESSION'
    AND inv.TRANS_TIME BETWEEN :USAGE_FROM AND :USAGE_TO + 86400000
    AND invl.PRODUCTCENTER IN (:scope);
