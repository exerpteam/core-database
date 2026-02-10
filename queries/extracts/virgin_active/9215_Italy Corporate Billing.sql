-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    companyId,
    companyname,
    PRODUCT_NAME,
    SUM(net_amount)           total_amount,
    COUNT(DISTINCT member_id) members
FROM
    (
        SELECT
            company.CENTER || 'p' || company.ID                         companyId,
            company.LASTNAME                                            companyName,
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
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = company.CENTER
            AND ar.CUSTOMERID = company.ID
            AND ar.AR_TYPE = 4
        JOIN
            AR_TRANS art
        ON
            art.CENTER = ar.CENTER
            AND art.ID = ar.ID
            AND art.REF_TYPE = sales.SALES_TYPE
            AND art.REF_CENTER = sales.CENTER
            AND art.REF_ID = sales.ID
        WHERE
            company.SEX = 'C'
            AND company.CENTER IN ($$Scope$$)
            AND (
                art.DUE_DATE IS NOT NULL
                AND art.DUE_DATE BETWEEN $$FromDate$$ AND (CAST($$ToDate$$ AS DATE) + interval '1' day) )
        ORDER BY
            company.CENTER,
            company.ID,
            sales.TRANS_TIME) t
GROUP BY
    companyid, 
    companyname,
    PRODUCT_NAME