-- The extract is extracted from Exerp on 2026-02-08
--  
WITH duplicated_dni AS MATERIALIZED
(
        SELECT
                t1.nat_id_formated,
                count(*)
        FROM
        (
                SELECT
                        REPLACE(REPLACE(UPPER(p.national_id),'-',''),' ','') nat_id_formated
                FROM vivagym.persons p
                JOIN vivagym.centers c ON p.center = c.id
                WHERE
                        c.country = 'ES'
                        AND p.status NOT IN (4,5,7,8)
                        AND p.national_id IS NOT NULL
        ) t1
        GROUP BY
                t1.nat_id_formated
        HAVING COUNT(*) > 1
),
v_main AS
(
        SELECT 
                dd.nat_id_formated,
                p.fullname,
                p.center || 'p' || p.id AS personid,
                (CASE p.status 
                        WHEN 0 THEN '4_LEAD' 
                        WHEN 1 THEN '1_ACTIVE' 
                        WHEN 2 THEN '3_INACTIVE' 
                        WHEN 3 THEN '2_TEMPORARYINACTIVE' 
                        WHEN 6 THEN '5_PROSPECT' 
                        WHEN 9 THEN '6_CONTACT' 
                        ELSE '7_Undefined' 
                END) AS person_status,
                p.national_id,
                p.blacklisted,
                ar.balance AS payment_account_balance,
                TO_DATE(pea.txtvalue,'YYYY-MM-DD') AS creationDate,
                MAX(s.end_date) AS latest_enddate
        FROM duplicated_dni dd
        JOIN vivagym.persons p
                ON REPLACE(REPLACE(UPPER(p.national_id),'-',''),' ','') = dd.nat_id_formated
        LEFT JOIN vivagym.account_receivables ar 
                ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
        LEFT JOIN vivagym.person_ext_attrs pea
                ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = 'CREATION_DATE'
        LEFT JOIN vivagym.subscriptions s
                ON p.center = s.owner_center AND p.id = s.owner_id AND p.status IN (2)
        WHERE
                p.status NOT IN (4,5,7,8)
        GROUP BY
                dd.nat_id_formated,
                p.fullname,
                p.center,
                p.id,
                p.status,
                p.national_id,
                p.blacklisted,
                ar.balance,
                pea.txtvalue
        ORDER BY
                dd.nat_id_formated,
                p.status
),
v_pivot AS
(
        SELECT
                v_main.*,
                LEAD(fullname,1) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS fullname2,
                LEAD(personid,1) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS personid2,
                LEAD(person_status,1) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS person_status2,
                LEAD(blacklisted,1) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS blacklisted2,
                LEAD(creationDate,1) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS creationDate2,
                LEAD(national_id,1) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS national_id2,
                LEAD(payment_account_balance,1) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS payment_account_balance2,
                LEAD(latest_enddate,1) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS latest_enddate2,
                
                LEAD(fullname,2) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS fullname3,
                LEAD(personid,2) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS personid3,
                LEAD(person_status,2) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS person_status3,
                LEAD(blacklisted,2) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS blacklisted3,
                LEAD(creationDate,2) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS creationDate3,
                LEAD(national_id,2) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS national_id3,
                LEAD(payment_account_balance,2) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS payment_account_balance3,
                LEAD(latest_enddate,2) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS latest_enddate3,
                
                LEAD(fullname,3) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS fullname4,
                LEAD(personid,3) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS personid4,
                LEAD(person_status,3) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS person_status4,
                LEAD(blacklisted,3) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS blacklisted4,
                LEAD(creationDate,3) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS creationDate4,
                LEAD(national_id,3) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS national_id4,
                LEAD(payment_account_balance,3) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS payment_account_balance4,
                LEAD(latest_enddate,3) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS latest_enddate4,
                
                LEAD(fullname,4) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS fullname5,
                LEAD(personid,4) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS personid5,
                LEAD(person_status,4) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS person_status5,
                LEAD(blacklisted,4) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS blacklisted5,
                LEAD(creationDate,4) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS creationDate5,
                LEAD(national_id,4) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS national_id5,
                LEAD(payment_account_balance,4) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS payment_account_balance5,
                LEAD(latest_enddate,4) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS latest_enddate5,
                
                LEAD(fullname,5) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS fullname6,
                LEAD(personid,5) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS personid6,
                LEAD(person_status,5) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS person_status6,
                LEAD(blacklisted,5) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS blacklisted6,
                LEAD(creationDate,5) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS creationDate6,
                LEAD(national_id,5) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS national_id6,
                LEAD(payment_account_balance,5) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS payment_account_balance6,
                LEAD(latest_enddate,5) OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS latest_enddate6,
                
                ROW_NUMBER() OVER (PARTITION BY nat_id_formated ORDER BY person_status, creationDate DESC, personid) AS ADDONSEQ
        FROM v_main
) 
SELECT 
        nat_id_formated,
        fullname AS fullname1,
        personid AS personid1,
        person_status AS person_status1,
        (CASE blacklisted WHEN 0 THEN 'NONE' WHEN 1 THEN 'BLACKLISTED' WHEN 2 THEN 'SUSPENDED' WHEN 3 THEN 'BLOCKED' END) AS blacklisted1,
        national_id AS national_id1,
        payment_account_balance AS payment_account_balance1,
        creationDate AS creationDate1,
        latest_enddate AS latest_enddate1,
        
        fullname2,
        personid2,
        person_status2,
        (CASE blacklisted2 WHEN 0 THEN 'NONE' WHEN 1 THEN 'BLACKLISTED' WHEN 2 THEN 'SUSPENDED' WHEN 3 THEN 'BLOCKED' END) AS blacklisted2,
        national_id2,
        payment_account_balance2,
        creationDate2,
        latest_enddate2,
        
        fullname3,
        personid3,
        person_status3,
        (CASE blacklisted3 WHEN 0 THEN 'NONE' WHEN 1 THEN 'BLACKLISTED' WHEN 2 THEN 'SUSPENDED' WHEN 3 THEN 'BLOCKED' END) AS blacklisted3,
        national_id3,
        payment_account_balance3,
        creationDate3,
        latest_enddate3,
        
        fullname4,
        personid4,
        person_status4,
        (CASE blacklisted4 WHEN 0 THEN 'NONE' WHEN 1 THEN 'BLACKLISTED' WHEN 2 THEN 'SUSPENDED' WHEN 3 THEN 'BLOCKED' END) AS blacklisted4,
        national_id4,
        payment_account_balance4,
        creationDate4,
        latest_enddate4,
        
        fullname5,
        personid5,
        person_status5,
        (CASE blacklisted5 WHEN 0 THEN 'NONE' WHEN 1 THEN 'BLACKLISTED' WHEN 2 THEN 'SUSPENDED' WHEN 3 THEN 'BLOCKED' END) AS blacklisted5,
        national_id5,
        payment_account_balance5,
        creationDate5,
        latest_enddate5,
        
        fullname6,
        personid6,
        person_status6,
        (CASE blacklisted6 WHEN 0 THEN 'NONE' WHEN 1 THEN 'BLACKLISTED' WHEN 2 THEN 'SUSPENDED' WHEN 3 THEN 'BLOCKED' END) AS blacklisted6,
        national_id6,
        payment_account_balance6,
        creationDate6,
        latest_enddate6         
FROM v_pivot
WHERE ADDONSEQ = 1