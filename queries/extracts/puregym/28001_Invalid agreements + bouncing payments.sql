-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    *
FROM
    (
        SELECT DISTINCT
            p.center ||'p'|| p.id                                                                                                                                                                                                        AS Member_ID ,
            p.fullname                                                                                                                                                                                                        AS Full_Name,
            DECODE (p.persontype, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown')                                                                                                                                                                               AS Person_Type ,
            DECODE (p.status, 0,'Lead', 1,'Active', 2,'Inactive', 3,'Temporary Inactive', 4,'Transfered', 5,'Duplicate', 6,'Prospect', 7,'Deleted',8, 'Anonymized', 9, 'Contact', 'Unknown')                                                                                                                                                      AS Person_Status,
            pro2.NAME                                                                                                                                                                                                        AS Latest_Subscription,
            DECODE (s1.state, 2,'Active', 3,'Ended', 4,'Frozen', 7,'Window', 8,'Created','Unknown')                                                                                                                                                                                                        AS Subscription_State,
            DECODE (s1.SUB_STATE, 1,'None', 2,'Awaiting Activation', 3,'Upgraded', 4,'Downgraded', 5,'Extended', 6, 'Transferred',7,'Regretted',8,'Cancelled',9,'Blocked','Unknown')                                                                                                                                                              AS Sub_State,
            DECODE(paz.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') AS Agreement_State,
            DECODE(pr.REQUEST_TYPE,1,'Payment',6,'Representation',8,'Zero','UNDEFINED')                                                                                                                                                                                                        AS PR_Request_Type,
            pr.req_amount                                                                                                                                                                                                        AS PR_Req_Amount,
            pr.DUE_DATE                                                                                                                                                                                                        AS PR_Due_Date,
            ar.BALANCE                                                                                                                                                                                                        AS Balance_on_Account,
            SUM(art.UNSETTLED_AMOUNT)                                                                                                                                                                                                        AS Overdue_Amount_on_Account
        FROM
            PERSONS p
        LEFT JOIN
            SUBSCRIPTIONS s1
        ON
            s1.OWNER_CENTER = p.CENTER
            AND s1.OWNER_ID = p.ID
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS s2
                WHERE
                    s1.OWNER_CENTER = s2.OWNER_CENTER
                    AND s1.OWNER_ID = s2.OWNER_ID
                    AND s1.CENTER = s2.CENTER
                    AND s2.id > s1.id)
        LEFT JOIN
            PUREGYM.PRODUCTS pro2
        ON
            s1.SUBSCRIPTIONTYPE_CENTER = pro2.CENTER
            AND s1.SUBSCRIPTIONTYPE_ID = pro2.id
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.center
            AND ar.CUSTOMERID = p.id
            AND ar.AR_TYPE = 4
        JOIN
            (
                SELECT
                    pa.CENTER     AS center,
                    pa.id         AS id,
                    MAX(pa.SUBID) AS subid,
                    pa.STATE      AS state
                FROM
                    PAYMENT_AGREEMENTS pa
                GROUP BY
                    pa.CENTER,
                    pa.id,
                    pa.STATE) paz
        ON
            ar.CENTER = paz.CENTER
            AND ar.ID = paz.ID
        JOIN
            PUREGYM.PAYMENT_REQUESTS pr
        ON
            pr.CENTER = ar.CENTER
            AND pr.ID = ar.ID
            AND pr.REQUEST_TYPE IN (1,6)
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PAYMENT_REQUESTS prx
                WHERE
                    prx.CENTER = pr.CENTER
                    AND prx.ID = pr.ID
                    AND prx.SUBID > pr.SUBID)
        LEFT JOIN
            AR_TRANS art
        ON
            art.center = ar.center
            AND art.id = ar.id
            AND art.DUE_DATE < SYSDATE
            AND (
                art.UNSETTLED_AMOUNT IS NOT NULL
                OR art.UNSETTLED_AMOUNT != 0)
        WHERE
            1=1
            AND paz.STATE NOT IN (1,2,4,13,15)
            AND pr.state = 12
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    persons p1,
                    PAYMENT_AGREEMENTS pal
                WHERE
                    p.CENTER = p1.CENTER
                    AND p.id = p1.id
                    AND pal.CENTER = paz.CENTER
                    AND pal.ID = paz.id
                    AND pal.SUBID = paz.subid
                    AND p1.STATUS = 1
                    AND pal.STATE =7)
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS s,
                    PRODUCTS pro
                WHERE
                    s.OWNER_CENTER = p.CENTER
                    AND s.OWNER_ID = p.ID
                    AND s.SUBSCRIPTIONTYPE_CENTER = pro.CENTER
                    AND s.SUBSCRIPTIONTYPE_ID = pro.ID
                    AND pro.GLOBALID LIKE '%GYMFLEX%')
            --AND pr.state NOT IN (1,2,4,13,15)
        GROUP BY
            p.center ||'p'|| p.id,
            p.fullname,
            p.persontype,
            p.status,
            pro2.NAME,
            s1.state,
            s1.SUB_STATE,
            paz.STATE,
            pr.REQUEST_TYPE,
            pr.req_amount,
            pr.DUE_DATE,
            ar.BALANCE )
WHERE
    Overdue_Amount_on_Account < 0
    OR Balance_on_Account < 0