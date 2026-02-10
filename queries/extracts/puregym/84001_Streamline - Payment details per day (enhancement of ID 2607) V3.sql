-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-7575
WITH journalentries_filtered AS (
    SELECT
        je.person_center,
        je.person_id,
        je.creatorcenter,
        je.creatorid,
        je.big_text,
        je.creation_time,
        je.name
    FROM puregym.journalentries je
    WHERE
        je.name IN (
            'Payment',
            'Debts Payment Sage Pay',
            'Day Pass Purchase Sage Pay',
            'Pure Loser Purchase Sage Pay',
            'Join Payment Sage Pay',
            'Debt Payment Sage Pay',
            'Day-pass Payment Sage Pay',
            'Pureloser Payment Sage Pay',
            'Course Payment Sage Pay',
            'Gift Voucher Purchase Sage Pay',
            'Debt Payment',
            'Day Pass Purchase',
            'Pure Loser Purchase',
            'Join Payment',
            'Day-pass Payment',
            'Pureloser Payment',
            'Course Payment',
            'Gift Voucher Purchase',
            'Paid Class'
        )
        OR je.name LIKE '%Course Purchase%'
),


journalentries_deduplicates AS (
    SELECT
        jf.*,
        ROW_NUMBER() OVER (
            PARTITION BY jf.person_center,
                         jf.person_id,
                         jf.creatorcenter,
                         jf.creatorid,
                         jf.big_text
            ORDER BY jf.creation_time DESC
        ) AS entry
    FROM journalentries_filtered jf
),


account_trans_with_account AS (
    SELECT
        act.center,
        act.id,
        act.subid,
        act.trans_time,
        act.entry_time,
        act.amount,
        act.text,
        acc.name      AS account_name,
        acc.globalid  AS account_globalid
    FROM puregym.account_trans act
    JOIN puregym.accounts acc
      ON acc.center = act.debit_accountcenter
     AND acc.id     = act.debit_accountid

    UNION ALL

    SELECT
        act.center,
        act.id,
        act.subid,
        act.trans_time,
        act.entry_time,
        act.amount,
        act.text,
        acc.name      AS account_name,
        acc.globalid  AS account_globalid
    FROM puregym.account_trans act
    JOIN puregym.accounts acc
      ON acc.center = act.credit_accountcenter
     AND acc.id     = act.credit_accountid
)

SELECT
    TO_CHAR(longtodateC(act.trans_time, act.center), 'DD/MM/YYYY HH24:MI:SS') AS "DATETIME",
    act.account_name                                                          AS account,
    CASE WHEN art.amount < 0 THEN art.amount ELSE 0 END                       AS refund,
    p.fullname                                                                AS name,
    act.text                                                                  AS "Transaction Text",
    CAST(convert_from(jed.big_text, 'UTF-8') AS VARCHAR)                      AS "Transaction ID",
    ar.customercenter || 'p' || ar.customerid                                 AS personid,
    p.center                                                                  AS centerid,
    CASE WHEN art.amount > 0 THEN art.amount ELSE 0 END                       AS payment,
    TO_CHAR(longtodateC(act.entry_time, act.center), 'DD/MM/YYYY HH24:MI:SS') AS "ENTRYTIME",
    CASE
        WHEN jed.name LIKE '%Course Purchase Sage Pay'
            THEN REPLACE(jed.name, 'Purchase Sage Pay', '')
        WHEN jed.name LIKE '%Course Purchase'
            THEN REPLACE(jed.name, 'Purchase', '')
        WHEN act.text = 'API Sale Transaction'
             AND ar.ar_type = 4
            THEN 'Direct Debit Sale'
        WHEN act.text = 'API Sale Transaction'
             AND ar.ar_type = 1
             AND jed.name IN (
                 'Day Pass Purchase Sage Pay',
                 'Day Pass Purchase',
                 'Payment'
             )
            THEN 'Day Pass'
        WHEN act.text = 'API Sale Transaction'
             AND ar.ar_type = 1
             AND jed.name IN (
                 'Pure Loser Purchase Sage Pay',
                 'Pure Loser Course Purchase Sage Pay',
                 'Pure Loser Purchase',
                 'Pure Loser Course Purchase'
             )
            THEN 'Pure Loser Course'
        WHEN act.text = 'API Sale Transaction'
             AND ar.ar_type = 1
             AND jed.name IN (
                 'Gift Voucher Purchase Sage Pay',
                 'Gift Voucher Purchase'
             )
            THEN 'Gift Card Sale'
        WHEN jed.name = 'Debt Payment'
             AND act.account_globalid IN ('BANK_ACCOUNT_WEB_DEBT')
            THEN 'Debt Payment'
        WHEN jed.name = 'Payment'
            THEN 'Payment'
        WHEN ar.ar_type = 1
             AND jed.name = 'Paid Class'
            THEN 'Paid Class'
        ELSE 'Unknown'
    END AS "Type",
    act.account_globalid AS globalid
FROM
    account_trans_with_account act
JOIN
    puregym.ar_trans art
        ON art.ref_type  = 'ACCOUNT_TRANS'
       AND art.ref_center = act.center
       AND art.ref_id     = act.id
       AND art.ref_subid  = act.subid
JOIN
    puregym.account_receivables ar
        ON ar.center = art.center
       AND ar.id     = art.id
JOIN
    persons p
        ON p.center = ar.customercenter
       AND p.id     = ar.customerid


LEFT JOIN LATERAL (
    SELECT jed.*
    FROM journalentries_deduplicates jed
    WHERE jed.person_id     = p.id
      AND jed.person_center = p.center
      AND jed.entry = 1
    ORDER BY
        CASE
            WHEN jed.creation_time > act.entry_time
                THEN (jed.creation_time - act.entry_time)
            ELSE (act.entry_time - jed.creation_time)
        END
    LIMIT 1
) jed ON TRUE

WHERE
    act.amount   <> 0
    AND act.account_globalid IN ('BANK_ACCOUNT_WEB_DEBT', 'BANK_ACCOUNT_WEB', 'PAYTEL')

     AND act.trans_time >= CAST(datetolongTZ(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),
                        'Europe/London') AS BIGINT)
     AND act.trans_time < CAST(datetolongTZ(TO_CHAR(CAST(:ToDate AS DATE) + 1, 'YYYY-MM-dd HH24:MI'),
                        'Europe/London') AS BIGINT)
ORDER BY
    "DATETIME";
