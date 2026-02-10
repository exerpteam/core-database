-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-dd')-interval '3 days',
            'YYYY-MM-dd'), c.id) AS BIGINT) AS from_date,
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-dd')+interval '1 days',
            'YYYY-MM-dd'), c.id) AS BIGINT)                              AS to_date,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-dd')-interval '3 days' AS sub_date,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-dd')                   AS cut_date,
            c.id                                                         AS center_id
        FROM
            centers c
    )
SELECT
    t1.external_id AS "External ID",
    t1.firstname   AS "First Name",
    t1.lastname    AS "Last Name",
    t1.email_addr  AS "Business Email",
    t1.email_addr  AS "Personal Email",
    t1.mobile_no   AS "Mobile Number",
    CASE t1.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END            AS PERSON_STATUS,
    t1.center_id   AS "Location Reference Code",
    t1.center_name AS "Location Name",
    t1.address1    AS "Home Address",
    t1.zipcode,
    t1.city,
    t1.country,
    CASE t1.sub_state
        WHEN 2
        THEN 'ACTIVE'
        WHEN 3
        THEN 'ENDED'
        WHEN 4
        THEN 'FROZEN'
        WHEN 7
        THEN 'WINDOW'
        WHEN 8
        THEN 'CREATED'
        ELSE 'Undefined'
    END                       AS "Subscription State",
    t1.start_date             AS "Subscription Start Date",
    t1.end_date               AS "Subscription End Date",
    t1.name                   AS "Subscription Product Type",
    SUM(art.unsettled_amount) AS "Debt Amount"
