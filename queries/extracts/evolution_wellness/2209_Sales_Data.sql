-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    *
FROM
    (
        WITH
            params AS
            (
                SELECT
                    /*+ materialize */
                    datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS
                            FromDate,
                    c.id AS CENTER_ID,
                    CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'),
                    'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
                FROM
                    centers c
            )
            ,
            previous_max AS
            (
                SELECT
                    pcc.owner_center ,
                    pcc.owner_id ,
                    pcc.center ,
                    MAX(pcc.id) AS MAXID
                FROM
                    clipcards pcc
                JOIN
                    products ppro
                ON
                    ppro.center = pcc.center
                AND ppro.id = pcc.ID
                JOIN
                    product_and_product_group_link ppgl
                ON
                    ppgl.product_center = ppro.center
                AND ppgl.product_id = ppro.id
                /*AND ppgl.product_group_id IN (1204,212,455,409,490,452,442,3007,3008,607,679,440,639,682
                                              ,3009,1204,3010,3011,3012,3603)*/
                GROUP BY
                    pcc.owner_center ,
                    pcc.owner_id ,
                    pcc.center
            )
            ,
            previous_clipcard AS
            (
                SELECT
                    pcc.owner_center ,
                    pcc.owner_id ,
                    pcc.center ,
                    pcc.id ,
                    pcc.subid ,
                    pcc.valid_from ,
                    ppro.name ,
                    pinv.entry_time ,
                    pinv.center AS invcenter ,
                    pcc.clips_initial
                FROM
                    clipcards pcc
                JOIN
                    products ppro
                ON
                    ppro.center = pcc.center
                AND ppro.id = pcc.ID
                JOIN
                    invoices pinv
                ON
                    pcc.invoiceline_center = pinv.center
                AND pcc.invoiceline_id = pinv.id
                /*JOIN
                    product_and_product_group_link ppgl
                ON
                    ppgl.product_center = ppro.center
                AND ppgl.product_id = ppro.id
                AND ppgl.product_group_id IN (1204,212,455,409,490,452,442,3007,3008,607,679,440,639,682
                                              ,3009,1204,3010,3011,3012,3603)*/
                JOIN
                    previous_max pm
                ON
                    pm.MAXID = pcc.id
                AND pm.center = pcc.center
                WHERE
                    pcc.cancelled IS FALSE
            )
        SELECT DISTINCT
            p.center ||'p'||p.id                            AS "Membership Number" ,
            p.external_id                                   AS "ExternalID" ,
            p.fullname                                      AS "Members Name" ,
            c.shortname                                     AS "Members Home Club" ,
            longtodatec(t.entry_time,t.center)              AS "Package Purchase Date" ,
            cclip.shortname                                 AS "Club Where Package Sold" ,
            cc.invoiceline_center||'inv'||cc.invoiceline_id AS "Receipt Number" ,
            NULL                                            AS "Transaction Number/Balance Number"
            ,
            CASE
                WHEN je.id IS NOT NULL
                THEN 'Yes'
                ELSE 'No'
            END                                                            AS "PT Agreement Doc" ,
            NULL                                                           AS "IPT GSR Doc" ,
            pg.name                                                        AS "Product Category" ,
            pro.globalid                                                   AS "Item Code" ,
            pro.name                                                       AS "Product Name" ,
            inv.product_normal_price                                       AS "List Price" ,
            (inv.total_amount/NULLIF(inv.product_normal_price,0))*100||'%' AS "Discount %" ,
            inv.product_normal_price-inv.total_amount                      AS "Discount Amount" ,
            inv.total_amount                                               AS "Package Price" ,
            inv.net_amount                                                 AS "Package Price ex TAX" ,            
            inv.total_amount/cc.clips_initial                              AS "Price Per Session" ,
            cc.clips_initial                                               AS
            "Total Hours Purchased" ,
            cc.clips_initial                      AS "Total Number Sessions Purchased" ,
            longtodatec(cc.valid_until,cc.center) AS "Package Expiry Date" ,
            NULL                                  AS "Total Estimated Commission" ,
            NULL                                  AS "Sales Commission" ,
            NULL                                  AS "Estimated Conducted Commission" ,
            CASE
                WHEN empsp.center IS NULL
                THEN pclpe.new_value
                ELSE pclsp.new_value
            END  AS "Selling Trainer ID" ,
            NULL AS "Selling Trainer Grade" ,
            CASE
                WHEN empsp.center IS NULL
                THEN pe.fullname
                ELSE empsp.fullname
            END AS "Selling Trainer Name" ,
            CASE
                WHEN empsp.center IS NULL
                THEN pec.shortname
                ELSE empspc.shortname
            END                         AS "Selling Trainer Home Club" ,
            NULL                        AS "Team Leader of Selling Trainer" ,
            pclap.new_value             AS "Primary Conducting Trainer ID" ,
            NULL                        AS "Primary Conducting Trainer Grade" ,
            empap.fullname              AS "Primary Conducting Trainer Name" ,
            empac.shortname             AS "Primary Conducting Trainer Home Club" ,
            NULL                        AS "Team Leader of Primary Conducting Trainer" ,
            CASE
                WHEN pcc.name IS NULL
                THEN 'New'
                ELSE
                    CASE
                        WHEN ((CAST(longtodatec(t.entry_time,t.center) AS DATE)) - (CAST
                                (longtodatec(pcc.entry_time,pcc.center) AS DATE))) > 90
                        THEN 'Renewal > 90D'
                        WHEN ((CAST(longtodatec(t.entry_time,t.center) AS DATE)) - (CAST
                                (longtodatec(pcc.entry_time,pcc.center) AS DATE))) < 90
                        THEN 'Renewal < 90D'
                        ELSE NULL
                    END
            END                                       AS "Purchase Type" ,
            longtodatec(pcc.entry_time,pcc.invcenter) AS "Last PT Purchased Date" ,
            'N/A'                                     AS "Last Verified Date" ,
            pcc.name                                  AS "Last PT Package Name" ,
            pcc.clips_initial                         AS "Last PT Package Total Hours Purchased" ,
            pcc.clips_initial                         AS
            "Last PT Package Total Number Sessions Purchased"
        FROM
            persons p
        JOIN
            clipcards cc
        ON
            cc.owner_center = p.center
        AND cc.owner_id = p.id
        AND cc.cancelled IS FALSE
        JOIN
            centers c
        ON
            c.id = p.center
        JOIN
            centers cclip
        ON
            cc.center = cclip.id
        JOIN
            products pro
        ON
            pro.center = cc.center
        AND pro.id = cc.ID
        LEFT JOIN
            invoice_lines_mt inv
        ON
            cc.invoiceline_center = inv.center
        AND cc.invoiceline_id = inv.id
        AND cc.invoiceline_subid = inv.subid
        LEFT JOIN
            invoices i
        ON
            inv.center = i.center
        AND inv.id = i.id
        LEFT JOIN
            employees emp
        ON
            emp.CENTER = i.employee_center
        AND emp.ID = i.employee_id
        LEFT JOIN
            persons pe
        ON
            pe.CENTER = emp.PERSONCENTER
        AND pe.ID = emp.PERSONID
        LEFT JOIN
            person_change_logs pclpe
        ON  
            pclpe.person_center = pe.center
        AND pclpe.person_id = pe.id
        AND pclpe.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId'         
        LEFT JOIN
            centers pec
        ON
            pec.id = pe.center
        JOIN
            params
        ON
            params.CENTER_ID = c.id
        JOIN
            product_and_product_group_link pgl
        ON
            pgl.product_center = pro.center
        AND pgl.product_id = pro.id
        /*AND pgl.product_group_id IN (1204,212,455,409,490,452,442,3007,3008,607,679,440,639,682,3009,
                                     1204,3010,3011,3012,3603)*/
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.id = pgl.product_group_id
        LEFT JOIN
            (
                SELECT DISTINCT
                    center ,
                    id ,
                    entry_time
                FROM
                    invoices )t
        ON
            cc.invoiceline_center = t.center
        AND cc.invoiceline_id = t.id
        LEFT JOIN
            previous_clipcard pcc
        ON
            pcc.owner_center = cc.owner_center
        AND pcc.owner_id = cc.owner_id
        AND cc.center||'cc'||cc.id||'cc'||cc.subid != pcc.center||'cc'||pcc.id||'cc'||pcc.subid
        AND cc.valid_from > pcc.valid_from
        LEFT JOIN
            persons empap
        ON
            empap.center = cc.assigned_staff_center
        AND empap.id = cc.assigned_staff_id
        LEFT JOIN
            person_change_logs pclap
        ON  
            pclap.person_center = empap.center
        AND pclap.person_id = empap.id 
        AND pclap.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId'     
        LEFT JOIN
            centers empac
        ON
            empap.center = empac.id
        LEFT JOIN
            evolutionwellness.journalentries je
        ON
            cc.center = je.ref_center
        AND cc.id = je.ref_id
        AND cc.subid = je.ref_subid
        AND je.jetype = 34
        LEFT JOIN
            evolutionwellness.invoice_sales_employee invs
        ON
            invs.invoice_center = inv.center
        AND invs.invoice_id = inv.id
        LEFT JOIN
            evolutionwellness.employees emps
        ON
            emps.center = invs.sales_employee_center
        AND emps.id = invs.sales_employee_id
        LEFT JOIN
            evolutionwellness.persons empsp
        ON
            empsp.center = emps.personcenter
        AND empsp.id = emps.personid
        LEFT JOIN
            person_change_logs pclsp
        ON  
            pclsp.person_center = empsp.center
        AND pclsp.person_id = empsp.id
        AND pclsp.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId' 
        LEFT JOIN
            evolutionwellness.centers empspc
        ON
            empspc.id = empsp.center
        WHERE
            p.status NOT IN (4,5,7,8)
        AND t.entry_time BETWEEN params.FromDate AND params.ToDate
        AND p.CENTER IN (:Scope) )t1