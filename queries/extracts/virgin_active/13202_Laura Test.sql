WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$FromDate$$ AS FROMDATE,
            $$ToDate$$ + (1000*60*60*24) AS TODATE
        FROM
            dual
    )
SELECT
    sales.PERSON_CENTER || 'p' || sales.PERSON_ID Member_Id,
    p.EXTERNAL_ID External_ID,
    staff.FULLNAME EMPLOYEE,
    sales.PRODUCT_NAME,
    sales.PRODUCT_GROUP_NAME,
    TO_CHAR(longtodateC(act.TRANS_TIME, act.CENTER), 'YYYY-MM-DD') BOOK_DATE,
    sales.TEXT,
    debit.EXTERNAL_ID debit,
    act.AMOUNT,
    credit.EXTERNAL_ID credit,
    TO_CHAR(longtodateC(act.ENTRY_TIME, act.CENTER), 'YYYY-MM-DD HH24:MI') ENTRY_TIME,
    club.SHORTNAME club,
    act.CENTER || 'acc' || act.ID || 'tr' || act.SUBID Gl_trans_Id
FROM
    SALES_VW sales
CROSS JOIN
    PARAMS
JOIN
    CENTERS club
ON
    sales.CENTER = club.ID
JOIN
    ACCOUNT_TRANS act
ON
    act.CENTER = sales.ACCOUNT_TRANS_CENTER
    AND act.ID = sales.ACCOUNT_TRANS_ID
    AND act.SUBID = sales.ACCOUNT_TRANS_SUBID
JOIN
    ACCOUNTS debit
ON
    debit.CENTER = act.DEBIT_ACCOUNTCENTER
    AND debit.ID = act.DEBIT_ACCOUNTID
JOIN
    ACCOUNTS credit
ON
    credit.CENTER = act.CREDIT_ACCOUNTCENTER
    AND credit.ID = act.CREDIT_ACCOUNTID
LEFT JOIN
    PERSONS p
ON
    p.CENTER = sales.PERSON_CENTER
    AND p.ID = sales.PERSON_ID
LEFT JOIN
    EMPLOYEES emp
ON
    sales.EMPLOYEE_CENTER = emp.CENTER
    AND sales.EMPLOYEE_ID = emp.ID
LEFT JOIN
    PERSONS staff
ON
    emp.PERSONCENTER = staff.CENTER
    AND emp.PERSONID = staff.ID
WHERE
    sales.TRANS_TIME >= PARAMS.FROMDATE
    AND sales.TRANS_TIME < PARAMS.TODATE
    AND sales.ACCOUNT_TRANS_CENTER in ($$Scope$$)
    AND (
        debit.EXTERNAL_ID IN ('101313')
        OR credit.EXTERNAL_ID IN ('101313') )