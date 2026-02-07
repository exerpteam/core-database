SELECT
    c.SHORTNAME club,
    p.CENTER || 'p' || p.ID person_Id,
    sales.PRODUCT_NAME,
    sales.PRODUCT_TYPE,
    sales.SALES_TYPE,
    TO_CHAR(longtodate(sales.ENTRY_TIME), 'YYYY-MM-DD HH24:MI') salesTime,
    prod.PRICE product_PRICE,
    comp.LASTNAME company,
    empName.FULLNAME salesPerson,
    ROUND(prod.PRICE, 2) remit_amount
FROM
    SALES_VW sales
LEFT JOIN
    persons p
ON
    p.CENTER = sales.PERSON_CENTER
    AND p.ID = sales.PERSON_ID
LEFT JOIN
    CENTERS c
ON
    c.ID = p.CENTER
LEFT JOIN
    RELATIVES comp_rel
ON
    comp_rel.center=p.center
    AND comp_rel.id=p.id
    AND comp_rel.RTYPE = 3
LEFT JOIN
    COMPANYAGREEMENTS cag
ON
    cag.center= comp_rel.RELATIVECENTER
    AND cag.id=comp_rel.RELATIVEID
    AND cag.subid = comp_rel.RELATIVESUBID
LEFT JOIN
    persons comp
ON
    comp.center = cag.center
    AND comp.id=cag.id
LEFT JOIN
    PRODUCTS prod
ON
    sales.PRODUCT_CENTER = prod.CENTER
    AND sales.PRODUCT_ID = prod.ID
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = sales.EMPLOYEE_CENTER
    AND emp.ID = sales.EMPLOYEE_ID
LEFT JOIN
    PERSONS empName
ON
    emp.PERSONCENTER = empName.CENTER
    AND emp.PERSONID = empName.ID
WHERE
    cag.CONTACTCENTER = 4
    AND cag.CONTACTID = 1105
    AND sales.ENTRY_TIME > $$FromDate$$
    AND sales.ENTRY_TIME <= $$ToDate$$ + (1000*60*60*24)
    AND sales.CENTER in ($$Scope$$)
    AND sales.EMPLOYEE_CENTER || 'emp' || sales.EMPLOYEE_ID <> '100emp1'
    AND EXISTS
    (
        SELECT
            *
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK pgl
        WHERE
            pgl.PRODUCT_CENTER = sales.PRODUCT_CENTER
            AND pgl.PRODUCT_ID = sales.PRODUCT_ID
            AND pgl.PRODUCT_GROUP_ID = 1401 )
