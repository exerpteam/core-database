SELECT DISTINCT
ON
    (
        prs.center, prs.id, prs.subid) prs.center || 'ar' || prs.id || 'sp' || prs.subid AS "ID",
    CASE
        WHEN P.SEX != 'C'
        THEN
            CASE
                WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                        OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                            AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END
        ELSE NULL
    END AS "PERSON_ID",
    CASE
        WHEN P.SEX = 'C'
        THEN
            CASE
                WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                        OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                            AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END
        ELSE NULL
    END AS "COMPANY_ID",
    pr.center||'ar'||pr.id||'agr'||pr.AGR_SUBID  AS "PAYMENT_AGREEMENT_ID",
	prs.entry_time                      AS "CREATION_DATETIME",
    prs.paid_state_last_entry_time      AS "LAST_PAYMENT_DATETIME",
    prs.requested_amount                AS "REQUESTED_AMOUNT",
    prs.collection_fee                  AS "COLLECTION_FEE_AMOUNT",
    prs.rejection_fee                   AS "REJECTION_FEE_AMOUNT",
    prs.total_invoice_amount            AS "TOTAL_INVOICE_AMOUNT",
    prs.open_amount                     AS "OPEN_AMOUNT",
    prs.paid_state                      AS "PAYMENT_STATE",
    prs.center                          AS "CENTER_ID",
    prs.last_modified                   AS "ETS"
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    PAYMENT_REQUESTS pr
ON
    prs.center = pr.inv_coll_center
    AND prs.id = pr.inv_coll_id   
    AND prs.subid = pr.inv_coll_subid   
JOIN 
   ACCOUNT_RECEIVABLES ar
ON 
   pr.CENTER = ar.CENTER
   AND pr.ID = ar.ID
   AND ar.ar_type = 4   
JOIN
   PERSONS p
ON
   p.CENTER = ar.customercenter
   AND  p.ID = ar.customerid
WHERE
  order by prs.center, prs.id, prs.subid, pr.entry_time desc