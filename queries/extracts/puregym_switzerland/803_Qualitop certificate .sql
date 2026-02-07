WITH
    params AS materialized
    (
        SELECT
            CAST(:period_from AS DATE) AS period_from_date,
            CAST(:period_to AS DATE)   AS period_to_date,
            CAST(datetolongc(TO_CHAR(:period_from ::DATE ,'YYYY-MM-DD') ,:member_center ) AS BIGINT
            ) AS period_from_ts,
            CAST(datetolongc(TO_CHAR(:period_to ::DATE +interval '1 day','YYYY-MM-DD'),
            :member_center ) AS BIGINT) AS period_to_ts
    )
    ,
    details AS
    (
        SELECT
            ce.name                    AS head_office_name,
            ce.address1                AS head_office_address_1,
            ce.zipcode ||' '|| ce.city AS head_office_address_2,
            cea_provid.txt_value       AS provider_id,
            cea_zsr.txt_value          AS zsr,
            op.center||'p'||op.id      AS member_id,
            op.lastname                AS member_last_name,
            op.firstname               AS member_first_name,
            CASE
                WHEN op.address2 IS NOT NULL
                AND op.address2 != ''
                THEN op.address1||', '||op.address2
                ELSE op.address1
            END        AS member_street,
            op.zipcode AS member_zip,
            op.city    AS member_city,
            c.city     AS home_city,
            --            s.center||'s'||s.id AS subscription_id,
            MIN(s.start_date) AS start_date ,
            -- get last end date of subs or addons, with nulls counted as max
            CASE
                WHEN art.center IS NULL
                THEN 'invoice'
                ELSE part.center||'ar'||part.id||'art'||part.subid
            END AS payment_id,
            CASE
                WHEN art.center IS NULL
                THEN 'direct invoice'
                ELSE part.text
            END AS payment_description,
            --   il.center||'inv'||il.id as invoice_id,
            SUM(
                CASE
                    WHEN art.center IS NULL
                    THEN il.total_amount
                    ELSE 0
                END) + MAX(
                CASE
                    WHEN art.center IS NOT NULL
                    THEN part.amount
                    ELSE 0
                END) AS paid_amount,
            /*                string_agg(cast(il.total_amount as text),';') AS il_amounts,
            string_agg(cast(part.amount as text),';') AS part_amounts,*/
            string_agg(pr.name,',') AS product_name,
            MAX(
                CASE
                    WHEN art.center IS NULL
                    THEN longtodatec(inv.entry_time,inv.center)
                    ELSE longtodatec(part.entry_time,inv.center)
                END) AS last_payment_time,
            MAX(
                CASE
                    WHEN pr.ptype = 13
                    AND sa.end_Date IS NOT NULL
                    THEN sa.end_date
                    WHEN s.end_Date IS NOT NULL
                    THEN s.end_date
                    ELSE spp.to_date
                END)            AS last_end_date,
            MAX(st.periodcount) AS periodcount,
            string_agg(DISTINCT
            CASE
                WHEN st.PERIODUNIT = 0
                THEN 'week'
                WHEN st.PERIODUNIT =1
                THEN 'day'
                WHEN st.PERIODUNIT = 2
                THEN 'month'
                WHEN st.PERIODUNIT = 3
                THEN 'year'
                WHEN st.PERIODUNIT =4
                THEN 'hour'
                WHEN st.PERIODUNIT = 5
                THEN 'minute'
                WHEN st.PERIODUNIT = 6
                THEN 'second'
                ELSE 'unknown'
            END,',')                 AS periodunit,
            MAX(s.billed_until_date) AS last_billed_until_date,
            MAX(
                CASE
                    WHEN ppgl.product_center IS NOT NULL
                    THEN 1
                    ELSE 0
                END) AS group_fitness
        FROM
            persons op
        CROSS JOIN
            params
        JOIN
            persons p
        ON
            p.transfers_current_prs_center = op.transfers_current_prs_center
        AND p.transfers_current_prs_id = op.transfers_current_prs_id
        JOIN
            centers ce
        ON
            ce.id = p.center
        JOIN
            puregym_switzerland.invoices inv
        ON
            inv.payer_center = p.center
        AND inv.payer_id = p.id
        JOIN
            puregym_switzerland.invoice_lines_mt il
        ON
            inv.center = il.center
        AND inv.id = il.id
        JOIN
            puregym_switzerland.products pr
        ON
            pr.center = il.productcenter
        AND pr.id = il.productid
        JOIN
            centers c
        ON
            c.id = il.center
        LEFT JOIN
            puregym_switzerland.masterproductregister mpr
        ON
            mpr.globalid = pr.globalid
        AND mpr.definition_key = mpr.id
        LEFT JOIN
            puregym_switzerland.spp_invoicelines_link sppil
        ON
            sppil.invoiceline_center = il.center
        AND sppil.invoiceline_id = il.id
        AND sppil.invoiceline_subid = il.subid
        LEFT JOIN
            puregym_switzerland.subscriptionperiodparts spp
        ON
            spp.center = sppil.period_center
        AND spp.id = sppil.period_id
        AND spp.subid = sppil.period_subid
            --AND spp.spp_state = 1
        LEFT JOIN
            puregym_switzerland.subscriptions s
        ON
            (
                s.center = spp.center
            AND s.id = spp.id)
        OR  (
                s.invoiceline_center = il.center
            AND s.invoiceline_id = il.id
            AND s.invoiceline_subid = il.subid)
        LEFT JOIN
            puregym_switzerland.subscription_addon sa
        ON
            sa.subscription_center = s.center
        AND sa.subscription_id = s.id
        AND sa.addon_product_id = mpr.id
        AND pr.ptype = 13
        LEFT JOIN
            puregym_switzerland.subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        LEFT JOIN
            puregym_switzerland.ar_trans art
        ON
            art.ref_center = il.center
        AND art.ref_id = il.id
        AND art.ref_type = 'INVOICE'
        LEFT JOIN
            puregym_switzerland.center_ext_attrs cea_provid
        ON
            cea_provid.center_id = ce.id
        AND cea_provid.name = 'PROVID'
        LEFT JOIN
            puregym_switzerland.center_ext_attrs cea_zsr
        ON
            cea_zsr.center_id = ce.id
        AND cea_zsr.name = 'ZSR'
        LEFT JOIN
            puregym_switzerland.art_match arm
        ON
            arm.art_paid_center = art.center
        AND arm.art_paid_id = art.id
        AND arm.art_paid_subid = art.subid
        AND arm.cancelled_time IS NULL
        AND arm.entry_time < params.period_to_ts
        AND arm.entry_time > params.period_from_ts
        LEFT JOIN
            puregym_switzerland.ar_trans part
        ON
            part.center = arm.art_paying_center
        AND part.id = arm.art_paying_id
        AND part.subid = arm.art_paying_subid
        LEFT JOIN
            puregym_switzerland.credit_notes cn
        ON
            cn.invoice_center = inv.center
        AND cn.invoice_id = inv.id
        LEFT JOIN
            puregym_switzerland.product_and_product_group_link ppgl
        ON
            ppgl.product_center = pr.center
        AND ppgl.product_id = pr.id
        AND ppgl.product_group_id = 1404
        WHERE
            (
                op.center, op.id) IN ( ( :member_center,
                                        :member_id ) )
            -- op.center = 6004 and op.id in (2672,3251,2951)
        AND pr.ptype IN ( 10,
                         13,
                         5 )
        AND (
                arm.art_paid_center IS NOT NULL
            AND part.ref_type != 'CREDIT_NOTE'
            OR  (
                    art.center IS NULL
                AND inv.entry_time BETWEEN params.period_from_ts AND params.period_to_ts ))
        AND s.id IS NOT NULL
        AND il.total_amount != 0
            --  AND cn.id IS NULL
        AND (
                art.text != 'Converted subscription invoice'
            OR  art.text IS NULL)
            -- and part.center = 6004 and part.id = 6 and part.subid = 40
            --and inv.center = 6004 and inv.id = 4530
        GROUP BY
            ce.name,
            ce.address1,
            ce.zipcode,
			ce.city,
            op.center,
            op.id,
            art.center,
            part.center,
            part.id,
            part.subid,
            cea_provid.txt_value,
            cea_zsr.txt_value,
            params.period_from_date,
            c.city
    )
