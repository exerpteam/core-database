-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(exerpsysdate())-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(exerpsysdate()+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                  AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,
    (
        SELECT
            pr.center||'pr'||pr.id||'id'||                                                                                                                                                                                                        pr.SUBID,
            cp.EXTERNAL_ID                                                                                                                                                                                                        AS "PERSON_ID",
            DECODE(pr.REQUEST_TYPE,1,'PAYMENT',6,'REPRESENTATION',8,'ZERO','UNDEFINED')                                                                                                                                                                                                        AS REQUEST_TYPE,
            UPPER(DECODE(pr.state,1, 'New',2, 'Sent',3, 'Done',4, 'Done, manual',5, 'Rejected, clearinghouse',6, 'Rejected, bank',7, 'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',12, 'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed', 17, 'Failed, payment revoked', 18, 'Done Partial', 19, 'Failed, Unsupported', 20, 'Require approval', 21,'Fail, debt case exists', 22,' Failed, timed out','UNDEFINED')) AS state,
            pr.REQ_AMOUNT                                                                                                                                                                                                        AS "REQ_AMOUNT",
            TO_CHAR(pr.DUE_DATE,'yyyy-MM-dd')                                                                                                                                                                                                        AS "DUE_DATE",
            TO_CHAR( pr.XFR_DATE ,'yyyy-MM-dd')                                                                                                                                                                                                        AS "RECEIVED_DATE",
            pr.XFR_AMOUNT                                                                                                                                                                                                        AS "RECEIVED_AMOUNT",
            pr.INV_COLL_CENTER||'pr'||pr.INV_COLL_ID||'id'|| pr.INV_COLL_SUBID                                                                                                                                                                                                        AS "SPEC_ID",
            prs.CANCELLED                                                                                                                                                                                                        AS "SPEC_CANCELLED",
            pr.LAST_MODIFIED                                                                                                                                                                                                        AS "ETS"
        FROM
            PAYMENT_REQUESTS pr
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.center = pr.center
            AND ar.id = pr.id
            AND ar.AR_TYPE = 4
        JOIN
            PERSONS p
        ON
            p.CENTER = ar.CUSTOMERCENTER
            AND p.id = ar.CUSTOMERID
        JOIN
            PERSONS cp
        ON
            cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
            AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
        JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.center = pr.INV_COLL_CENTER
            AND prs.id = pr.INV_COLL_ID
            AND prs.SUBID = pr.INV_COLL_SUBID) biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE