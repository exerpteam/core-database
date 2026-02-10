-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4042
SELECT
    p.center,
    p.id,
    p.center||'p'||p.id  AS "Member ID",
    p.firstname          AS "First Name",
    pr.name              AS "Subcription name",
    s.subscription_price AS "Price",
    s.binding_end_date   AS "Binding Date",
    pea_email.txtvalue   AS "E-mail",
    z.PROVINCE           AS "Province"
FROM
    persons p
JOIN
    subscriptions s
ON
    s.owner_center = p.center
    AND s.owner_id = p.id
    --AND s.binding_end_date = CURRENT_DATE + 60
    -- TODO: the following line will be commented out when running SQL Event
   AND s.binding_end_date BETWEEN :From_Date AND :To_Date
   AND s.end_date IS NULL
   AND s.state IN (2,4,8)
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND st.st_type IN (1,2) -- only recurring subscriptions  (EFT and Clipcard)
JOIN
    PRODUCTS pr
ON
    pr.CENTER = st.center
    AND pr.ID = st.ID
JOIN
    centers c
ON
    c.ID = s.center
JOIN
    ZIPCODES z
ON
    z.COUNTRY = c.COUNTRY
    AND z.ZIPCODE = c.ZIPCODE
    AND z.CITY = c.CITY
    AND z.PROVINCE IN ('ON', 'NS', 'SK')
LEFT JOIN
    person_ext_attrs pea_email
ON
    pea_email.personcenter = p.center
    AND pea_email.personid = p.id
    AND pea_email.name = '_eClub_Email'
WHERE
 ---exclude products in 'No Renewal Notices' product group
    NOT EXISTS
    (
        SELECT
            1
        FROM
            product_and_product_group_link pl
        JOIN
            product_group pg
        ON
		    pl.product_center = pr.center
			AND pl.product_id = pr.id
            AND pl.product_group_id = pg.id
            AND pg.Name = 'No Renewal Notices'
    )
