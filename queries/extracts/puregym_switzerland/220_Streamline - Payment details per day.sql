-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    base AS materialized
    (   SELECT
            p.center         AS p_center,
            p.id             AS p_id,
            art.entry_time   AS art_entry_time,
            art.amount       AS art_amount,
            ar.ar_type       AS ar_ar_type,
            p.fullname       AS p_fullname,
            act.center       AS act_center,
            act.id           AS act_id,
            act.subid        AS act_subid,
            act.trans_time   AS act_trans_time,
            act.text         AS act_text,
            act.entry_time   AS act_entry_time,
            acc.name         AS acc_account,
            acc.globalid     AS acc_globalid,
            je.name          AS je_name_unfiltered,
            je.creation_time AS je_creation_time_unfiltered,
            je.big_text      AS je_big_text_unfiltered,
            CASE WHEN (je.creation_time >= CAST(datetolongTZ(to_char(CAST($$fromdate$$ AS DATE), 'YYYY-MM-dd HH24:MI'),  'Europe/Zurich') AS BIGINT) - 300000
                                AND je.creation_time <  CAST(datetolongTZ(to_char(CAST($$todate$$ AS DATE)+1, 'YYYY-MM-dd HH24:MI'),  'Europe/Zurich') AS BIGINT) + 300000
                                AND ABS(je.creation_time - art.entry_time) <= 300000
                                AND(je.name IN ('Debts Payment Sage Pay', 'Day Pass Purchase Sage Pay', 'Pure Loser Purchase Sage Pay', 'Join Payment Sage Pay', 'Debt Payment Sage Pay',
                                        'Day-pass Payment Sage Pay', 'Pureloser Payment Sage Pay', 'Course Payment Sage Pay', 'Gift Voucher Purchase Sage Pay', 'Debt Payment', 'Day Pass Purchase',
                                        'Pure Loser Purchase', 'Join Payment', 'Day-pass Payment', 'Pureloser Payment', 'Course Payment', 'Gift Voucher Purchase')
                                        --'Grit Course Purchase Sage Pay', 'Pure Loser Course Purchase Sage Pay', 'Pure LifeStyle Course Purchase Sage Pay', 'Pure LifeStyle with Protein World Course Purchase Sage',
                                        --'Pay', 'Zuu Fitness Course Purchase Sage Pay' 
                                OR je.name LIKE '%Course Purchase%'))            
                        OR je.creation_time IS NULL                
                THEN true
                ELSE false
            END je_join_extra_conditions
        FROM
            ACCOUNT_TRANS act
        JOIN
            ACCOUNTS acc
            ON (
                    act.DEBIT_ACCOUNTCENTER = acc.center
                    AND act.DEBIT_ACCOUNTID = acc.id)
                OR
                (
                    act.CREDIT_ACCOUNTCENTER = acc.center
                    AND act.CREDIT_ACCOUNTID = acc.id)
        JOIN
            AR_TRANS art
            ON  art.REF_TYPE = 'ACCOUNT_TRANS'
                AND art.REF_CENTER = act.center
                AND art.REF_ID = act.id
                AND art.REF_SUBID = act.subid
        JOIN
            ACCOUNT_RECEIVABLES AR
            ON  AR.CENTER = art.CENTER
                AND AR.ID = ART.ID
        JOIN
            persons P
            ON  P.CENTER = AR.CUSTOMERCENTER
                AND P.ID = AR.CUSTOMERID
        LEFT JOIN
            JOURNALENTRIES je
            ON  p.id = je.PERSON_ID
                AND p.center = je.PERSON_CENTER
        WHERE
            act.AMOUNT <> 0
            AND acc.GLOBALID IN ('BANK_ACCOUNT_WEB_DEBT', 'BANK_ACCOUNT_WEB', 'PAYTEL')
            AND act.trans_time >= CAST(datetolongTZ(to_char(CAST($$fromdate$$ AS DATE), 'YYYY-MM-dd HH24:MI'),  'Europe/Zurich') AS BIGINT)
            AND act.trans_time <  CAST(datetolongTZ(to_char(CAST($$todate$$ AS DATE)+1, 'YYYY-MM-dd HH24:MI'),  'Europe/Zurich') AS BIGINT)
    )
    ,
    base2 AS
    (   SELECT
            *,
            CASE WHEN je_join_extra_conditions
                    THEN je_name_unfiltered
                    ELSE NULL
            END AS je_name,
            CASE WHEN je_join_extra_conditions
                    THEN je_creation_time_unfiltered
                    ELSE NULL
            END AS je_creation_time,
            CASE WHEN je_join_extra_conditions
                    THEN je_big_text_unfiltered
                    ELSE NULL
            END AS je_big_text
        FROM
            base
    )
    ,
    base3 AS
    (   SELECT
            *,
            RANK() OVER(
                    PARTITION BY
                        p_center,
                        p_id,
                        act_center,
                        act_id,
                        act_subid
                    ORDER BY
                        ABS(je_creation_time - art_entry_time) ASC) AS rnk,
            ABS(je_creation_time - art_entry_time)                  AS timediff,
            ROW_NUMBER() OVER(
                    PARTITION BY
                        p_center,
                        p_id,
                        act_center,
                        act_id,
                        act_subid)                                  as row_number
        FROM
            base2
    )
SELECT
    TO_CHAR(longtodateTZ(act_trans_time, 'Europe/Zurich'), 'DD/MM/YYYY HH24:MI:SS') AS "DATETIME",
    acc_account                                                                     AS account,
    CASE WHEN(art_amount < 0)
            THEN art_amount
            ELSE 0
    END                                AS REFUND,
    p_fullname                         AS NAME,
    act_text                           AS "Transaction Text",
    convert_from(je_big_text, 'UTF-8') AS "Transaction ID",
    p_center || 'p' || p_id            AS PersonId,
    p_center                           AS CenterID,
    CASE WHEN(art_amount > 0)
            THEN art_amount
            ELSE 0
    END                                                                             AS PAYMENT,
    TO_CHAR(longtodateTZ(act_entry_time, 'Europe/Zurich'), 'DD/MM/YYYY HH24:MI:SS') AS "ENTRYTIME",
    CASE WHEN je_name LIKE '%Course Purchase Sage Pay' THEN REPLACE(je_name, 'Purchase Sage Pay', '') 
        WHEN je_name LIKE '%Course Purchase' THEN REPLACE(je_name, 'Purchase', '') 
        WHEN act_text = 'API Sale Transaction' AND ar_ar_type = 4 THEN 'Direct Debit Sale' 
        WHEN act_text = 'API Sale Transaction' AND ar_ar_type = 1 AND je_name IN ('Day Pass Purchase Sage Pay', 'Day Pass Purchase') THEN 'Day Pass' 
        WHEN act_text = 'API Sale Transaction' AND ar_ar_type = 1
            AND je_name IN('Pure Loser Purchase Sage Pay', 'Pure Loser Course Purchase Sage Pay', 'Pure Loser Purchase', 'Pure Loser Course Purchase') THEN 'Pure Loser Course' 
        WHEN act_text = 'API Sale Transaction' AND ar_ar_type = 1
            AND je_name IN('Gift Voucher Purchase Sage Pay', 'Gift Voucher Purchase') THEN 'Gift Card Sale' 
        WHEN je_name = 'Debt Payment' OR acc_globalid IN('BANK_ACCOUNT_WEB_DEBT') THEN 'Debt Payment'
                ELSE 'Unknown'
    END AS "Type"
FROM
    base3
WHERE
    rnk = 1
    and row_number=1