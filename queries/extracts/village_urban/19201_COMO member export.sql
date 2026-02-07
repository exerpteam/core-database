SELECT
    t1.external_id AS memberid,
    t1.firstname   AS firstName,
    t1.lastname    AS lastName,
    email.txtvalue AS email,
    CASE t1.status
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
    END                                 AS genericString1,
    REPLACE(phone.txtvalue, '+44', '0') AS phoneNumber
FROM
    (
        SELECT
            p.center,
            p.id,
            p.external_id,
            p.firstname,
            p.lastname,
            p.STATUS
        FROM
            persons p
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        AND s.state IN (2,4)
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
            product_and_product_group_link pgl
        ON
            pgl.product_center = pr.center
        AND pgl.product_id = pr.id
        AND pgl.product_group_id IN (5,802,1401,4,801)
        JOIN
            villageurban.product_group pg
        ON
            pg.id = pgl.product_group_id
        WHERE
            p.status IN (1,3)
        UNION ALL
        SELECT
            p.center,
            p.id,
            p.external_id,
            p.firstname,
            p.lastname,
            p.STATUS
        FROM
            persons p
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        AND s.state IN (2,4)
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
            product_and_product_group_link pgl
        ON
            pgl.product_center = pr.center
        AND pgl.product_id = pr.id
        AND pgl.product_group_id IN (202)
        JOIN
            villageurban.product_group pg
        ON
            pg.id = pgl.product_group_id
        WHERE
            p.status = 1 ) t1
LEFT JOIN
    person_ext_attrs email
ON
    email.personcenter = t1.center
AND email.personid = t1.id
AND email.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs phone
ON
    phone.personcenter = t1.center
AND phone.personid = t1.id
AND phone.name = '_eClub_PhoneSMS'
WHERE
t1.center IN (:scope)