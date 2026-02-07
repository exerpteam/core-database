-- This is the version from 2026-02-05
-- test
SELECT DISTINCT
        t2.Center AS "Center",
        t2.AccountType AS "Account type",
        t2.NotDueSum AS "Debt not overdue",
        t2.Due30Sum AS "Due 30",
        t2.Due60Sum AS "Due 60",
        t2.Due90Sum AS "Due 90",
        t2.Due120Sum AS "Due 120",
        t2.DuePlus120Sum AS "Due + 120",
        t2.TotalDebtSum AS "TotalDebt",
        t2.Balance AS "Positive balance",
        t2.AccountBalance AS "Total",
        t2.PersonType AS "DebtorType",
        t2.PersonId AS "PersonId",
        t2.FullName AS "PersonName",
        t2.Status AS "Status",    
        (CASE 
                WHEN r.CENTER IS NOT NULL THEN 'YES'
                ELSE 'NO'
        END) AS "Pay others?",
        exerpro.longtodate(MAX(CHECKIN_TIME)) AS "Check in",
		MAX(S.END_DATE) AS "SubscriptionEndDate"
FROM
(
        SELECT
                t1.Center,
                t1.Id,
                t1.AccountType,
                SUM(t1.NotDue) AS NotDueSum,
                SUM(t1.Due30) AS Due30Sum,
                SUM(t1.Due60) AS Due60Sum,
                SUM(t1.Due90) AS Due90Sum,
                SUM(t1.Due120) AS Due120Sum,
                SUM(t1.DuePlus120) AS DuePlus120Sum,
                SUM(t1.TotalDebt) AS TotalDebtSum,
                t1.Balance,
                t1.AccountBalance,
                t1.PersonType,
                t1.PersonId,
                t1.FullName,
                t1.Status
        FROM
        (
                SELECT
                        cp.center AS Center,
                        cp.id AS Id,
                        (CASE
                                WHEN ar.AR_TYPE = 1 THEN 'CASH'
                                WHEN ar.AR_TYPE = 4 THEN 'PAYMENT'
                                WHEN ar.AR_TYPE = 5 THEN 'DEBT'
                                WHEN ar.AR_TYPE = 6 THEN 'INSTALLMENT'
                        END) AS AccountType,
                        (CASE 
                                WHEN art.AMOUNT > 0 THEN 0
                                WHEN art.DUE_DATE IS NULL OR art.DUE_DATE > exerpsysdate()
                                THEN art.AMOUNT
                                ELSE 0
                        END) AS NotDue,
                        (CASE
                                WHEN art.AMOUNT > 0 THEN 0
                                WHEN art.DUE_DATE < exerpsysdate() AND art.DUE_DATE > exerpsysdate()-30
                                THEN art.AMOUNT
                                ELSE 0
                        END) AS Due30,
                        (CASE
                                WHEN art.AMOUNT > 0 THEN 0
                                WHEN art.DUE_DATE < exerpsysdate()-30 AND art.DUE_DATE > exerpsysdate()-60
                                THEN art.AMOUNT
                                ELSE 0
                        END) AS Due60,
                        (CASE
                                WHEN art.AMOUNT > 0 THEN 0
                                WHEN art.DUE_DATE < exerpsysdate()-60 AND art.DUE_DATE > exerpsysdate()-90
                                THEN art.AMOUNT
                                ELSE 0
                        END) AS Due90,
                        (CASE
                                WHEN art.AMOUNT > 0 THEN 0
                                WHEN art.DUE_DATE < exerpsysdate()-90 AND art.DUE_DATE > exerpsysdate()-120
                                THEN art.AMOUNT
                                ELSE 0
                        END) AS Due120,
                        (CASE
                                
                                WHEN art.DUE_DATE < exerpsysdate()-120
                                THEN art.AMOUNT
                                ELSE 0
                        END) AS DuePlus120,
                        (CASE
                                WHEN ar.AR_TYPE = 4 AND ar.BALANCE > 0 THEN ar.BALANCE
                                ELSE 0
                        END) AS Balance,               
                        ar.Balance AS AccountBalance,
                        DECODE(cp.persontype, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS PersonType,              
                        cp.center || 'p' || cp.id AS PersonId,
                        cp.FULLNAME AS FullName,
                        DECODE(cp.status, 0,'Lead', 1,'Active', 2,'Inactive', 3,'Temporary Inactive', 4,'Transfered', 5,'Duplicate', 6,'Prospect', 7,'Deleted',8, 'Anonymized', 9, 'Contact', 'Unknown') AS Status,
                        (CASE
                                WHEN art.AMOUNT>0 THEN 0
                                ELSE art.AMOUNT
                        END) AS TotalDebt
                FROM
                        AR_TRANS art
                LEFT JOIN
                        ACCOUNT_RECEIVABLES ar
                ON
                        ar.center = art.center
                        AND ar.id = art.id
                LEFT JOIN
                        ACCOUNTS ac
                ON
                        ac.center = ar.ASSET_ACCOUNTCENTER
                        AND ac.id = ar.ASSET_ACCOUNTID
                LEFT JOIN
                        PERSONS p
                ON
                        p.center = ar.CUSTOMERCENTER
                        AND p.id = ar.CUSTOMERID
                LEFT JOIN
                        PERSONS cp
                ON
                        cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
                        AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
                WHERE
                        art.STATUS IN ('OPEN','NEW')
                        AND art.AMOUNT <> 0 
                        AND art.center IN (:Scope)
        ) t1
        GROUP BY
                t1.Center,
                t1.Id,
                t1.AccountType,
                t1.Balance,
                t1.AccountBalance,
                t1.PersonType,
                t1.PersonId,
                t1.FullName,
                t1.Status
 ) t2
JOIN PERSONS curr_p 
        ON curr_p.CURRENT_PERSON_CENTER = t2.CENTER and curr_p.CURRENT_PERSON_ID = t2.ID
LEFT JOIN SUBSCRIPTIONS S
		ON t2.CENTER = S.OWNER_CENTER AND t2.ID = S.OWNER_ID
LEFT JOIN FW.CHECKINS ch
        ON ch.PERSON_CENTER = curr_p.center AND ch.PERSON_ID = curr_p.id
LEFT JOIN FW.RELATIVES r
        ON t2.center = r.center AND t2.id = r.id AND r.RTYPE = 12 AND r.STATUS = 1
WHERE t2.STATUS not in ('Active', 'Temporary Inactive')
AND t2.AccountBalance > 0
GROUP BY
        t2.Center,
        t2.AccountType,
        t2.NotDueSum,
        t2.Due30Sum,
        t2.Due60Sum,
        t2.Due90Sum,
        t2.Due120Sum,
        t2.DuePlus120Sum,
        t2.TotalDebtSum,
        t2.Balance,
        t2.AccountBalance,
        t2.PersonType,
        t2.PersonId,
        t2.FullName,
        t2.Status,
        r.center 
        