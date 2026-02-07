SELECT
        t1.*
FROM
(
        WITH params AS
        (
                SELECT
                        dateToLongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) AS fromDate,
                        dateToLongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),c.id)-1 AS toDate,
                        c.id
                FROM puregym_switzerland.centers c
        )
        SELECT
                p.center || 'p' || p.id AS personid,
                CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
                p.status,
                il.center,
                il.id,
                il.subid,
                i.text,
                ar.balance AS payment_account_balance,
                il.text,
                spp.addons_price,
                spp.subscription_price,
                spp.to_date-spp.from_date as number_days_period,
                (CASE
                        WHEN 
                                EXISTS
                                (
                                        SELECT 1
                                        FROM puregym_switzerland.subscription_addon sa
                                        WHERE sa.subscription_center = s.center AND sa.subscription_id = s.id
                                                AND sa.individual_price_per_unit > 0
                                )
                                THEN 'YES'
                                ELSE 'NO'
                END) HAS_ADDON,
                cp.center || 'p' || cp.id AS current_PersonId,
                car.balance AS current_PaymentAccountBalance,
                to_char(longtodatec(spp.cancellation_time, spp.center),'YYYY-MM-DD HH24:MI') AS cancellation_time
        FROM puregym_switzerland.subscriptionperiodparts spp
        JOIN params par ON spp.center = par.id
        JOIN puregym_switzerland.spp_invoicelines_link spl 
                ON spl.period_center = spp.center AND spl.period_id = spp.id AND spl.period_subid = spp.subid
        JOIN puregym_switzerland.invoice_lines_mt il
                ON spl.invoiceline_center = il.center AND spl.invoiceline_id = il.id AND spl.invoiceline_subid = il.subid
        JOIN puregym_switzerland.invoices i     
                ON il.center = i.center AND il.id = i.id
        JOIN puregym_switzerland.subscriptions s
                ON s.center = spp.center AND s.id = spp.id
        JOIN puregym_switzerland.persons p
                ON p.center = s.owner_center AND p.id = s.owner_id
        JOIN puregym_switzerland.account_receivables ar
                ON ar.customercenter = p.center AND ar.customerid = p.id AND ar.ar_type = 4
        LEFT JOIN puregym_switzerland.persons cp
                ON cp.center = p.current_person_center AND cp.id = p.current_person_id AND p.status IN (4)
        LEFT JOIN puregym_switzerland.account_receivables car
                ON car.customercenter = cp.center AND car.customerid = cp.id AND car.ar_type = 4
        WHERE
                (i.employee_center, i.employee_id) = ((100,1))
                AND i.text = 'Converted subscription invoice'
                AND spp.spp_state = 2 -- CANCELLED
                AND p.status NOT IN (5)
                AND spp.cancellation_time between par.fromDate AND par.toDate
) t1
WHERE t1.has_addon = 'YES' AND ((t1.status NOT IN (4) AND t1.payment_account_balance != 0) OR (t1.status IN (4) AND t1.current_PaymentAccountBalance != 0))