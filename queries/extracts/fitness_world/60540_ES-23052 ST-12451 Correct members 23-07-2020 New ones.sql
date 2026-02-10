-- The extract is extracted from Exerp on 2026-02-08
-- These are correct members which have payment request specification not equal to request amount and linked to payment request created before 180 days.
SELECT
    ccrOuter.center,
    ccrOuter.id,
    ccrOuter.subid,
    ccOuter.PERSONCENTER || 'p' || ccOuter.PERSONID MEMEBR_ID
FROM
    cashcollection_requests ccrOuter
JOIN
    CASHCOLLECTIONCASES ccOuter
 ON
    ccrOuter.CENTER = ccOuter.CENTER
    AND ccrOuter.ID = ccOuter.ID
JOIN
    PERSONS p
 ON
    p.CENTER = ccOuter.PERSONCENTER
    AND p.ID = ccOuter.PERSONID
WHERE
    ccOuter.MISSINGPAYMENT = 1
    AND ccOuter.CLOSED = 0
    AND ccrOuter.REQ_DELIVERY IN ( 66207,
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
                                  66002 )
    AND p.status NOT IN (4,
                         5,
                         8,
                         9)
    /*BEGIN Only persons in files with a single case */
    AND (
        ccOuter.PERSONCENTER || 'p' || ccOuter.PERSONID ) IN
    (
        /* Only persons in files with a single case */
        /* Only persons in files with a single case */
     SELECT
            Member_ID
       FROM
            (
             SELECT
                    p.center || 'p' || p.id  AS Member_ID,
                    ccc.id || 'cc' || ccc.id    ccCaseId
               FROM
                    PERSONS p
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
                    ccc.MISSINGPAYMENT = 1
                    AND ccr.REQ_DELIVERY IN ( 66207,
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
                                             66002 )
           GROUP BY
                    p.center,
                    p.id,
                    ccc.id || 'cc' || ccc.id ) casesByPerson
   GROUP BY
            Member_ID
     HAVING
            COUNT(*) = 1 )
    /*END Only persons in files with a single case */
    /*BEGIN Only persons with negative balance on the debt account */
    AND (
        ccOuter.PERSONCENTER, ccOuter.PERSONID ) IN
    (
     SELECT
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID
       FROM
            ACCOUNT_RECEIVABLES ar
      WHERE
            ar.AR_TYPE = 5
            AND ar.Balance < 0 )
    /*END Only persons with negative balance on the debt account *
    /*BEGIN CC request amount must match open amount on linked PRS*/
    AND (
        ccOuter.PERSONCENTER, ccOuter.PERSONID ) NOT IN
    (
     SELECT
            ccInner.PERSONCENTER,
            ccInner.PERSONID
       FROM
            CASHCOLLECTIONCASES ccInner
       JOIN
            CASHCOLLECTION_REQUESTS ccrInner
         ON
            ccrInner.CENTER = ccInner.CENTER
            AND ccrInner.ID = ccInner.ID
       JOIN
            payment_request_specifications prs
         ON
            prs.center = ccrInner.prscenter
            AND prs.id = ccrInner.prsid
            AND prs.subid = ccrInner.prssubid
      WHERE
            ccInner.CENTER = ccOuter.CENTER
            AND ccInner.ID = ccOuter.ID
            AND (
                prs.open_amount != ccrInner.req_amount
                OR prs.ORIGINAL_DUE_DATE < ccrInner.REQ_DATE - 180))
/*END CC request amount must match open amount on linked PRS*/