FROM
    (
        SELECT DISTINCT
            p.center,
            p.id,
            p.external_id,
            p.firstname,
            p.lastname,
            email.txtvalue  AS email_addr,
            mobile.txtvalue AS mobile_no,
            p.status,
            c.id   AS center_id,
            c.name AS center_name,
            p.address1,
            p.zipcode,
            p.city,
            p.country,
            t.state AS sub_state,
            t.start_date,
            t.end_date,
            t.name
        FROM
            persons p
        JOIN
        (SELECT
            rank() over(partition BY s.owner_center, s.owner_id ORDER BY s.start_date
            ASC) AS rnk,
            s.owner_center,
            s.owner_id,
            s.start_date,
            s.end_date,
            s.state,
            pr.name
        FROM
            subscriptions s
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        JOIN
            product_and_product_group_link prgl
        ON
            prgl.product_center = pr.center
        AND prgl.product_id = pr.id
        JOIN
            product_group pg
        ON
            pg.id = prgl.product_group_id
        WHERE
            pg.id = 13601
        AND s.state IN (2,4,8)
        ) t
        ON
        t.owner_center = p.center
        AND t.owner_id = p.id
        AND t.rnk = 1
        JOIN
            centers c
        ON
            c.id = p.center
        JOIN
            puregym.person_change_logs pcl
        ON
            pcl.person_center = p.center
        AND pcl.person_id = p.id
        JOIN
            params
        ON
            params.center_id = pcl.person_center
        LEFT JOIN
            person_ext_attrs email
        ON
            email.personcenter = p.center
        AND email.personid = p.id
        AND email.name = '_eClub_Email'
        LEFT JOIN
            person_ext_attrs mobile
        ON
            mobile.personcenter = p.center
        AND mobile.personid = p.id
        AND mobile.name = '_eClub_PhoneSMS'
        WHERE
            p.status NOT IN (4,5,7,8)
        AND pcl.change_attribute IN ('FIRST_NAME',
                                     'LAST_NAME',
                                     'E_MAIL',
                                     'MOB_PHONE',
                                     'ADDRESS_1')
        AND pcl.entry_time BETWEEN params.from_date AND params.to_date
        AND (
                t.end_date IS NULL
            OR  t.end_date >= params.sub_date)
		AND p.center IN (:scope)
        UNION
        SELECT DISTINCT
            p.center,
            p.id,
            p.external_id,
            p.firstname,
            p.lastname,
            email.txtvalue  AS email_addr,
            mobile.txtvalue AS mobile_no,
            p.status,
            c.id   AS center_id,
            c.name AS center_name,
            p.address1,
            p.zipcode,
            p.city,
            p.country,
            t.state AS sub_state,
            t.start_date,
            t.end_date,
            t.name
        FROM
            persons p
        JOIN
        (SELECT
            rank() over(partition BY s.owner_center, s.owner_id ORDER BY s.start_date
            ASC) AS rnk,
            s.owner_center,
            s.owner_id,
            s.start_date,
            s.end_date,
            s.state,
            pr.name
        FROM
            subscriptions s
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        JOIN
            product_and_product_group_link prgl
        ON
            prgl.product_center = pr.center
        AND prgl.product_id = pr.id
        JOIN
            product_group pg
        ON
            pg.id = prgl.product_group_id
        WHERE
            pg.id = 13601
        AND s.state IN (2,4,8)
        ) t
        ON
        t.owner_center = p.center
        AND t.owner_id = p.id
        AND t.rnk = 1
        JOIN
            centers c
        ON
            c.id = p.center
        JOIN
            puregym.state_change_log scl
        ON
            scl.center = p.center
        AND scl.id = p.id
        AND scl.entry_type = 1
        JOIN
            params
        ON
            params.center_id = scl.center
        LEFT JOIN
            person_ext_attrs email
        ON
            email.personcenter = p.center
        AND email.personid = p.id
        AND email.name = '_eClub_Email'
        LEFT JOIN
            person_ext_attrs mobile
        ON
            mobile.personcenter = p.center
        AND mobile.personid = p.id
        AND mobile.name = '_eClub_PhoneSMS'
            /*LEFT JOIN
            cashcollectioncases ccc
            ON
            ccc.personcenter = p.center
            AND ccc.personid = p.id
            AND ccc.closed = false
            AND missingpayment = true */
        WHERE
            p.status NOT IN (4,5,7,8)
        AND scl.entry_start_time BETWEEN params.from_date AND params.to_date
		AND p.center IN (:scope)
        UNION
        SELECT DISTINCT
            p.center,
            p.id,
            p.external_id,
            p.firstname,
            p.lastname,
            email.txtvalue  AS email_addr,
            mobile.txtvalue AS mobile_no,
            p.status,
            c.id   AS center_id,
            c.name AS center_name,
            p.address1,
            p.zipcode,
            p.city,
            p.country,
            s.state AS sub_state,
            s.start_date,
            s.end_date,
            pr.name
        FROM
            persons p
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        JOIN
            product_and_product_group_link prgl
        ON
            prgl.product_center = pr.center
        AND prgl.product_id = pr.id
        JOIN
            product_group pg
        ON
            pg.id = prgl.product_group_id
        JOIN
            centers c
        ON
            c.id = p.center
        JOIN
            puregym.state_change_log scl
        ON
            scl.center = s.center
        AND scl.id = s.id
        AND scl.entry_type = 2
        JOIN
            params
        ON
            params.center_id = scl.center
        LEFT JOIN
            person_ext_attrs email
        ON
            email.personcenter = p.center
        AND email.personid = p.id
        AND email.name = '_eClub_Email'
        LEFT JOIN
            person_ext_attrs mobile
        ON
            mobile.personcenter = p.center
        AND mobile.personid = p.id
        AND mobile.name = '_eClub_PhoneSMS'
            /*LEFT JOIN
            cashcollectioncases ccc
            ON
            ccc.personcenter = p.center
            AND ccc.personid = p.id
            AND ccc.closed = false
            AND missingpayment = true */
        WHERE
            pg.id = 13601
        AND p.status NOT IN (4,5,7,8)
        AND scl.entry_start_time BETWEEN params.from_date AND params.to_date
		AND p.center IN (:scope)
        AND NOT EXISTS
        (SELECT
        1
        FROM
        subscriptions sub
        WHERE
        sub.state = 2
        AND sub.owner_center = s.owner_center
        AND sub.owner_id = s.owner_id
        )
        UNION
        SELECT DISTINCT
            p.center,
            p.id,
            p.external_id,
            p.firstname,
            p.lastname,
            email.txtvalue  AS email_addr,
            mobile.txtvalue AS mobile_no,
            p.status,
            c.id   AS center_id,
            c.name AS center_name,
            p.address1,
            p.zipcode,
            p.city,
            p.country,
            s.state AS sub_state,
            s.start_date,
            s.end_date,
            pr.name
        FROM
            persons p
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        JOIN
            product_and_product_group_link prgl
        ON
            prgl.product_center = pr.center
        AND prgl.product_id = pr.id
        JOIN
            product_group pg
        ON
            pg.id = prgl.product_group_id
        JOIN
            centers c
        ON
            c.id = p.center
        JOIN
            puregym.subscription_change sc
        ON
            sc.old_subscription_center = s.center
        AND sc.old_subscription_id = s.id
        AND sc.type = 'END_DATE'
        JOIN
            params
        ON
            params.center_id = sc.old_subscription_center
        LEFT JOIN
            person_ext_attrs email
        ON
            email.personcenter = p.center
        AND email.personid = p.id
        AND email.name = '_eClub_Email'
        LEFT JOIN
            person_ext_attrs mobile
        ON
            mobile.personcenter = p.center
        AND mobile.personid = p.id
        AND mobile.name = '_eClub_PhoneSMS'
            /*LEFT JOIN
            cashcollectioncases ccc
            ON
            ccc.personcenter = p.center
            AND ccc.personid = p.id
            AND ccc.closed = false
            AND missingpayment = true */
        WHERE
            pg.id = 13601
        AND p.status NOT IN (4,5,7,8)
        AND sc.change_time BETWEEN params.from_date AND params.to_date
		AND p.center IN (:scope)
        AND NOT EXISTS
        (SELECT
        1
        FROM
        subscriptions sub
        WHERE
        sub.state = 2
        AND sub.owner_center = s.owner_center
        AND sub.owner_id = s.owner_id
        ) ) t1
JOIN
    params
ON
    params.center_id = t1.center
JOIN
    puregym.account_receivables ar
ON
    ar.customercenter = t1.center
AND ar.customerid = t1.id
LEFT JOIN
    ar_trans art
ON
    art.center = ar.center
AND art.id = ar.id
AND ar.balance < 0
AND art.unsettled_amount != 0
AND art.due_date < params.cut_date
GROUP BY
    t1.external_id,
    t1.firstname,
    t1.lastname,
    t1.email_addr,
    t1.mobile_no,
    t1.status,
    t1.center_id,
    t1.center_name,
    t1.address1,
    t1.zipcode,
    t1.city,
    t1.country,
    t1.sub_state,
    t1.start_date,
    t1.end_date,
    t1.name