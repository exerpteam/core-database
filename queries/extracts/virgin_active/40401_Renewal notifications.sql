-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4757
SELECT
    s.center  AS CENTER,
    s.id          AS ID,
    p.center||'p'||p.id              AS PERSONKEY,
    p.firstname                      AS  FIRSTNAME,
    p.lastname                       AS LASTNAME,
    pr.name                          AS SUBSCRIPTION_NAME,
    to_char(s.START_DATE,'DD/MM/YYYY') AS START_DATE,
    to_char(s.END_DATE,'DD/MM/YYYY') AS END_DATE,
    c.PHONE_NUMBER                   AS CLUB_PHONE,
    c.SHORTNAME                      AS CLUB_NAME,
    pea_email.txtvalue               AS EMAIL
FROM
    persons p
JOIN
    subscriptions s
ON
   s.owner_center = p.center
   AND s.owner_id = p.id
   AND s.end_date = trunc(current_date) + 30
   AND s.state = 2
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND st.st_type = 0 -- only CASH subscriptions
JOIN
    PRODUCTS pr
ON
    pr.CENTER = st.center
    AND pr.ID = st.ID
JOIN
    centers c
ON
    c.ID = s.center
    AND c.COUNTRY = 'GB'
JOIN
    person_ext_attrs pea_email
ON
    pea_email.personcenter = p.center
    AND pea_email.personid = p.id
    AND pea_email.name = '_eClub_Email'
    AND pea_email.txtvalue is not null
WHERE
-- exclude corporate members
    p.persontype <> 4
    AND st.PERIODUNIT = 3  -- yearly
    AND st.PERIODCOUNT = 1 -- one year 
    AND s.subscription_price <> 0
    AND UPPER(pr.name) not like '%TEMPORARY%'
 ---exclude products in 'GymFlex' product group
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            product_and_product_group_link pl
        JOIN
            product_group pg
        ON
            pl.product_group_id = pg.id
            AND pg.Name = 'Gymflex'
        WHERE
           pl.product_center = pr.center
	   AND pl.product_id = pr.id

    )
  ---exclude members with other payer
    AND NOT EXISTS
    (
        SELECT 
           1
        FROM 
           relatives r
        WHERE
           r.RELATIVECENTER = p.CENTER
           AND r.RELATIVEID = p.ID
           AND r.RTYPE = 12
           AND r.STATUS = 1 
    )