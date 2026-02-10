-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    CONTACT_PERSON AS
    (
        SELECT
            p.fullname,
            r.center,
            r.id,
            email.txtvalue AS email,
            work_phone.txtvalue as work_phone
        FROM
            PERSONS p
        JOIN
            RELATIVES r
        ON
            r.relativecenter = p.center
        AND r.relativeid = p.id
        AND r.rtype = 7
        AND r.status = 1
        LEFT JOIN
            person_ext_attrs email
        ON
            email.personcenter = p.center
        AND email.personid = p.id
        AND email.name = '_eClub_Email'
        
        LEFT JOIN
        person_ext_attrs work_phone
        ON
        work_phone.personcenter = p.center
        AND work_phone.personid = p.id
        AND work_phone.name = '_eClub_PhoneWork'
    )
SELECT DISTINCT
    comp.CENTER || 'p' || comp.ID AS "Company ID",
    comp.LASTNAME                 AS "Company",
    comp_email.txtvalue           AS "Company Email",
    comp_mobile.txtvalue          AS "Company Mobile Phone",
    con_per.fullname            AS "Contact Person",
    con_per.work_phone          AS "Contact Work Phone",
    con_per.email               AS "Contact Person Email",
    comp.address1,
    comp.address2,
    comp.address3,
    comp.ZIPCODE,
    comp_invoice_email.txtvalue             AS "Invoice Email",
    comp_comment.txtvalue                   AS "Comment",
    ca.center ||'p'||ca.id||'rpt'||ca.subid AS "Agreement ID",
    ca.NAME                                 AS "Company Agreement",
    CASE
        WHEN ca.STATE = 0
        THEN 'Under target'
        WHEN ca.STATE = 1
        THEN 'Active'
        WHEN ca.STATE = 2
        THEN 'Stop new'
        WHEN ca.STATE = 3
        THEN 'Old'
        WHEN ca.STATE = 4
        THEN 'Awaiting activation'
        WHEN ca.STATE = 5
        THEN 'Blocked'
        WHEN ca.STATE = 6
        THEN 'Deleted'
    END                     AS "Agreement State",
    ca.stop_new_date        AS "Stop New Joins Date",
    c.NAME                  AS "Club",
    p.CENTER || 'p' || p.ID AS "Person Id",
    CASE p.STATUS
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
    END AS "Person Status",
    p.FIRSTNAME,
    p.LASTNAME,
    S.ID AS "Sub ID",
    pr.NAME "Subscription",
    s.START_DATE AS "Subscription Start Date",
    s.END_DATE   AS "Subscription End Date",
    CASE
        WHEN st.ST_TYPE = 0
        THEN 'Cash'
        WHEN st.ST_TYPE = 1
        THEN 'EFT'
        WHEN st.ST_TYPE = 3
        THEN 'Prospect'
        ELSE 'Unknown'
    END AS "Subscription Type",
    CASE s.STATE
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
    END AS "Subscription State",
    (
        CASE
            WHEN TRUNC(FROM_DATE, 'MONTH')= FROM_DATE
            AND LAST_DAY(FROM_DATE)=TO_DATE
            THEN il.TOTAL_AMOUNT
            ELSE (il.TOTAL_AMOUNT/(il.TOTAL_AMOUNT+COALESCE(spons_il.TOTAL_AMOUNT,0)))*
                spp.SUBSCRIPTION_PRICE
        END) AS "Member Monthly Fee",
    (
        CASE
            WHEN TRUNC(FROM_DATE, 'MONTH')= FROM_DATE
            AND LAST_DAY(FROM_DATE)=TO_DATE
            THEN COALESCE(spons_il.TOTAL_AMOUNT,0)
            ELSE (COALESCE(spons_il.TOTAL_AMOUNT,0)/(COALESCE(spons_il.TOTAL_AMOUNT,0)+
                il.TOTAL_AMOUNT))* spp.SUBSCRIPTION_PRICE
        END) AS "Member fee sponsored",
    s.BINDING_END_DATE "Expiry Date"
