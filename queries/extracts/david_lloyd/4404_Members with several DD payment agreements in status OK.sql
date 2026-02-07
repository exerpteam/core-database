-- This is the version from 2026-02-05
--  
WITH clearinghouses_filtered AS (
    SELECT
        cl.id
    FROM clearinghouses AS cl
    WHERE cl.ctype IN (
        1, 2, 4, 64, 130, 137, 140, 143, 145, 146, 148, 150, 152, 153,
        155, 156, 157, 158, 159, 165, 167, 168, 172, 176, 177, 178, 179,
        180, 181, 182, 185, 187, 189, 191, 192
    )
),
multiple_agreements AS (
    SELECT
        p.center || 'p' || p.id AS member_id,
        p.external_id          AS external_id,
        COUNT(*)               AS agreement_count
    FROM payment_agreements AS pag
    JOIN account_receivables AS ar
        ON pag.center = ar.center
       AND pag.id     = ar.id
    JOIN persons AS p
        ON ar.customercenter = p.center
       AND ar.customerid     = p.id
    JOIN clearinghouses_filtered AS cf
        ON cf.id = pag.clearinghouse
    WHERE pag.state  = 4
      AND pag.active = 'true'   
    GROUP BY
        p.center,
        p.id
    HAVING COUNT(*) > 1
)
SELECT
    m.member_id,
    m.external_id
FROM multiple_agreements AS m;