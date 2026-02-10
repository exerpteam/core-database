-- The extract is extracted from Exerp on 2026-02-08
-- ES-23052 incorrect members
Count is not equal to 1
SELECT
    Person_External_ID,
    Member_ID,
    ar.BALANCE,
    COUNT(*),
    SUM(REQ_AMOUNT)
FROM
    (
        SELECT
            p.EXTERNAL_ID                  Person_External_ID,
            p.center||'p'||p.id            AS Member_ID,
            (ccc.center || 'cc' || ccc.id)    cc_case,
            COUNT(*)                          requests,
            sum(ccr.REQ_AMOUNT) REQ_AMOUNT
            --    ccr.REQ_DELIVERY        Payment_File_ID,
            --    ar.BALANCE              Debt_Account_Balance,
            --    -SUM(ccr.REQ_AMOUNT)    total_debt_requested
        FROM
            PERSONS p
        JOIN
            PERSONS pt
        ON
            pt.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER
        AND pt.TRANSFERS_CURRENT_PRS_ID = p.ID
        JOIN
            CASHCOLLECTIONCASES ccc
        ON
            pt.CENTER = ccc.PERSONCENTER
        AND pt.ID = ccc.PERSONID
        JOIN
            CASHCOLLECTION_REQUESTS ccr
        ON
            ccr.CENTER = ccc.CENTER
        AND ccr.ID = ccc.ID

        WHERE
            -- p.center = 159 AND p.id = 126700 AND
            --    ccc.STARTDATE >= to_date('2020-03-01','YYYY-MM-DD')
            --AND ccr.REQ_DATE >= to_date('2020-03-01','YYYY-MM-DD')
            --ccr.state = 1 --SENT
            ccr.REQ_DELIVERY IN (66207,
65811,
65812,
65604,
65808,
66205,
65810,
65807,
66402,
65809,
66206,
66005,
65603,
65803,
66202,
66203,
65806,
66401,
65805,
65804,
65802,
66204,
66002)
        GROUP BY
            p.EXTERNAL_ID,
            p.center,
            p.id,
            ccc.center,
            ccc.id )
          LEFT JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID = Member_ID

        AND ar.AR_TYPE = 5
GROUP BY
    Person_External_ID,
    Member_ID, ar.BALANCE
       having count(*) <>1

