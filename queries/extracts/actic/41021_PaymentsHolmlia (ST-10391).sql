-- The extract is extracted from Exerp on 2026-02-08
-- Extract to find Oslo Holmia revenue parts
SELECT
    p.CENTER||'p'||p.ID                                                                                                                                                                                                        AS "MemberId",
    s.center||'ss'||s.id                                                                                                                                                                                                        AS "SubscriptionId",
    pr.REQ_AMOUNT                                                                                                                                                                                                        AS "PaymentRequestAmount",
    SUM(spp.SUBSCRIPTION_PRICE)                                                                                                                                                                                                        AS "SubscriptionPeriodTotalPrice",
    s.START_DATE                                                                                                                                                                                                        AS "SubscriptionStartDate",
    s.END_DATE                                                                                                                                                                                                        AS "SubscriptionEndDate",
    pr.XFR_DATE                                                                                                                                                                                                        AS "PaidDate",
    prs.OPEN_AMOUNT                                                                                                                                                                                                        AS "PaymentRequestOpenAmount",
    spp.FROM_DATE                                                                                                                                                                                                        AS "SubscriptionPeriodStart",
    spp.to_DATE                                                                                                                                                                                                        AS "SubscriptionPeriodEnd",
    DECODE(pr.STATE,1,'New',2,'Sent',3,'Done',4,'Done, manual',5,'Rejected, clearinghouse',6,'Rejected, bank',7,'Rejected, debtor',8,'Cancelled',10,'Reversed, new',11,'Reversed, sent',12,'Failed, not creditor',13,'Reversed, rejected',14,'Reversed, confirmed',17,'Failed, payment revoked',18,'Done Partial',19,'Failed, Unsupported',20,'Require approval',21,'Fail, debt case exists',22,'Failed, timed out','Undefined') AS "PaymentRequestState"
FROM
    PAYMENT_REQUESTS pr
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pr.CENTER
    AND ar.ID = pr.ID
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
JOIN
    AR_TRANS art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
LEFT JOIN
    SPP_INVOICELINES_LINK sil
ON
    sil.INVOICELINE_CENTER = art.REF_CENTER
    AND sil.INVOICELINE_ID = art.REF_ID
    AND art.REF_TYPE = 'INVOICE'
JOIN
    SUBSCRIPTIONS s
ON
    s.CENTER= sil.PERIOD_CENTER
    AND s.ID = sil.PERIOD_ID
JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    sil.PERIOD_CENTER = spp.CENTER
    AND sil.PERIOD_ID = spp.id
    AND sil.PERIOD_SUBID = spp.SUBID
    AND spp.FROM_DATE <= $$to_date$$
    AND spp.TO_DATE >= $$from_date$$
WHERE
    pr.CENTER = $$center$$
    AND pr.DUE_DATE = $$due_date$$
    AND pr.REQ_AMOUNT != 0
GROUP BY
    p.CENTER||'p'||p.ID,
    s.center||'ss'||s.id,
    pr.REQ_AMOUNT ,
    s.START_DATE ,
    s.END_DATE,
    pr.XFR_DATE,
    prs.OPEN_AMOUNT,
    spp.FROM_DATE,
    spp.to_DATE,
    DECODE(pr.STATE,1,'New',2,'Sent',3,'Done',4,'Done, manual',5,'Rejected, clearinghouse',6,'Rejected, bank',7,'Rejected, debtor',8,'Cancelled',10,'Reversed, new',11,'Reversed, sent',12,'Failed, not creditor',13,'Reversed, rejected',14,'Reversed, confirmed',17,'Failed, payment revoked',18,'Done Partial',19,'Failed, Unsupported',20,'Require approval',21,'Fail, debt case exists',22,'Failed, timed out','Undefined')