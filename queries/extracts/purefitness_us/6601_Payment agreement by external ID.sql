-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    "Member ID",
    "External ID",
    "Member Name",
    "Deduction Day",
    "Agreement State"
FROM
    (
        SELECT DISTINCT
            p.center||'p'||p.id                 AS "Member ID",
            p.center,
            p.external_id						AS "External ID",
            p.fullname                          AS "Member Name",
            pag.INDIVIDUAL_DEDUCTION_DAY        AS "Deduction Day",
            CASE pag.state
                WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed'
                WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house'
                WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent'
                WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor'
                WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)'
                WHEN 13 THEN 'Agreement not needed (invoice payment)'
                WHEN 14 THEN 'Agreement information incomplete'
                WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated'
                WHEN 17 THEN 'Signature missing'
                ELSE 'UNDEFINED'
            END                                 AS "Agreement State"
        FROM
            PERSONS p
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.center
            AND ar.CUSTOMERID = p.id
        JOIN
            PAYMENT_ACCOUNTS pa
        ON
            pa.center = ar.center
            AND pa.id = ar.id
        JOIN
            PAYMENT_AGREEMENTS pag
        ON
            pag.CENTER = pa.ACTIVE_AGR_center
            AND pag.ID = pa.ACTIVE_AGR_id
        WHERE
            p.center IN (:center)
            AND p.external_id IN (:externalid)
        GROUP BY
            p.center,
            p.id,
            pag.INDIVIDUAL_DEDUCTION_DAY,
            pag.state) dat