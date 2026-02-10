-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    RECURSIVE centers_in_area AS
    (
        SELECT
            a.id,
            a.parent,
            ARRAY[id] AS chain_of_command_ids,
            2         AS level
        FROM
            areas a
        WHERE
            a.types LIKE '%system%'
        AND a.parent IS NULL
        UNION ALL
        SELECT
            a.id,
            a.parent,
            array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids,
            cin.level + 1                                AS level
        FROM
            areas a
        JOIN
            centers_in_area cin
        ON
            cin.id = a.parent
    )
    ,
    areas_total AS
    (
        SELECT
            cin.id AS ID,
            cin.level,
            unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
        FROM
            centers_in_area cin
        LEFT JOIN
            centers_in_area AS b -- join provides subordinates
        ON
            cin.id = ANY (b.chain_of_command_ids)
        AND cin.level <= b.level
        GROUP BY
            1,2
    )
    ,
    scope_center AS
    (
        SELECT
            'A'               AS SCOPE_TYPE,
            areas_total.ID    AS SCOPE_ID,
            c.ID              AS CENTER_ID,
            areas_total.level AS LEVEL
        FROM
            areas_total
        LEFT JOIN
            area_centers ac
        ON
            ac.area = areas_total.sub_areas
        JOIN
            centers c
        ON
            ac.CENTER = c.id
    )
    ,
    center_config_payment_method_id AS
    (
        SELECT
            center_id,
            (xpath('//attribute/@id',xml_element))[1]::text::INTEGER     AS id,
            (xpath('//attribute/@name',xml_element))[1]::text            AS name,
            (xpath('//attribute/@globalAccountId',xml_element))[1]::text AS globalAccountId
        FROM
            (
                SELECT
                    center_id,
                    unnest(xpath('//attribute',xmlparse(document convert_from(mimevalue, 'UTF-8'))
                    )) AS xml_element
                FROM
                    (
                        SELECT
                            a.name,
                            sc.center_id,
                            sys.mimevalue,
                            sc.level,
                            MAX(sc.LEVEL) over (partition BY sc.CENTER_ID) AS maxlevel
                        FROM
                            evolutionwellness.systemproperties SYS
                        JOIN
                            scope_center sc
                        ON
                            sc.SCOPE_ID = sys.scope_id
                        AND sys.scope_type = sc.SCOPE_TYPE
                        JOIN
                            areas a
                        ON
                            a.id = sys.scope_id
                        WHERE
                            sys.globalid = 'PaymentMethodsConfig') t
                WHERE
                    maxlevel = LEVEL)
    )
SELECT DISTINCT
    CASE
        WHEN art.ref_type = 'ACCOUNT_TRANS'
        THEN art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid
        ELSE art.ref_center||'cred'||art.ref_id
    END           AS "TXN_ID",
    c.name        AS "CLUB",
    c.id          AS "CLUB_NUMBER",
    c.external_id AS "CLUB_CODE",
    cea.txt_value AS "CLUB_VAT_NUMBER",
    p.external_id AS "MEMBER_NUMBER",
    p.fullname    AS "MEMBER_NAME",
    COALESCE(p.address1,'')||' '||COALESCE(p.address2,'')||' '||COALESCE(p.address3,'')||', '||
    COALESCE(p.city,'')||', '||COALESCE(p.zipcode,'')                   AS "MEMBER_ADDRESS",
    p.ssn                                                               AS "MEMBER_TAX_ID",
    p.center||'p'||p.id                                                 AS "PERSON_ID",
    TO_CHAR(longtodatec(crt.transtime,crt.center),'dd.mm.yyyy hh24:mi') AS "PAYMENT_DATE",
    CASE crt.CRTTYPE
        WHEN 1
        THEN 'CASH'
        WHEN 2
        THEN 'CHANGE'
        WHEN 3
        THEN 'RETURN ON CREDIT'
        WHEN 4
        THEN 'PAYOUT CASH'
        WHEN 5
        THEN 'PAID BY CASH AR ACCOUNT'
        WHEN 6
        THEN 'DEBIT CARD'
        WHEN 7
        THEN 'CREDIT CARD'
        WHEN 8
        THEN 'DEBIT OR CREDIT CARD'
        WHEN 9
        THEN 'GIFT CARD'
        WHEN 10
        THEN 'CASH ADJUSTMENT'
        WHEN 11
        THEN 'CASH TRANSFER'
        WHEN 12
        THEN 'PAYMENT AR'
        WHEN 14
        THEN 'CASH REGISTER PAYOUT'
        WHEN 15
        THEN 'CREDIT CARD ADJUSTMENT'
        WHEN 16
        THEN 'CLOSING CASH ADJUST'
        WHEN 17
        THEN 'VOUCHER'
        WHEN 18
        THEN 'PAYOUT CREDIT CARD'
        WHEN 19
        THEN 'TRANSFER BETWEEN REGISTERS'
        WHEN 20
        THEN 'CLOSING CREDIT CARD ADJ'
        WHEN 21
        THEN 'TRANSFER BACK CASH COINS'
        WHEN 22
        THEN 'INSTALLMENT PLAN'
        WHEN 100
        THEN 'INITIAL CASH'
        WHEN 101
        THEN 'MANUAL'
        WHEN 13
        THEN cpm.name
        ELSE 'CREDIT NOTE'
    END               AS "PAYMENT_TYPE",
    staff.fullname    AS "OPERATOR",
    art.amount / 1.07 AS "OVERPAYMENT_EXCLUDING_TAX",
    art.amount * 0.07 / 1.07 AS "OVERPAYMENT_TAX_AMOUNT" ,
    art.amount        AS "OVERPAYMENT_TOTAL"
FROM
    persons p
JOIN
    evolutionwellness.account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
    evolutionwellness.ar_trans art
ON
    art.center = ar.center
AND art.id = ar.id
AND art.ref_type = 'ACCOUNT_TRANS'
LEFT JOIN
    evolutionwellness.cashregistertransactions crt
ON
    longtodatec(art.trans_time,art.center) = longtodatec(crt.transtime,crt.center)
AND art.amount = crt.amount
AND crt.customercenter = ar.customercenter
AND crt.customerid = ar.customerid
LEFT JOIN
    persons cp
ON
    cp.center = p.transfers_current_prs_center
AND cp.id = p.transfers_current_prs_id
LEFT JOIN
    evolutionwellness.employees emp
ON
    emp.center = crt.employeecenter
AND emp.id = crt.employeeid
LEFT JOIN
    evolutionwellness.persons staff
ON
    staff.center = emp.personcenter
AND staff.id = emp.personid
LEFT JOIN
    center_config_payment_method_id cpm
ON
    cpm.center_id = crt.center
AND crt.config_payment_method_id = cpm.id
LEFT JOIN
    evolutionwellness.centers c
ON
    crt.center = c.id
LEFT JOIN
    evolutionwellness.center_ext_attrs cea
ON
    cea.center_id= c.id
AND cea.name = 'vatRegistrationNumber'
WHERE
    art.amount > 0
AND p.sex != 'C'
AND art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid = :TransactionID