WITH params AS
        (       
                SELECT 
                        /*+ materialize  */
                        dateToLongTZ(to_char(TRUNC(SYSDATE-7),'YYYY-MM-DD HH24:MI'),'Europe/London') AS fromDate,
                        dateToLongTZ(to_char(TRUNC(SYSDATE+31),'YYYY-MM-DD HH24:MI'),'Europe/London') AS toDate
                FROM DUAL 
        )
SELECT
    TO_CHAR(longtodateTZ(pr.ENTRY_TIME,'Europe/London'), 'YYYY-MM-DD') AS Request_Entry_Date
FROM
        PUREGYM.PERSONS p
CROSS JOIN params
JOIN
        PUREGYM.ACCOUNT_RECEIVABLES ar
ON
        ar.CUSTOMERCENTER = p.CENTER
        AND ar.CUSTOMERID = p.ID
        AND ar.AR_TYPE = 4
JOIN
        PUREGYM.PAYMENT_REQUESTS pr  
ON        
        ar.CENTER = pr.CENTER
        AND ar.ID = pr.ID
JOIN
        PUREGYM.PAYMENT_REQUEST_SPECIFICATIONS prs
ON
        prs.CENTER = pr.INV_COLL_CENTER
        AND prs.ID = pr.INV_COLL_ID
        AND prs.SUBID = pr.INV_COLL_SUBID
WHERE
    prs.ENTRY_TIME >= params.fromDate
    AND prs.ENTRY_TIME <= params.toDate
    AND pr.STATE IN (1,2)
    AND p.EXTERNAL_ID = $$member_external_id$$
AND pr.REQUEST_TYPE in (1,5,6)