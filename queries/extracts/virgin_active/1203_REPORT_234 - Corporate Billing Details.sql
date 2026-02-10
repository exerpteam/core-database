-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    company.CENTER || 'p' || company.ID companyId,
    company.LASTNAME companyName,
    TO_CHAR(longtodate(sales.TRANS_TIME), 'YYYY-MM-DD') book_date,
    TO_CHAR(longtodate(sales.ENTRY_TIME), 'YYYY-MM-DD') entry_date,
    sales.PRODUCT_NAME,
    sales.SALES_TYPE,
    sales.NET_AMOUNT,
    salesPerson.FULLNAME salesPerson,
    CASE
        WHEN person.center IS NOT NULL
            AND person.center <> company.center
            AND person.id <> company.id
        THEN person.CENTER || 'p' || person.ID
        ELSE NULL
    END member_Id,
    CASE
        WHEN person.center IS NOT NULL
            AND person.center <> company.center
            AND person.id <> company.id
        THEN person.FULLNAME
        ELSE NULL
    END member_name
FROM
    SALES_VW sales
JOIN
    PERSONS company
ON
    (
        company.CENTER = sales.PERSON_CENTER
        AND company.ID = sales.PERSON_ID)
    OR (
        company.CENTER = sales.PAYER_CENTER
        AND company.ID = sales.PAYER_ID )
JOIN
    PRODUCTS prod
ON
    sales.PRODUCT_CENTER = prod.CENTER
    AND sales.PRODUCT_ID = prod.ID
LEFT JOIN
    PERSONS person
ON
    person.CENTER = sales.PERSON_CENTER
    AND person.ID = sales.PERSON_ID
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = sales.EMPLOYEE_CENTER
    AND emp.ID = sales.EMPLOYEE_ID
LEFT JOIN
    PERSONS salesPerson
ON
    emp.PERSONCENTER = salesPerson.CENTER
    AND emp.PERSONID = salesPerson.ID
WHERE
    company.SEX = 'C'
    AND sales.TRANS_TIME > $$FromDate$$
    AND sales.TRANS_TIME <= $$ToDate$$ + (1000+60*60*24)
    AND sales.ENTRY_TIME <= $$ToDate$$ + (1000+60*60*24)
    AND company.CENTER || 'p' || company.ID = $$CompanyId$$
ORDER BY
    company.CENTER,
    company.ID,
    sales.TRANS_TIME
