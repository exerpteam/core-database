-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t2.fullname,
        t2.creation_date,
        t2.adyen AS total_adyen,
        t2.sepa AS total_sepa,
        (t2.adyen*100)/total AS "porcentaje_adyen(%)",
        (t2.sepa*100)/total AS "porcentaje_sepa(%)"
FROM
(
        SELECT
                t1.fullname,
                t1.creation_date,
                SUM(CASE WHEN t1.clearinghouse = 1 THEN 1 ELSE 0 END) AS Adyen,
                SUM(CASE WHEN t1.clearinghouse = 201 THEN 1 ELSE 0 END) AS SEPA,
                count(*) total
        FROM
        (
                WITH params AS MATERIALIZED
                (
                        SELECT
                                datetolongc(TO_CHAR(to_date(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) AS fromDate,
								datetolongc(TO_CHAR(to_date(:toDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) AS toDate,
                                c.id
                        FROM vivagym.centers c
                        WHERE
                                c.country = 'ES'
                )
                SELECT
                        p.fullname,
                        to_char(longtodatec(acl.entry_time, acl.agreement_center),'YYYY-MM') AS creation_date,
                        pag.clearinghouse,
                        ch.name AS ch_name
                FROM vivagym.payment_agreements pag
                JOIN params par ON pag.center = par.id
                JOIN vivagym.agreement_change_log acl ON pag.center = acl.agreement_center AND pag.id = acl.agreement_id AND pag.subid = acl.agreement_subid
                JOIN vivagym.employees emp ON acl.employee_center = emp.center AND acl.employee_id = emp.id
                JOIN vivagym.persons p ON p.center = emp.personcenter AND p.id = emp.personid
                JOIN vivagym.clearinghouses ch ON ch.id = pag.clearinghouse
                WHERE
                        acl.entry_time > par.fromdate 
 						AND acl.entry_time < par.toDate
                        AND acl.state = 1
                        AND (acl.text IS NULL OR acl.text NOT IN ('Predeterminado','Transfer'))
                        AND (acl.employee_center, acl.employee_id) NOT IN ((100,803))
                        --AND p.fullname != 'WAT Web Apps API User Spain'
        ) t1
        GROUP BY
                t1.fullname,
                t1.creation_date
) t2
order by 1,2