/*SELECT
*
FROM
details;*/
SELECT
    -- Do NOT change the order of the fields as they are references by index in the qualitop
    -- certificate template
    head_office_name,
    head_office_address_1,
    head_office_address_2,
    provider_id,
    zsr,
    member_id,
    member_last_name,
    member_first_name,
    member_street,
    member_zip,
    member_city,
    string_agg(DISTINCT product_name,',')                        AS product_name,
    TO_CHAR(MIN(start_date),'DD.MM.YYYY')                        AS product_start_date,
    TO_CHAR(MAX(last_end_date),'DD.MM.YYYY')                     AS product_end_date,
    TO_CHAR(CAST(SUM(paid_amount) AS DECIMAL), 'FM999999990.00')      AS amount,
    MAX(periodunit)                                                   AS period_unit,
    string_agg(DISTINCT CAST(periodcount AS text),',')                AS period_count,
    TO_CHAR(MAX(last_billed_until_date),'DD.MM.YYYY')                 AS billed_until_date,
    string_agg(DISTINCT TO_CHAR(last_payment_time,'DD.MM.YYYY') ,',') AS paid_date,
    MAX(COALESCE(group_fitness,0))                                    AS group_fitness,
    home_city                                                         AS home_city
FROM
    details
WHERE
    last_payment_time BETWEEN :period_from AND :period_to
AND last_payment_time > '2023-01-01' -- change this to match the migration date
GROUP BY
    head_office_name,
    head_office_address_1,
    head_office_address_2,
    provider_id,
    zsr,
    member_id,
    member_last_name,
    member_first_name,
    member_street,
    member_zip,
    member_city,
    home_city