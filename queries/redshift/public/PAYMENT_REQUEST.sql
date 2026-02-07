SELECT
    pr.center||'ar'||pr.id||'req'||pr.SUBID AS "ID",
    pr.inv_coll_center || 'ar' || pr.inv_coll_id || 'sp' || pr.inv_coll_subid   AS "PAYMENT_REQUEST_SPEC_ID",
    pr.center||'ar'||pr.id||'agr'||pr.AGR_SUBID                                 AS "PAYMENT_AGREEMENT_ID",
    CASE PR.STATE
        WHEN 1 THEN 'NEW'
        WHEN 2 THEN 'SENT'
        WHEN 3 THEN 'DONE'
        WHEN 4 THEN 'DONE, MANUAL'
        WHEN 5 THEN 'REJECTED, CLEARINGHOUSE'
        WHEN 6 THEN 'REJECTED, BANK'
        WHEN 7 THEN 'REJECTED, DEBTOR'
        WHEN 8 THEN 'CANCELLED'
        WHEN 10 THEN 'REVERSED, NEW'
        WHEN 11 THEN 'REVERSED , SENT'
        WHEN 12 THEN 'FAILED, NOT CREDITOR'
        WHEN 13 THEN 'REVERSED, REJECTED'
        WHEN 14 THEN 'REVERSED, CONFIRMED'
        WHEN 17 THEN 'FAILED, PAYMENT REVOKED'
        WHEN 18 THEN 'DONE PARTIAL'
        WHEN 19 THEN 'FAILED, UNSUPPORTED'
        WHEN 20 THEN 'REQUIRE APPROVAL'
        WHEN 21 THEN 'FAIL, DEBT CASE EXISTS'
        WHEN 22 THEN 'FAILED, TIMED OUT'
        ELSE 'UNDEFINED'
    END AS "STATE",
    CASE 
        WHEN PR.STATE  IN (1,20) THEN 'NEW'
        WHEN PR.STATE  = 2 THEN 'SENT'
        WHEN PR.STATE IN (3,4) THEN 'PAID'
        WHEN PR.STATE IN (5,6,7,10,12,17,19,21,22) THEN 'FAILED'
        WHEN PR.STATE = 8 THEN 'CANCELLED'
        WHEN PR.STATE = 18 THEN 'PARTIAL'
        ELSE 'UNDEFINED'
    END AS "STATE_CATEGORY",
    CASE REQUEST_TYPE
        WHEN 1 THEN 'PAYMENT'
        WHEN 2 THEN 'DEBT COLLECTION'
        WHEN 3 THEN 'REVERSAL'
        WHEN 4 THEN 'REMINDER'
        WHEN 5 THEN 'REFUND'
        WHEN 6 THEN 'REPRESENTATION'
        WHEN 7 THEN 'LEGACY'
        WHEN 8 THEN 'ZERO'
        WHEN 9 THEN 'SERVICE CHARGE'
        ELSE 'UNDEFINED'
    END                         AS "REQUEST_TYPE",
    pr.creditor_id              AS "CREDITOR_ID",
    pr.entry_time               AS "CREATION_DATETIME",
    pr.req_date                 AS "REQUESTED_DATE",
    pr.req_amount               AS "REQUESTED_AMOUNT",
    pr.due_date                 AS "DUE_DATE",
    pr.center                   AS "CENTER_ID",
    pr.xfr_amount               AS "XFR_AMOUNT",
    pr.xfr_date                 AS "XFR_DATE",
    pr.xfr_delivery             AS "XFR_DELIVERY",
    pr.xfr_info                 AS "XFR_INFO",
    pr.last_modified            AS "ETS",
    pr.rejected_reason_code     AS "REJECTED_REASON_CODE",
    pr.clearinghouse_id         AS "CLEARINGHOUSE_ID"
FROM
    PAYMENT_REQUESTS pr
   