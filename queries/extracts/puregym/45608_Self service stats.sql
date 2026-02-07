WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$StartDate$$                                                                                 AS StartDate,
            $$EndDate$$                                                                                 AS EndDate,
            datetolongTZ(TO_CHAR($$StartDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/London')                   AS StartDateLong,
            (datetolongTZ(TO_CHAR($$EndDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/London')+ 86400 * 1000)-1 AS EndDateLong
        FROM
            dual
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
                    AND pg_new.name = 'Standard Products' AND s_old.sub_state = 3
                THEN 'Upgrading from off-peak to standard'
                WHEN pg_old.name = 'Standard Products'
                    AND pg_new.name = 'Multi Products (MS Reporting)' AND s_old.sub_state = 3
                THEN 'Upgrading from standard to multi'
                WHEN pg_old.name = 'Multi Products (MS Reporting)'
                    AND pg_new.name = 'Extra Subscriptions MS' AND s_old.sub_state = 3
                THEN 'Upgrading from multi to extra'
                WHEN pg_old.name = 'Off Peak'
                    AND pg_new.name = 'Extra Subscriptions MS' AND s_old.sub_state = 3
                THEN 'Upgrading from off-peak to extra'
                WHEN pg_old.name = 'Standard Products'
                    AND pg_new.name = 'Extra Subscriptions MS' AND s_old.sub_state = 3
                THEN 'Upgrading from standard to extra'
                WHEN pg_old.name = 'Multi Products (MS Reporting)'
                    AND pg_new.name = 'Multi Products (MS Reporting)'
                THEN 'Changing from multi to multi'
                WHEN pg_old.name = 'Multi Products (MS Reporting)'
                    AND pg_new.name = 'Standard Products'
                THEN 'Changing from multi to standard'				
                ELSE NULL
            END             change_type,
            pro_old.name AS changed_from,
            pro_new.name AS changed_to
        FROM
            subscription_change sc
        CROSS JOIN
            params
        JOIN
            subscriptions s_new
        ON
            s_new.CENTER = sc.NEW_SUBSCRIPTION_CENTER
            AND s_new.ID = sc.NEW_SUBSCRIPTION_ID
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
        WHERE
            s_new.owner_center IN ($$Scope$$)
            AND sc.type LIKE 'TYPE'
            AND sc.cancel_time IS NULL
            AND pg_old.name IN ('Off Peak',
                                'Standard Products',
                                'Multi Products (MS Reporting)')
            AND pg_new.name IN ('Standard Products',
                                'Multi Products (MS Reporting)',
                                'Extra Subscriptions MS')
            AND sc.CHANGE_TIME BETWEEN params.StartDateLong AND params.EndDateLong
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
        GROUP BY
            sub.change_type
    )
    ,
    v_freeze AS
    (
        SELECT
            s.owner_center || 'p' || s.owner_id AS PersonId,
            CASE
                WHEN sfp.state = 'ACTIVE'
                THEN 'Members freezing'
                ELSE 'Un-freeze membership'
            END                                          AS feature,
            sfp.employee_center||'emp'|| sfp.employee_id AS employee
        FROM
            subscription_freeze_period sfp
        CROSS JOIN
            params
        JOIN
            subscriptions s
        ON
            s.center = sfp.subscription_center
            AND s.id = sfp.subscription_id
        WHERE
            s.owner_center IN ($$Scope$$)
            AND sfp.entry_time BETWEEN params.StartDateLong AND params.EndDateLong
        GROUP BY
            s.owner_center,
            s.owner_id,
            sfp.state,
            sfp.employee_center||'emp'|| sfp.employee_id
    )
    ,
    v_freeze_count AS
    (
        SELECT
            freeze.feature AS feature,
            SUM(
                CASE
                    WHEN freeze.employee = '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN freeze.employee != '100emp17401'
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_freeze freeze
        GROUP BY
            freeze.feature
    )
    ,
    v_personchange AS
    (
        SELECT
            pcl.person_center || 'p' || pcl.person_id       AS PersonId,
            pcl.employee_center || 'emp' || pcl.employee_id AS Employee,
            CASE
                WHEN pcl.CHANGE_ATTRIBUTE = '_eClub_TransferredFromId'
                THEN 'Transfer member'
                ELSE 'Update personal details'
            END AS feature
        FROM
            PERSON_CHANGE_LOGS pcl
        JOIN 
            PERSON_CHANGE_LOGS prepcl
        ON
             prepcl.id = pcl.previous_entry_id
             AND prepcl.new_value != pcl.new_value			
        CROSS JOIN
            params
        WHERE
            pcl.CHANGE_ATTRIBUTE IN ('E_MAIL',
                                     'MOB_PHONE',
                                     '_eClub_TransferredFromId')
            AND pcl.ENTRY_TIME BETWEEN params.StartDateLong AND params.EndDateLong
            AND pcl.person_center IN ($$Scope$$)
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
    v_deduction_change AS
    (
        SELECT
            ar.customercenter || 'p' || ar.customerid       AS PersonId,
            acl.employee_center || 'emp' || acl.employee_id AS Employee,
            'Amend direct debit date'                       AS feature
        FROM
            account_receivables ar
        JOIN
            persons p
        ON
            p.center = ar.customercenter
            AND p.id = ar.customerid
            AND p.status NOT IN (2)
        CROSS JOIN
            params
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
            AND acl.entry_time BETWEEN scl.entry_start_time AND NVL(scl.entry_end_time, acl.entry_time)					
        WHERE
            ar.ar_type = 4
            AND ar.customercenter IN ($$Scope$$)
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
			v_bank.customercenter || 'p' || v_bank.customerid AS PersonId,
			acl.employee_center || 'emp' || acl.employee_id   AS Employee,
			'Amend bank details'                              AS feature
		FROM
			bank_change v_bank
		CROSS JOIN
			params
		JOIN
			agreement_change_log acl
		ON
			acl.agreement_center = v_bank.center
			AND acl.agreement_id = v_bank.id
			AND acl.agreement_subid = v_bank.subid
			AND acl.state = 1
		JOIN
			state_change_log scl
		ON
			scl.center = v_bank.customercenter
			AND scl.id = v_bank.customerid
			AND scl.entry_type = 1
			AND scl.stateid = 1
			AND acl.entry_time BETWEEN scl.entry_start_time AND NVL(scl.entry_end_time, acl.entry_time)			
		WHERE
			v_bank.creation_time BETWEEN params.StartDateLong AND params.EndDateLong
			AND v_bank.IS_CHANGE = 1	
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
            j.person_center||'p'||j.person_id             AS PersonId,
            longtodatec(j.creation_time, j.person_center) AS creation_time,
            j.creatorcenter || 'emp' || j.creatorid         AS Employee
        FROM
            journalentries j
        CROSS JOIN
            params
        WHERE
            j.person_center IN ($$Scope$$)
            AND j.jetype = 3
            AND j.name IN ('Debt Payment Sage Pay', 'Debt Payment')
            AND j.creation_time BETWEEN params.StartDateLong AND params.EndDateLong
    )
    ,
    v_debtonline_count AS
    (
        SELECT
            'Pay debt on-line' AS feature,
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
    )
    ,
    v_bolton AS
    (
        SELECT DISTINCT
            s.owner_center || 'p' || s.owner_id                         AS PersonId,
            longtodatec(sa.creation_time, sa.center_id)                 AS creation_time,
            sa.employee_creator_center || 'emp' || sa.employee_creator_id AS Employee
        FROM
            SUBSCRIPTION_ADDON sa
        CROSS JOIN
            params
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
        WHERE
            s.owner_center IN ($$Scope$$)
            AND pg.NAME IN( 'Add-ons')
            AND sa.creation_time BETWEEN params.StartDateLong AND params.EndDateLong
    )
    ,
    v_bolton_count AS
    (
        SELECT
            'Add or cancel a Bolt on' AS feature,
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
    )
    ,
    v_class AS
    (
		SELECT DISTINCT
			sales.owner_center || 'p' || sales.owner_id AS PersonId,
			sales.employee_center || 'emp' || sales.employee_id as Employee
		FROM
			SUBSCRIPTION_SALES sales
		CROSS JOIN
			params
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
			AND sales.sales_date BETWEEN params.StartDate AND params.EndDate
			AND prod.ptype IN (10)
			AND pg.name = 'Courses'
			AND sub.state IN (2,3,4,8)
		UNION    
		SELECT DISTINCT
			c.owner_center || 'p' || c.owner_id         AS PersonId,
			i.employee_center || 'emp' || i.employee_id AS Employee
		FROM
			INVOICES I
		CROSS JOIN
			params
		JOIN
			INVOICELINES IL
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
			AND pg.name = 'Courses'
			AND c.owner_center IN ($$Scope$$)
			AND I.TRANS_TIME BETWEEN params.StartDateLong AND params.EndDateLong    
    )
    ,
    v_class_count AS
    (
        SELECT
            'Add a course' AS feature,
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
    )
    ,
    v_pin AS
    (
        SELECT
            m.center || 'p' || m.id           AS PersonId,
            longtodatec(m.senttime, m.center) AS sent_time,
            NULL                              AS Employee
        FROM
            messages m
        CROSS JOIN
            params
        WHERE
            m.subject = 'PIN Reminder'
            AND m.center IN ($$Scope$$)
            AND m.senttime BETWEEN params.StartDateLong AND params.EndDateLong
    )
    ,
    v_pin_count AS
    (
        SELECT
            'PIN Reminder' AS feature,
            SUM(
                CASE
                    WHEN pin.employee IS NULL
                    THEN 1
                    ELSE 0
                END) AS "Online completions",
            SUM(
                CASE
                    WHEN pin.employee = '100p27001'
                    THEN 1
                    ELSE 0
                END) AS "Member services completions",
            SUM(1)   AS "Total completions"
        FROM
            v_pin pin
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