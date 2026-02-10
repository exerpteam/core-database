-- The extract is extracted from Exerp on 2026-02-08
-- All members in the file with Next debt step date
SELECT
    Person_External_ID,
    Member_ID,
    STATUS,
    ar.BALANCE,
    ccp.CLOSED,
    ccp.NEXTSTEP_DATE,
    ccp.NEXTSTEP_TYPE,
    COUNT(*),
    --SUM(REQ_AMOUNT)
DECODE(STATUS,0,'LEAD',1,'ACTIVE',2,'INACTIVE',3,'TEMPORARYINACTIVE',4,'TRANSFERRED',5,'DUPLICATE',6,'PROSPECT',7,'DELETED',8,'ANONYMIZED',9,'CONTACT','Undefined') AS STATUS 
FROM
    (
        SELECT
            p.EXTERNAL_ID                  Person_External_ID,
            p.center||'p'||p.id            AS Member_ID,
            p.STATUS                          status,
            (ccc.center || 'cc' || ccc.id)    cc_case,
            COUNT(*)                          requests,
            SUM(ccr.REQ_AMOUNT)               REQ_AMOUNT
            --    ccr.REQ_DELIVERY        Payment_File_ID,
            --    ar.BALANCE              Debt_Account_Balance,
            --    -SUM(ccr.REQ_AMOUNT)    total_debt_requested
        FROM
            FW.PERSONS p
            /*        JOIN
            PERSONS pt
            ON
            pt.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER
            AND pt.TRANSFERS_CURRENT_PRS_ID = p.ID
            */
        JOIN
            CASHCOLLECTIONCASES ccc
        ON
            p.CENTER = ccc.PERSONCENTER
        AND p.ID = ccc.PERSONID
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
            ccc.MISSINGPAYMENT = 1
            --            AND ccc.CLOSED = 0
            /*AND ccr.REQ_DELIVERY IN (66002)*/
        AND ccr.REQ_DELIVERY IN (66207,
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
            p.STATUS,
            ccc.center,
            ccc.id )
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID = Member_ID
AND ar.AR_TYPE = 5
LEFT JOIN
    FW.CASHCOLLECTIONCASES ccp
ON
    ccp.PERSONCENTER || 'p' || ccp.PERSONID = Member_ID
AND ccp.MISSINGPAYMENT = 1
AND ccp.CLOSED = 0
GROUP BY
    Person_External_ID,
    Member_ID,
    STATUS,
    ccp.CLOSED,
    ccp.NEXTSTEP_DATE,
    ccp.NEXTSTEP_TYPE,
    ar.BALANCE
    HAVING ar.balance < 0