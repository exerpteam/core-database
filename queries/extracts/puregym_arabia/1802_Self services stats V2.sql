-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-8560
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id,
            CAST ($$StartDate$$ AS DATE)                                                                                    AS StartDate,
            CAST ($$EndDate$$ AS DATE)                                                                                    AS EndDate,
            CAST (dateToLongC(TO_CHAR(CAST($$StartDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT)                  AS StartDateLong,
            CAST((dateToLongC(TO_CHAR(CAST($$EndDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id)+ 86400 * 1000)-1 AS BIGINT) AS EndDateLong
        FROM
            centers c
    )
    ,
    v_sub_change AS
    (
        SELECT DISTINCT
            s_new.OWNER_CENTER || 'p' || s_new.OWNER_ID AS PersonId,
            longToDate(sc.CHANGE_TIME)                  AS change_time,
            sc.employee_center||'emp'||sc.employee_id   AS employee,
            CASE
                WHEN pg_old.name = 'Off Peak'
                    AND pg_new.name = 'Standard Products'
                    AND s_old.sub_state = 3
                THEN 'Upgrading from off-peak to standard'
                WHEN pg_old.name = 'Standard Products'
                    AND pg_new.name = 'Multi Products (MS Reporting)'
                    AND s_old.sub_state = 3
                THEN 'Upgrading from standard to multi'
                WHEN pg_old.name = 'Multi Products (MS Reporting)'
                    AND pg_new.name = 'Extra Subscriptions MS'
                    AND s_old.sub_state = 3
                THEN 'Upgrading from multi to extra'
                WHEN pg_old.name = 'Off Peak'
                    AND pg_new.name = 'Extra Subscriptions MS'
                    AND s_old.sub_state = 3
                THEN 'Upgrading from off-peak to extra'
                WHEN pg_old.name = 'Standard Products'
                    AND pg_new.name = 'Extra Subscriptions MS'
                    AND s_old.sub_state = 3
                THEN 'Upgrading from standard to extra'
                WHEN pg_old.name = 'Multi Products (MS Reporting)'
                    AND pg_new.name = 'Multi Products (MS Reporting)'
                THEN 'Changing from multi to multi'
                WHEN pg_old.name = 'Multi Products (MS Reporting)'
                    AND pg_new.name = 'Standard Products'
                THEN 'Changing from multi to standard'
                WHEN pg_old.name = 'Off Peak'
                    AND pg_new.name = 'Multi Products (MS Reporting)'
                    AND s_old.sub_state = 3
                THEN 'Upgrading from off-peak to multi'
                WHEN pg_old.name = 'Standard Products'
                    AND pg_new.name = 'Off Peak'
                    AND s_old.sub_state = 4
                THEN 'Downgrading from standard to off-peak'
                WHEN pg_old.name = 'Multi Products (MS Reporting)'
                    AND pg_new.name = 'Off Peak'
                    AND s_old.sub_state = 4
                THEN 'Downgrading from multi to off-peak'
                WHEN pg_old.name = 'Extra Subscriptions MS'
                    AND pg_new.name = 'Extra Subscriptions MS'
                THEN 'Changing from extra to extra'
                WHEN pg_old.name = 'Extra Subscriptions MS'
                    AND pg_new.name = 'Multi Products (MS Reporting)'
                    AND s_old.sub_state = 4
                THEN 'Downgrading from extra to multi'
                WHEN pg_old.name = 'Extra Subscriptions MS'
                    AND pg_new.name = 'Standard Products'
                    AND s_old.sub_state = 4
                THEN 'Downgrading from extra to standard'
                WHEN pg_old.name = 'Extra Subscriptions MS'
                    AND pg_new.name = 'Off Peak'
                    AND s_old.sub_state = 4
                THEN 'Downgrading from extra to off-peak'
                ELSE NULL
            END             change_type,
            pro_old.name AS changed_from,
            pro_new.name AS changed_to,
            scl.stateid,
            rank() over (partition BY scl.center, scl.id ORDER BY scl.entry_start_time DESC) AS rnk
        FROM
            subscription_change sc
        JOIN
            subscriptions s_new
        ON
            s_new.CENTER = sc.NEW_SUBSCRIPTION_CENTER
            AND s_new.ID = sc.NEW_SUBSCRIPTION_ID
        JOIN
            params
        ON
            params.id = s_new.owner_center
        JOIN
            products pro_new
        ON
            pro_new.center = s_new.subscriptiontype_center
            AND pro_new.id = s_new.subscriptiontype_id
        JOIN
            product_and_product_group_link pglink_new
        ON
            pglink_new.product_center = pro_new.center
            AND pglink_new.product_id = pro_new.id
        JOIN
            product_group pg_new
        ON
            pg_new.id = pglink_new.product_group_id
        JOIN
            subscriptions s_old
        ON
            s_old.CENTER = sc.OLD_SUBSCRIPTION_CENTER
            AND s_old.ID = sc.OLD_SUBSCRIPTION_ID
        JOIN
            products pro_old
        ON
            pro_old.center = s_old.subscriptiontype_center
            AND pro_old.id = s_old.subscriptiontype_id
        JOIN
            product_and_product_group_link pglink_old
        ON
            pglink_old.product_center = pro_old.center
            AND pglink_old.product_id = pro_old.id
        JOIN
            product_group pg_old
        ON
            pg_old.id = pglink_old.product_group_id
            /* Member should be active during time of change */
        JOIN
            STATE_CHANGE_LOG SCL
        ON
            scl.center = s_new.OWNER_CENTER
            AND scl.id = s_new.OWNER_ID
            AND SCL.ENTRY_TYPE = 1
            AND scl.entry_start_time < sc.CHANGE_TIME
        WHERE
            s_new.owner_center IN ($$Scope$$)
            AND sc.employee_center = 100
            /* Changes made by employee at center 100 and not 100emp1 */
            AND sc.employee_id != 1
            AND sc.type LIKE 'TYPE'
            AND sc.cancel_time IS NULL
            AND pg_old.name IN ('Off Peak',
                                'Standard Products',
                                'Multi Products (MS Reporting)',
                                'Extra Subscriptions MS')
            AND pg_new.name IN ('Standard Products',
                                'Multi Products (MS Reporting)',
                                'Extra Subscriptions MS',
                                'Off Peak')
            AND sc.CHANGE_TIME BETWEEN params.StartDateLong AND params.EndDateLong
            /* Member should have an active subscription during the change */
            AND EXISTS
            (
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG SCL
                WHERE
                    SCL.CENTER = s_new.CENTER
                    AND SCL.ID = s_new.ID
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.STATEID IN (2,4,
                                        8)
                    AND SCL.ENTRY_START_TIME <= sc.CHANGE_TIME
                    AND (
                        SCL.ENTRY_END_TIME IS NULL
                        OR SCL.ENTRY_END_TIME > sc.CHANGE_TIME ) )
    )
    ,
    v_sub_change_count AS
    (
        SELECT
            sub.change_type AS feature,
            SUM(
                CASE
                    WHEN sub.employee = '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN sub.employee != '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_sub_change sub
        WHERE
            sub.change_type IS NOT NULL
            AND sub.rnk = 1
            AND sub.stateid = 1
        GROUP BY
            sub.change_type
    )
    ,
    /* Count multiple freeze from member as 1 and count freeze if subscription is un freeze*/
    v_freeze AS
    (
        SELECT
            s.owner_center || 'p' || s.owner_id          AS PersonId,
            sfp.employee_center||'emp'|| sfp.employee_id AS Employee,
            'Members freezing'                           AS feature
        FROM
            subscription_freeze_period sfp
        JOIN
            subscriptions s
        ON
            s.center = sfp.subscription_center
            AND s.id = sfp.subscription_id
        JOIN
            params
        ON
            params.id = s.owner_center
        WHERE
            s.owner_center IN ($$Scope$$)
            AND sfp.employee_center = 100
            /* Changes made by employee at center 100 and not 100emp1 */
            AND sfp.employee_id != 1
            AND sfp.entry_time BETWEEN params.StartDateLong AND params.EndDateLong
        UNION
        /* Cancelled freeze and member should have an active agreement with state other then ENDED and CANCEL*/
        SELECT
            t.PersonId,
            t.Employee,
            'Un-freeze membership' AS feature
        FROM
            (
                SELECT
                    s.owner_center || 'p' || s.owner_id                        AS PersonId,
                    sfp.cancel_employee_center||'emp'|| sfp.cancel_employee_id AS Employee,
                    'Un-freeze membership'                                     AS feature,
                    acl.state,
                    rank() over (partition BY acl.agreement_center, acl.agreement_id, acl.agreement_subid ORDER BY acl.entry_time DESC) AS rnk
                FROM
                    subscription_freeze_period sfp
                JOIN
                    subscriptions s
                ON
                    s.center = sfp.subscription_center
                    AND s.id = sfp.subscription_id
                JOIN
                    params
                ON
                    params.id = s.owner_center
                JOIN
                    account_receivables ar
                ON
                    ar.customercenter = s.owner_center
                    AND ar.customerid = s.owner_id
                    AND ar.ar_type = 4
                JOIN
                    payment_agreements pag
                ON
                    pag.center = ar.center
                    AND pag.id = ar.id
                JOIN
                    agreement_change_log acl
                ON
                    acl.agreement_center = pag.center
                    AND acl.agreement_id = pag.id
                    AND acl.agreement_subid = pag.subid
                WHERE
                    s.owner_center IN ($$Scope$$)
                    AND sfp.cancel_employee_center = 100
                    /* Changes made by employee at center 100 and not 100emp1 */
                    AND sfp.cancel_employee_id != 1
                    AND sfp.state = 'CANCELLED'
                    AND sfp.cancel_time BETWEEN params.StartDateLong AND params.EndDateLong
                    AND acl.entry_time <= sfp.cancel_time ) t
        WHERE
            t.rnk = 1
            AND t.state IN (1,2,4,9,11,12,13,14,15,16,17)
    )
    ,
    v_freeze_count AS
    (
        SELECT
            f1.feature AS feature,
            SUM(
                CASE
                    WHEN f1.employee = '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN f1.employee != '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_freeze f1
        GROUP BY
            f1.feature
    )
    ,
    v_personchange AS
    (
        SELECT
            PersonId,
            Employee,
            CAST (feature AS TEXT) AS feature
        FROM
            (
                SELECT
                    pcl.person_center || 'p' || pcl.person_id       AS PersonId,
                    pcl.employee_center || 'emp' || pcl.employee_id AS Employee,
                    'Update personal details'                       AS feature,
                    scl.stateid,
                    rank() over (partition BY scl.center, scl.id ORDER BY scl.entry_start_time DESC) AS rnk
                FROM
                    PERSON_CHANGE_LOGS pcl
                JOIN
                    PERSON_CHANGE_LOGS prepcl
                ON
                    prepcl.id = pcl.previous_entry_id
                    AND trim(prepcl.new_value) != trim(pcl.new_value)
                JOIN
                    subscriptions s
                ON
                    s.owner_center = pcl.person_center
                    AND s.owner_id = pcl.person_id
                JOIN
                    params
                ON
                    params.id = pcl.person_center
                    /* Member should be active during time of change */
                JOIN
                    STATE_CHANGE_LOG SCL
                ON
                    scl.center = s.OWNER_CENTER
                    AND scl.id = s.OWNER_ID
                    AND SCL.ENTRY_TYPE = 1
                    AND scl.entry_start_time < pcl.ENTRY_TIME
                WHERE
                    pcl.CHANGE_ATTRIBUTE IN ('E_MAIL',
                                             'MOB_PHONE')
                    AND pcl.employee_center = 100
                    /* Changes made by employee at center 100 and not 100emp1 */
                    AND pcl.employee_id != 1
                    AND pcl.ENTRY_TIME BETWEEN params.StartDateLong AND params.EndDateLong
                    AND pcl.person_center IN ($$Scope$$)
                    /* Member should have an active subscription during the change */
                    AND EXISTS
                    (
                        SELECT
                            1
                        FROM
                            STATE_CHANGE_LOG SCL
                        WHERE
                            SCL.CENTER = s.CENTER
                            AND SCL.ID = s.ID
                            AND SCL.ENTRY_TYPE = 2
                            AND SCL.STATEID IN (2,4,
                                                8)
                            AND SCL.ENTRY_START_TIME <= pcl.ENTRY_TIME
                            AND (
                                SCL.ENTRY_END_TIME IS NULL
                                OR SCL.ENTRY_END_TIME > pcl.ENTRY_TIME ) ) ) t
        WHERE
            rnk = 1
            AND stateid = 1
    )
    ,
    v_personchange_count AS
    (
        SELECT
            personchange.feature AS feature,
            SUM(
                CASE
                    WHEN personchange.employee = '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN personchange.employee != '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_personchange personchange
        GROUP BY
            personchange.feature
    )
    ,
    v_transfer_mem AS
    (
        SELECT
            scl.center,
            scl.id,
            scl.employee_center || 'emp' || scl.employee_id AS Employee,
            scl.ENTRY_START_TIME
        FROM
            STATE_CHANGE_LOG SCL
        JOIN
            params
        ON
            params.id = scl.center
        WHERE
            scl.employee_center = 100
            /* Changes made by employee at center 100 and not 100emp1 */
            AND scl.employee_id != 1
            AND scl.ENTRY_START_TIME >= params.StartDateLong
            AND scl.ENTRY_START_TIME <= params.EndDateLong
            AND scl.center IN ($$Scope$$)
            AND SCL.ENTRY_TYPE = 1
            AND SCL.STATEID = 4
    )
    ,
    v_transfer AS
    (
        SELECT DISTINCT
            transfer.PersonId,
            transfer.Employee,
            CAST ('Transfer member' AS TEXT) AS feature
        FROM
            (
                SELECT
                    t.center || 'p' || t.id AS PersonId,
                    t.Employee,
                    longtodatec(t.ENTRY_START_TIME, scl.center) AS EntryTime,
                    scl.stateid,
                    rank() over (partition BY scl.center, scl.id ORDER BY scl.entry_start_time DESC) AS rnk
                FROM
                    v_transfer_mem t
                JOIN
                    STATE_CHANGE_LOG SCL
                ON
                    scl.center = t.center
                    AND scl.id = t.id
                    AND SCL.ENTRY_TYPE = 1
                    AND scl.entry_start_time < t.entry_start_time )transfer
        WHERE
            transfer.stateid = 1
            AND transfer.rnk = 1
    )
    ,
    v_transfer_count AS
    (
        SELECT
            trans.feature,
            SUM(
                CASE
                    WHEN trans.employee = '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN trans.employee != '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_transfer trans
        GROUP BY
            trans.feature
    )
    ,
    v_deduction_change AS
    (
        SELECT
            ar.customercenter || 'p' || ar.customerid       AS PersonId,
            acl.employee_center || 'emp' || acl.employee_id AS Employee,
            CAST('Amend direct debit date' AS TEXT)         AS feature
        FROM
            account_receivables ar
        JOIN
            persons p
        ON
            p.center = ar.customercenter
            AND p.id = ar.customerid
            AND p.status NOT IN (2)
        JOIN
            params
        ON
            params.id = p.center
        JOIN
            payment_agreements pag
        ON
            pag.center = ar.center
            AND pag.id = ar.id
        JOIN
            agreement_change_log acl
        ON
            acl.agreement_center = pag.center
            AND acl.agreement_id = pag.id
            AND acl.agreement_subid = pag.subid
            AND acl.employee_center || 'emp' || acl.employee_id NOT IN ('100emp1')
        JOIN
            state_change_log scl
        ON
            scl.center = p.center
            AND scl.id = p.id
            AND scl.entry_type = 1
            AND scl.stateid = 1
            AND acl.entry_time BETWEEN scl.entry_start_time AND COALESCE(scl.entry_end_time, acl.entry_time)
        WHERE
            ar.ar_type = 4
            AND ar.customercenter IN ($$Scope$$)
            AND acl.employee_center = 100
            /* Changes made by employee at center 100 and not 100emp1 */
            AND acl.employee_id != 1
            AND acl.entry_time BETWEEN params.StartDateLong AND params.EndDateLong
            AND acl.text LIKE 'Deduction day change%'
    )
    ,
    v_dedchange_count AS
    (
        SELECT
            agreement.feature,
            SUM(
                CASE
                    WHEN agreement.employee = '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN agreement.employee != '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_deduction_change agreement
        GROUP BY
            agreement.feature
    )
    ,
    bank_change AS
    (
        SELECT
            ar.customercenter,
            ar.customerid,
            pag.center,
            pag.id,
            pag.subid,
            pag.bank_account_details,
            pag.creation_time,
            CASE
                WHEN LAG(pag.bank_account_details) over (partition BY ar.center,ar.id ORDER BY pag.creation_time) != pag.bank_account_details
                THEN 1
                ELSE 0
            END AS IS_CHANGE
        FROM
            account_receivables ar
        JOIN
            payment_agreements pag
        ON
            pag.center = ar.center
            AND pag.id = ar.id
        WHERE
            ar.customercenter IN ($$Scope$$)
            AND ar.ar_type = 4
    )
    ,
    v_bank_change AS
    (
        SELECT DISTINCT
            customercenter || 'p' || customerid     AS PersonId,
            employee_center || 'emp' || employee_id AS Employee,
            CAST('Amend bank details' AS TEXT)      AS feature
        FROM
            (
                SELECT
                    v_bank.customercenter,
                    v_bank.customerid,
                    acl.employee_center,
                    acl.employee_id,
                    acl.entry_time,
                    rank() over (partition BY acl.agreement_center, acl.agreement_id, acl.agreement_subid ORDER BY acl.entry_time) AS rnk,
                    longtodatec(acl.entry_time, v_bank.customercenter)                                                             AS entrytime,
                    v_bank.creation_time,
                    acl.entry_time AS ACl_ENTRY
                FROM
                    bank_change v_bank
                JOIN
                    params
                ON
                    params.id = v_bank.customercenter
                JOIN
                    agreement_change_log acl
                ON
                    acl.agreement_center = v_bank.center
                    AND acl.agreement_id = v_bank.id
                    AND acl.agreement_subid = v_bank.subid
                    AND acl.state = 1
                WHERE
                    v_bank.creation_time BETWEEN params.StartDateLong AND params.EndDateLong
                    AND v_bank.IS_CHANGE = 1 ) t
        WHERE
            rnk = 1
            AND employee_center = 100
            /* Changes made by employee at center 100 and not 100emp1 */
            AND employee_id != 1
            /* Member should be active during time of change */
            AND EXISTS
            (
                SELECT
                    1
                FROM
                    state_change_log scl
                WHERE
                    scl.center = customercenter
                    AND scl.id = customerid
                    AND scl.entry_type = 1
                    AND scl.stateid = 1
                    AND entry_time BETWEEN scl.entry_start_time AND COALESCE(scl.entry_end_time, entry_time))
    )
    ,
    v_bankchange_count AS
    (
        SELECT
            bankch.feature,
            SUM(
                CASE
                    WHEN bankch.employee = '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN bankch.employee != '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_bank_change bankch
        GROUP BY
            bankch.feature
    )
    ,
    v_debtonline AS
    (
        SELECT
            j.person_center||'p'||j.person_id       AS PersonId,
            j.creatorcenter || 'emp' || j.creatorid AS Employee,
            CAST('Pay debt on-line' AS TEXT)        AS feature
        FROM
            journalentries j
        JOIN
            params
        ON
            params.id = j.person_center
        WHERE
            j.person_center IN ($$Scope$$)
            AND j.creatorcenter = 100
            /* Changes made by employee at center 100 and not 100emp1 */
            AND j.creatorid != 1
            AND j.jetype = 3
            AND j.name IN ('Debt Payment Sage Pay',
                           'Debt Payment')
            AND j.creation_time BETWEEN params.StartDateLong AND params.EndDateLong
    )
    ,
    v_debtonline_count AS
    (
        SELECT
            debt.feature,
            SUM(
                CASE
                    WHEN debt.employee = '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN debt.employee != '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_debtonline debt
        GROUP BY
            debt.feature
    )
    ,
    v_bolton AS
    (
        SELECT DISTINCT
            s.owner_center || 'p' || s.owner_id                           AS PersonId,
            longtodatec(sa.creation_time, sa.center_id)                   AS creation_time,
            sa.employee_creator_center || 'emp' || sa.employee_creator_id AS Employee,
            CAST('Add or cancel a Bolt on' AS TEXT)                       AS feature
        FROM
            SUBSCRIPTION_ADDON sa
        JOIN
            masterproductregister m
        ON
            sa.addon_product_id = m.id
        JOIN
            products prod
        ON
            m.globalid = prod.globalid
        JOIN
            product_and_product_group_link pglink
        ON
            pglink.product_center = prod.center
            AND pglink.product_id = prod.id
        JOIN
            product_group pg
        ON
            pg.id = pglink.product_group_id
        JOIN
            subscriptions s
        ON
            sa.subscription_center= s.CENTER
            AND sa.subscription_id = s.id
        JOIN
            params
        ON
            params.id = s.owner_center
        WHERE
            s.owner_center IN ($$Scope$$)
            AND sa.employee_creator_center = 100
            /* Changes made by employee at center 100 and not 100emp1 */
            AND sa.employee_creator_id != 1
            AND pg.NAME IN( 'Add-ons')
            AND sa.creation_time BETWEEN params.StartDateLong AND params.EndDateLong
    )
    ,
    v_bolton_count AS
    (
        SELECT
            bolton.feature,
            SUM(
                CASE
                    WHEN bolton.employee = '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN bolton.employee != '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_bolton bolton
        GROUP BY
            bolton.feature
    )
    ,
    v_class AS
    (
        SELECT DISTINCT
            sales.owner_center || 'p' || sales.owner_id         AS PersonId,
            sales.employee_center || 'emp' || sales.employee_id AS Employee,
            CAST('Add a course' AS TEXT)                        AS feature
        FROM
            SUBSCRIPTION_SALES sales
        JOIN
            params
        ON
            params.id = sales.owner_center
        JOIN
            SUBSCRIPTIONS sub
        ON
            sales.SUBSCRIPTION_CENTER = sub.CENTER
            AND sales.SUBSCRIPTION_ID = sub.ID
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.center = sales.SUBSCRIPTION_TYPE_CENTER
            AND st.id = sales.SUBSCRIPTION_TYPE_ID
        JOIN
            products prod
        ON
            prod.center = st.center
            AND prod.id = st.id
        JOIN
            product_and_product_group_link pglink
        ON
            pglink.product_center = prod.center
            AND pglink.product_id = prod.id
        JOIN
            product_group pg
        ON
            pg.id = pglink.product_group_id
        WHERE
            sales.owner_center IN ($$Scope$$)
            AND sales.employee_center = 100
            /* Changes made by employee at center 100 and not 100emp1 */
            AND sales.employee_id != 1
            AND sales.sales_date BETWEEN params.StartDate AND params.EndDate
            AND prod.ptype IN (10)
            AND pg.name = 'Courses'
            AND sub.state IN (2,3,4,8)
        UNION
        SELECT DISTINCT
            c.owner_center || 'p' || c.owner_id         AS PersonId,
            i.employee_center || 'emp' || i.employee_id AS Employee,
            CAST('Add a course' AS TEXT)                AS feature
        FROM
            INVOICES I
        JOIN
            invoice_lines_mt IL
        ON
            I.CENTER=IL.CENTER
            AND I.ID=IL.ID
        JOIN
            CLIPCARDS C
        ON
            IL.CENTER=C.INVOICELINE_CENTER
            AND IL.ID=C.INVOICELINE_ID
            AND IL.SUBID=C.INVOICELINE_SUBID
        JOIN
            params
        ON
            params.id = c.owner_center
        JOIN
            products prod
        ON
            prod.center = IL.PRODUCTCENTER
            AND prod.id = IL.PRODUCTID
        JOIN
            product_and_product_group_link pglink
        ON
            pglink.product_center = prod.center
            AND pglink.product_id = prod.id
        JOIN
            product_group pg
        ON
            pg.id = pglink.product_group_id
        WHERE
            prod.ptype IN (4)
            AND i.employee_center = 100
            /* Changes made by employee at center 100 and not 100emp1 */
            AND i.employee_id != 1
            AND pg.name = 'Courses'
            AND c.owner_center IN ($$Scope$$)
            AND I.TRANS_TIME BETWEEN params.StartDateLong AND params.EndDateLong
    )
    ,
    v_class_count AS
    (
        SELECT
            class.feature,
            SUM(
                CASE
                    WHEN class.employee = '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN class.employee != '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_class class
        GROUP BY
            class.feature
    )
    ,
    v_pin AS
    (
        SELECT
            m.center || 'p' || m.id      AS PersonId,
            NULL                         AS Employee,
            CAST('PIN Reminder' AS TEXT) AS feature
        FROM
            messages m
        JOIN
            params
        ON
            params.id = m.center
        WHERE
            m.subject = 'PIN Reminder'
            AND m.center IN ($$Scope$$)
            AND m.senttime BETWEEN params.StartDateLong AND params.EndDateLong
    )
    ,
    v_pin_count AS
    (
        SELECT
            pin.feature,
            SUM(
                CASE
                    WHEN pin.employee IS NULL
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN pin.employee IS NOT NULL
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_pin pin
        GROUP BY
            pin.feature
    )
SELECT
    *
FROM
    v_sub_change_count
UNION ALL
SELECT
    *
FROM
    v_freeze_count
UNION ALL
SELECT
    *
FROM
    v_personchange_count
UNION ALL
SELECT
    *
FROM
    v_transfer_count
UNION ALL
SELECT
    *
FROM
    v_dedchange_count
UNION ALL
SELECT
    *
FROM
    v_bankchange_count
UNION ALL
SELECT
    *
FROM
    v_debtonline_count
UNION ALL
SELECT
    *
FROM
    v_bolton_count
UNION ALL
SELECT
    *
FROM
    v_class_count
UNION ALL
SELECT
    *
FROM
    v_pin_count