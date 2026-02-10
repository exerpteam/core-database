-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     PRS.REF                                            AS "Invoice Id.",
     AR.CUSTOMERCENTER || 'p' || AR.CUSTOMERID          AS "Customer Id.",
     PE.FULLNAME                       AS "Name",
     CASE 
       WHEN PAR.STATE = 1 THEN 'PS_NEW' 
       WHEN PAR.STATE = 2 THEN 'PS_SENT' 
       WHEN PAR.STATE = 3 THEN 'PS_DONE' 
       WHEN PAR.STATE = 4 THEN 'PS_DONE_MANUAL' 
       WHEN PAR.STATE = 5 THEN 'PS_REJECTED_BY_CLEARINGHOUSE' 
       WHEN PAR.STATE = 6 THEN 'PS_REJECTED_BY_BANK' 
       WHEN PAR.STATE = 7 THEN 'PS_REJECTED_BY_DEBITOR' 
       WHEN PAR.STATE = 8 THEN 'PS_CANCELLED' 
       WHEN PAR.STATE = 12 THEN 'PS_FAIL_NO_CREDITOR' 
       WHEN PAR.STATE = 17 THEN 'PS_FAIL_REJ_DEB_REVOKED' 
       WHEN PAR.STATE = 18 THEN 'PS_DONE_PARTIAL' 
       WHEN PAR.STATE = 19 THEN 'PS_FAIL_UNSUPPORTED' 
       WHEN PAR.STATE = 20 THEN 'PS_REQUIRE_APPROVAL' 
       WHEN PAR.STATE = 21 THEN 'PS_FAIL_DEBT_CASE_EXISTS' 
       WHEN PAR.STATE = 22 THEN 'PS_FAIL_TIMED_OUT' 
       ELSE 'UNDEFINED'
     END AS "State",       
     PAR.REQ_AMOUNT                    AS "Req. Amount",
     CASE
         WHEN PAR.REQUEST_TYPE=5 THEN
                 PAR.REQ_AMOUNT*(-1)
         ELSE
                 PAR.REQ_AMOUNT
     END as "Req. Amount",
     COALESCE(PAR.XFR_AMOUNT,0)        AS "Paid amount",
     PRS.OPEN_AMOUNT                   AS "Open Amount",
     PAR.REQ_DATE                      AS "Deduction day",
     PAR.DUE_DATE                      AS "Due date",
     PAR.XFR_DATE                      AS "Paid",
     AR.CENTER || 'ar' || AR.ID        AS "Account Rec.",
     PAR.REQ_DELIVERY                  AS "Sent File",
     PAR.XFR_DELIVERY                  AS "Received File",
     COALESCE(IL1.TOTAL_AMOUNT,0)      AS "Collection fee",
     COALESCE(IL2.TOTAL_AMOUNT,0)      AS "Rejection fee",
     PAR.REJECTED_REASON_CODE          AS "Rejected reason code",
     PAR.XFR_INFO                      AS "Info"
 FROM
     PAYMENT_REQUESTS PAR
 INNER JOIN
     PAYMENT_REQUEST_SPECIFICATIONS PRS
 ON
     (
         PAR.INV_COLL_CENTER = PRS.CENTER
     AND PAR.INV_COLL_ID = PRS.ID
     AND PAR.INV_COLL_SUBID = PRS.SUBID)
 INNER JOIN
     ACCOUNT_RECEIVABLES AR
 ON
     (
         PRS.CENTER = AR.CENTER
     AND PRS.ID = AR.ID)
 INNER JOIN
     PERSONS PE
 ON
     (
         AR.CUSTOMERCENTER = PE.CENTER
     AND AR.CUSTOMERID = PE.ID)
 LEFT JOIN
     INVOICELINES IL1
 ON
     (
         PAR.COLL_FEE_INVLINE_CENTER = IL1.CENTER
     AND PAR.COLL_FEE_INVLINE_ID = IL1.ID
     AND PAR.COLL_FEE_INVLINE_SUBID = IL1.SUBID)
 LEFT JOIN
     INVOICELINES IL2
 ON
     (
         PAR.REJECT_FEE_INVLINE_CENTER = IL2.CENTER
     AND PAR.REJECT_FEE_INVLINE_ID = IL2.ID
     AND PAR.REJECT_FEE_INVLINE_SUBID = IL2.SUBID)
 WHERE
     PAR.CENTER IN (:Scope)
     AND PAR.CLEARINGHOUSE_ID in (:ClearingHouse)
     AND PAR.REQUEST_TYPE in (:RequestType)
         --AND PAR.REQ_AMOUNT >= 10
     --AND PAR.REQ_AMOUNT <= 100
     AND (
     (:State=1 AND PAR.STATE IN (1)) OR (:State=20 AND PAR.STATE IN (20)) OR (:State=2 AND PAR.STATE IN (2)) OR (:State=18 AND PAR.STATE IN (18)) OR (:State=3 AND PAR.STATE IN (3,4))
     OR (:State=8 AND PAR.STATE IN (8)) OR (:State=17 AND PAR.STATE IN (17,7,6,5)) OR (:State=12 AND PAR.STATE IN (12,21,22)) OR (:State=10 AND PAR.STATE IN (1,2,3,4,5,6,7,8,12,17,18,19,20,21,22))
     )
     AND PAR.REQ_DATE >= :fromDate
     AND PAR.REQ_DATE <= :toDate
