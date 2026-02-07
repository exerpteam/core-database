SELECT
        t1.center,
        t1.id,
        t1."PERSONKEY",
        t1.deductiondate,
        t1.duedate
FROM
(
        WITH PARAMS AS
        (
                SELECT
                        dateToLongC(TO_CHAR(DATE_TRUNC('MONTH',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')),'YYYY-MM-DD'), c.id) AS fromDateLong,
                        DATE_TRUNC('MONTH',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) as fromDate,
                        extract(DAY FROM(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'))) AS executionDate,
                        TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') AS deductiondate,
                        c.id AS centerId
                FROM
                        vivagym.centers c
                WHERE
                        c.country = 'ES'
        )
        SELECT
                DISTINCT
                p.center,
                p.id,
                p.external_id AS externalid,
                p.center || 'p' || p.id AS "PERSONKEY", 
                par.deductiondate,
                par.deductiondate AS duedate
                /*p.status,
                longToDatec(art.entry_time, art.center) AS TransactionEntryTime,
                art.amount,
                art.text,
                art.due_date,
                art.ref_type,
                pag.state,
                longtodatec(pag.creation_time, pag.center) AS PaymentAgr_CreationTime,
                ar.balance,
                (CASE
                        WHEN pag_old.clearinghouse = 1 THEN 'Adyen'
                        WHEN pag_old.clearinghouse = 201 THEN 'SEPA'
                        ELSE NULL
                END) AS Previous_CH,
                longtodatec(pea.last_edit_time, pea.personcenter) AS Transferred_Time*/
        FROM vivagym.persons p
        JOIN PARAMS par ON p.center = par.centerId
        JOIN vivagym.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
        JOIN vivagym.ar_trans art ON ar.center = art.center AND ar.id = art.id
        JOIN vivagym.payment_accounts pac ON pac.center = ar.center AND pac.id = ar.id
        JOIN vivagym.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
        LEFT JOIN vivagym.payment_agreements pag_old ON pag.prev_center = pag_old.center AND pag.prev_id = pag_old.id AND pag.prev_subid = pag_old.subid
        LEFT JOIN vivagym.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_TransferredFromId'
        WHERE
                art.collected = 0
                 AND p.center IN (:center)
                AND art.amount < 0
                AND art.status NOT IN ('CLOSED')
                AND art.entry_time > par.fromDateLong
                AND pag.clearinghouse in (3401,3001,2801,201,3801,3802,4401,4801,5001,4403,5401)
                AND p.status NOT IN (4,5,7,8)
                AND par.executionDate = 8
                -- To exclude small amounts due to adjustments
                AND ar.balance < -5
                -- Member doesnt have a PaymentRequest raised this month already
                AND NOT EXISTS
                (
                        SELECT
                                1
                        FROM vivagym.persons allp
                        JOIN vivagym.account_receivables arp ON allp.center = arp.customercenter AND allp.id = arp.customerid
                        JOIN vivagym.payment_requests pr on arp.center = pr.center AND arp.id = pr.id
                        WHERE
                                allp.current_person_center = p.center
                                AND allp.current_person_id = p.id
                                AND pr.req_date >= par.fromDate
                )
) t1