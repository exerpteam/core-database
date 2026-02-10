-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t4.*
FROM
(
        SELECT
                t3.person_status,
                t3.personid,
                t3.ch_name,
                t3.state,
                t3.active,
                t3.ref,
                t3.iban,
                t3.bban_check_digit AS current_bban_check_digit,
                (t3.first_check_digit * 10 ) + t3.second_check_digit AS calculated_check_digit
        FROM
        (
                SELECT
                        t2.person_status,
                        t2.personid,
                        t2.ch_name,
                        t2.state,
                        t2.active,
                        t2.ref,
                        t2.iban,
                        t2.bban_check_digit,
                        t2.first_digit_calc,
                        t2.second_digit_calc,
                        (CASE t2.first_digit_calc WHEN 11 THEN 0 WHEN 10 THEN 1 ELSE t2.first_digit_calc END) AS first_check_digit,
                        (CASE t2.second_digit_calc WHEN 11 THEN 0 WHEN 10 THEN 1 ELSE t2.second_digit_calc END) AS second_check_digit
                FROM
                (
                        SELECT
                                t1.person_status,
                                t1.personid,
                                t1.ch_name,
                                t1.state,
                                t1.active,
                                t1.ref,
                                t1.iban,
                                t1.bban_check_digit,
                                11-MOD((t1.e1*4)+(t1.e2*8)+(t1.e3*5)+(t1.e4*10)+(t1.o1*9)+(t1.o2*7)+(t1.o3*3)+(t1.o4*6),11) AS first_digit_calc,
                                11-MOD((t1.c1*1)+(t1.c2*2)+(t1.c3*4)+(t1.c4*8)+(t1.c5*5)+(t1.c6*10)+(t1.c7*9)+(t1.c8*7)+(t1.c9*3)+(t1.c10*6),11) AS second_digit_calc
                        FROM
                        (
                                SELECT
                                        pag.state,
                                        ch.name AS ch_name,
                                        pag.active,
                                        pag.ref,
                                        pag.iban,
                                        p.center || 'p' || p.id AS personid,
                                        (CASE p.status WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' 
                                                       WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' 
                                                       WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END) AS person_status,
                                        CAST(substring(pag.iban,5,1)AS INT) AS e1,
                                        CAST(substring(pag.iban,6,1)AS INT) AS e2,
                                        CAST(substring(pag.iban,7,1)AS INT) AS e3,
                                        CAST(substring(pag.iban,8,1)AS INT) AS e4,
                                        
                                        CAST(substring(pag.iban,9,1)AS INT) AS o1,
                                        CAST(substring(pag.iban,10,1)AS INT) AS o2,
                                        CAST(substring(pag.iban,11,1)AS INT) AS o3,
                                        CAST(substring(pag.iban,12,1)AS INT) AS o4,
                                        
                                        CAST(substring(pag.iban,15,1)AS INT) AS c1,
                                        CAST(substring(pag.iban,16,1)AS INT) AS c2,
                                        CAST(substring(pag.iban,17,1)AS INT) AS c3,
                                        CAST(substring(pag.iban,18,1)AS INT) AS c4,
                                        CAST(substring(pag.iban,19,1)AS INT) AS c5,
                                        CAST(substring(pag.iban,20,1)AS INT) AS c6,
                                        CAST(substring(pag.iban,21,1)AS INT) AS c7,
                                        CAST(substring(pag.iban,22,1)AS INT) AS c8,
                                        CAST(substring(pag.iban,23,1)AS INT) AS c9,
                                        CAST(substring(pag.iban,24,1)AS INT) AS c10,
                                        
                                        CAST(substring(pag.iban,13,2)AS INT) AS bban_check_digit
                                FROM vivagym.payment_agreements pag
                                JOIN vivagym.payment_accounts pac ON pag.center = pac.center AND pag.id = pac.id
                                JOIN vivagym.account_receivables ar ON pac.center = ar.center AND pac.id = ar.id
                                JOIN vivagym.persons p ON p.center = ar.customercenter AND p.id = ar.customerid
                                JOIN vivagym.clearinghouses ch ON pag.clearinghouse = ch.id
                                WHERE
                                        ch.ctype = 185
                                        AND pag.state = 4
                                        AND pag.iban IS NOT NULL
                                        AND length(pag.iban) = 24
                                        AND pag.iban like 'ES%'
                        ) t1
                ) t2
        ) t3
) t4
WHERE
        t4.current_bban_check_digit != t4.calculated_check_digit
UNION ALL
SELECT
        (CASE p.status WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' 
                       WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' 
                       WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END) AS person_status,
        p.center || 'p' || p.id AS personid,               
        ch.name AS ch_name,
        pag.state,
        pag.active,
        pag.ref,
        pag.iban,
        NULL,
        NULL        
FROM vivagym.payment_agreements pag
JOIN vivagym.payment_accounts pac ON pag.center = pac.center AND pag.id = pac.id
JOIN vivagym.account_receivables ar ON pac.center = ar.center AND pac.id = ar.id
JOIN vivagym.persons p ON p.center = ar.customercenter AND p.id = ar.customerid
JOIN vivagym.clearinghouses ch ON pag.clearinghouse = ch.id
WHERE
        ch.ctype = 185
        AND pag.state = 4
        AND pag.iban IS NOT NULL
        AND (pag.iban like 'GB%' OR pag.iban like 'CH%')
order by 3