FROM
    PERSONS p
JOIN
    CENTERS c
ON
    p.CENTER=c.ID
JOIN
    SUBSCRIPTIONS s
ON
    p.CENTER = s.OWNER_CENTER
AND p.ID = s.OWNER_ID
AND s.STATE IN (:subState)
JOIN
    SUBSCRIPTIONTYPES st
ON
    s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
AND s.SUBSCRIPTIONTYPE_ID = st.ID --AND st.ST_TYPE NOT IN (0)
JOIN
    PRODUCTS pr
ON
    st.CENTER = pr.CENTER
AND st.ID = pr.ID
JOIN
    RELATIVES r
ON
    r.CENTER = s.OWNER_CENTER
AND r.id = s.owner_ID
AND r.RTYPE IN (3)
AND r.STATUS<3
JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = r.RELATIVECENTER
AND ca.ID = r.RELATIVEID
AND ca.SUBID = r.RELATIVESUBID
JOIN
    PERSONS comp
ON
    comp.center = ca.CENTER
AND comp.id=ca.ID
LEFT JOIN
    person_ext_attrs comp_email
ON
    comp_email.personcenter = comp.center
AND comp_email.personid = comp.id
AND comp_email.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs comp_mobile
ON
    comp_mobile.personcenter = comp.center
AND comp_mobile.personid = comp.id
AND comp_mobile.name = '_eClub_PhoneSMS'
LEFT JOIN
    person_ext_attrs comp_invoice_email
ON
    comp_invoice_email.personcenter = comp.center
AND comp_invoice_email.personid = comp.id
AND comp_invoice_email.name = '_eClub_InvoiceEmail'
LEFT JOIN
    person_ext_attrs comp_comment
ON
    comp_comment.personcenter = comp.center
AND comp_comment.personid = comp.id
AND comp_comment.name = '_eClub_Comment'

LEFT JOIN
CONTACT_PERSON con_per
ON
con_per.center = comp.center
AND con_per.id = comp.id

LEFT JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER=s.CENTER
AND spp.ID=s.ID
AND spp.FROM_DATE<=CURRENT_DATE
AND spp.TO_DATE>=CURRENT_DATE-1
AND SPP_STATE NOT IN (2)
JOIN
    SPP_INVOICELINES_LINK sppl
ON
    sppl.PERIOD_CENTER=spp.CENTER
AND sppl.PERIOD_ID=spp.ID
AND sppl.PERIOD_SUBID=spp.SUBID
JOIN
    INVOICELINES il
ON
    il.CENTER = sppl.INVOICELINE_CENTER
AND il.ID=sppl.INVOICELINE_ID
AND il.SUBID=sppl.INVOICELINE_SUBID
JOIN
    INVOICES i
ON
    i.center= il.center
AND i.id = il.id
JOIN
    PRODUCTS pd
ON
    pd.center = il.PRODUCTCENTER
AND pd.id = il.PRODUCTID
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
ON
    pgl.PRODUCT_CENTER = pd.CENTER
AND pgl.PRODUCT_ID = pd.id
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = pgl.PRODUCT_GROUP_ID
AND pg.name IN ('Corporate',
                'Partnership',
                'Corporate Funded')
LEFT JOIN
    INVOICES spons_i
ON
    spons_i.center = i.SPONSOR_INVOICE_CENTER
AND spons_i.ID = i.SPONSOR_INVOICE_ID
LEFT JOIN
    INVOICELINES spons_il
ON
    spons_il.center = spons_i.center
AND spons_il.id = spons_i.id
AND spons_il.subid = il.SPONSOR_INVOICE_SUBID
WHERE
    comp.CENTER IN (:scope)
AND spp.SUBSCRIPTION_PRICE > 0
AND p.STATUS IN (1,3)
AND p.PERSONTYPE = 4
ORDER BY
    comp.LASTNAME