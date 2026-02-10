-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-5725
SELECT DISTINCT
    pr.full_reference                              AS "Payment Request Reference",
    pr.REQ_AMOUNT                                  AS "Requested amount",
    TO_CHAR(pr.REQ_DATE,'DD/MM/YYYY')              AS "Deduction Date",
    TO_CHAR(pr.DUE_DATE,'DD/MM/YYYY')              AS "Due date",
    p.center || 'p' || p.id                        AS "PersonID",
    DECODE(mpac.center,null,'',mpac.center || 'cc' || mpac.id)  AS "Missing Payment Agreement Case",
    TO_CHAR(longtodateC(mpac.start_datetime, mpac.center),'DD/MM/YYYY')   AS "Missing Paym. Agr. Start date",
    DECODE(mpac.closed,1,'Closed',0,'Active',null) AS "Missing Paym. Agr. Status",
    TO_CHAR(longtodateC(mpac.closed_datetime,mpac.center),'DD/MM/YYYY')  AS "Missing Paym. Agr. Stop date",
    pr.rejected_reason_code                       AS "Reject Reason Code",
    DECODE(dcc.closed,1,'Closed',0,'Active',null) AS "Debt Case Status",
    TO_CHAR(longtodateC(dcc.start_datetime, dcc.center),'DD/MM/YYYY')   AS "Debt Case Open Date"
FROM
    payment_request_specifications prs
JOIN
    payment_requests pr
ON
    pr.center = prs.center
    AND pr.ID = prs.ID
    AND pr.SUBID = prs.SUBID
JOIN
    account_receivables ar
ON
    ar.center = prs.center
    AND ar.id = prs.id
JOIN
    persons p
ON
    p.center = ar.customercenter
    AND p.id = ar.customerid
LEFT JOIN
    cashcollectioncases mpac
ON
    p.center = mpac.personcenter
    AND p.id = mpac.personid
    AND mpac.missingpayment = 0
    AND mpac.start_datetime >= dateToLongC(TO_CHAR($$Payment_Request_Date$$,'YYYY-MM-DD HH24:MI'),mpac.center)
LEFT JOIN
    cashcollectioncases dcc
ON
    p.center = dcc.personcenter
    AND p.id = dcc.personid
    AND dcc.missingpayment = 1
    AND dcc.start_datetime >= dateToLongC(TO_CHAR($$Payment_Request_Date$$,'YYYY-MM-DD HH24:MI'),dcc.center)
WHERE
   pr.req_date = $$Payment_Request_Date$$
   AND
   p.center IN ($$scope$$)
