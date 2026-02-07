WITH
    PARAMS AS
    (
        SELECT
            TO_DATE(:fromDate,'YYYY-MM-DD')                                           AS fromDate,
            TO_DATE(:toDate,'YYYY-MM-DD')                                             AS toDate,
            datetolongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'), 'YYYY-MM-DD'), c.ID) AS
            fromDateLong,
            datetolongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD'), 'YYYY-MM-DD'), c.ID)+ (24*60*60*1000
            )      AS toDateLong,
            c.id   AS center_id,
            c.name AS center_name
        FROM
            centers c
	WHERE c.country = 'ES'
    )
SELECT
    curP.external_id                      AS ShopperRef,
    t.person_center || 'p' || t.person_id AS PersonId,
    t.CLUB_NAME,
    t.TRANSACTION_DATE,
    t.AMOUNT,
    t.transaction_id,
    t.Transaction_type,
    (
        CASE
            WHEN t.req_status = 1234
            THEN 'MANUAL'
            ELSE 'REMESA'
        END) Transaction_subtype
FROM
    (
        SELECT
            (
                CASE
                    WHEN cct.method != 4
                    AND ccr.center IS NOT NULL
                    THEN ccr.customercenter
                    WHEN cct.method = 4
                    AND art.center IS NOT NULL
                    THEN ar.customercenter
                    ELSE NULL
                END) PERSON_CENTER,
            (
                CASE
                    WHEN cct.method != 4
                    AND ccr.center IS NOT NULL
                    THEN ccr.customerid
                    WHEN cct.method = 4
                    AND art.center IS NOT NULL
                    THEN ar.customerid
                    ELSE NULL
                END)                                                     PERSON_ID,
            par.center_name                                              AS CLUB_NAME,
            TO_CHAR(longtodatec(cct.transtime, cct.center),'YYYY-MM-DD HH24:MI:SS') AS TRANSACTION_DATE,
            cct.AMOUNT,
            cct.transaction_id,
            '1234' AS req_status,
            (
                CASE
                    WHEN ccr.center IS NOT NULL
                    THEN 'ELGYMIBERIAPOS'
                    ELSE 'ELGYMIBERIAECOM'
                END) AS Transaction_type
        FROM
            creditcardtransactions cct
        JOIN
            PARAMS par
        ON
            par.center_id = cct.center
        LEFT JOIN
            vivagym.cashregistertransactions ccr
        ON
            cct.gl_trans_center = ccr.gltranscenter
        AND cct.gl_trans_id = ccr.gltransid
        AND cct.gl_trans_subid = ccr.gltranssubid
        AND cct.method != 4
        LEFT JOIN
            vivagym.ar_trans art
        ON
            art.center = cct.gl_trans_center
        AND art.id = cct.gl_trans_id
        AND art.subid = cct.gl_trans_subid
        AND cct.method = 4
        LEFT JOIN
            vivagym.account_receivables ar
        ON
            ar.center = art.center
        AND ar.id = art.id
        WHERE
            cct.transtime >= par.fromDateLong
        AND cct.transtime <= par.toDateLong
        AND cct.amount != 0
        UNION ALL
        SELECT
            ar.customercenter                     AS PERSON_CENTER,
            ar.customerid                         AS PERSON_ID,
            par.center_name                       AS CLUB_NAME,
            TO_CHAR(pr.req_date - 1,'YYYY-MM-DD') AS TRANSACTION_DATE,
            pr.req_amount                         AS AMOUNT,
            pag.clearinghouse_ref                 AS transaction_id,
            pr.state                              AS req_status,
            'ELGYMIBERIAECOM'                     AS Transaction_type
        FROM
            vivagym.payment_requests pr
        JOIN
            PARAMS par
        ON
            par.center_id = pr.center
        JOIN
            vivagym.payment_agreements pag
        ON
            pr.center = pag.center
        AND pr.id = pag.id
        AND pr.agr_subid = pag.subid
        JOIN
            vivagym.clearinghouses ch
        ON
            pag.clearinghouse = ch.id
        JOIN
            vivagym.payment_accounts pac
        ON
            pac.center = pag.center
        AND pac.id = pag.id
        JOIN
            vivagym.account_receivables ar
        ON
            ar.center = pac.center
        AND ar.id = pac.id
        WHERE
            ch.id = 1 -- ADYEN
        AND pr.state IN (3,18)
        AND pr.req_date >= par.fromDate
        AND pr.req_date <= par.toDate + interval '1 day'
        UNION ALL
        SELECT
            curp.center                                                   AS PERSON_CENTER,
            curp.id                                                       AS PERSON_ID,
            par.center_name                                               AS CLUB_NAME,
            TO_CHAR(longtodatec(art.trans_time,art.center), 'YYYY-MM-DD HH24:MI:SS') AS TRANSACTION_DATE,
            art.amount,
            'Error (N/A)'     AS transaction_id,
            '1234'            AS req_status,
            'ELGYMIBERIAECOM' AS Transaction_type
        FROM
            vivagym.ar_trans art
        JOIN
            PARAMS par
        ON
            par.center_id = art.center
        JOIN
            vivagym.account_receivables ar
        ON
            ar.center = art.center
        AND ar.id = art.id
        LEFT JOIN
            vivagym.creditcardtransactions cct
        ON
            art.center = cct.gl_trans_center
        AND art.id = cct.gl_trans_id
        AND art.subid = cct.gl_trans_subid
        AND cct.method = 4
        JOIN
            persons p
        ON
            p.center = ar.customercenter
        AND p.id = ar.customerid
        LEFT JOIN
            PERSONS curP
        ON
            curP.center = p.current_person_center
        AND curP.id = p.current_person_id
        WHERE
            ar.ar_type = 1
        AND cct.id IS NULL
        AND art.text = 'API Sale Transaction'
        AND art.employeecenter = 100
        AND art.employeeid = 1203
        AND art.trans_time >= par.fromDateLong
        AND art.trans_time <= par.toDateLong) t
LEFT JOIN
    PERSONS p
ON
    p.center = t.person_center
AND p.id = t.person_id
LEFT JOIN
    PERSONS curP
ON
    curP.center = p.current_person_center
AND curP.id = p.current_person_id