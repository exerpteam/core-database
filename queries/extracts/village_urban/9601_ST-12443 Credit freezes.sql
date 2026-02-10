-- The extract is extracted from Exerp on 2026-02-08
-- Extract to assess what members should receive a credit note for charged freezes that have been applied. 
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id                               AS center_id,
            to_date('21-03-2020', 'dd-MM-yyyy') AS from_date,
            to_date('24-07-2020', 'dd-MM-yyyy') AS to_date
        FROM
            CENTERS c
        WHERE
            c.COUNTRY = 'GB'
    )
SELECT
    x.OWNER_CENTER || 'p' || x.OWNER_ID as personID,
    'PAYMENT' as ACCOUNT_TYPE,
    x.center as PRODUCT_CENTER,
    x.id AS PRODUCT_ID,
    ROUND((INV_TOTAL_AMOUNT / inv_days) * covid_credit_days,2) AS credit_amount,
    TO_CHAR(current_date,'YYYY-MM-DD'),
    'ST-12443 - Paid freeze credit applied' AS text
FROM
    (
        SELECT
            s.OWNER_CENTER,
            s.owner_id,
            pr.center,
            pr.id,
            pr.name,
            srp.start_date        AS SRP_START,
            srp.end_date          AS SRP_END,
            s.billed_until_date,
            srp.text AS SRP_TEXT,
            sfp.TYPE                                              AS FREEZE_TYPE,
            spp.from_date                                              INV_START_DATE,
            spp.to_date                                                  INV_TO_DATE,
            spp.TO_DATE - spp.FROM_DATE+1                               AS inv_days,
            il.TOTAL_AMOUNT                                              INV_TOTAL_AMOUNT,
            GREATEST(spp.FROM_DATE ,srp.start_date, params.from_Date)        AS credit_period_start,
            LEAST(spp.TO_DATE,srp.end_date, params.to_Date) AS
            credit_period_end,
            LEAST(spp.TO_DATE,srp.end_date, params.to_Date) - GREATEST
            (spp.FROM_DATE , srp.start_date, params.from_Date) +1 AS covid_credit_days
        FROM
            SUBSCRIPTION_REDUCED_PERIOD srp
        JOIN
            subscriptions s
        ON
            s.center = srp.SUBSCRIPTION_CENTER
        AND s.id = srp.SUBSCRIPTION_ID
        LEFT JOIN
            SUBSCRIPTION_FREEZE_PERIOD sfp
        ON
            sfp.id = srp.FREEZE_PERIOD
        JOIN
            SUBSCRIPTIONPERIODPARTS spp
        ON
            spp.CENTER = s.center
        AND spp.id = s.id
        AND spp.FROM_DATE <= srp.END_DATE
        AND spp.TO_DATE >= srp.START_DATE
        AND spp.spp_state = 1
        JOIN
            SPP_INVOICELINES_LINK sppl
        ON
            sppl.PERIOD_CENTER = spp.center
        AND sppl.PERIOD_ID = spp.id
        AND sppl.PERIOD_SUBID = spp.subid
        JOIN
            INVOICE_LINES_MT il
        ON
            il.center = sppl.INVOICELINE_CENTER
        AND il.id = sppl.INVOICELINE_ID
        AND sppl.INVOICELINE_SUBID = il.subid
        JOIN
            params
        ON
            params.CENTER_ID = srp.SUBSCRIPTION_CENTER
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.center = s.SUBSCRIPTIONTYPE_CENTER
        AND st.id = s.SUBSCRIPTIONTYPE_ID
        JOIN
            products pr
        ON
            pr.center = s.SUBSCRIPTIONTYPE_CENTER
        AND pr.id = s.SUBSCRIPTIONTYPE_ID
	WHERE
        srp.START_DATE <= params.to_date
        AND srp.END_DATE >= params.from_date
        AND srp.state = 'ACTIVE'
        AND srp.FREEZE_PERIOD IS NOT NULL
		AND pr.GLOBALID NOT IN ('BUSINESS_CLUB_MONTHLY_CONTRACT',
                                                'BUSINESS_CLUB_MONTHLY_FLEXIBLE',
                                                'VWORKS_COMPLIMENTARY_FLEXI_COM',
                                                'VWORKS_FIXED_DESK_–_MONTHLY',
                                                'VWORKS_FIXED_DESK_–_MONTHLY3',
                                                'VWORKS_FLEXI_DESK_–_MONTHLY',
                                                'VWORKS_FLEXI_DESK_–MONTHLY',
                                                'VWORKS_FLEXI_DESK_–_MONTHLY_12',
                                                'VWORKS_FLEXI_DESK_12_MONTHS_CO',
                                                'VWORKS_NATIONAL_FLEXI_DESK_–_6',
                                                'VWORKS_PLATINUM_FIXED_DESK_MEM',
                                                'VWORKS_PLATINUM_FLEXI_DESK_MEM',
                                                'GOLF_5_DAY_GOLF_ONLY_ANNUAL',
                                                'GOLF_5_DAY_GOLF_MONTHLY',
                                                'GOLF_5_DAY_RESORT_ANNUAL',
                                                'GOLF_5_DAY_RESORT_MONTHLY',
                                                'GOLF_7_DAY_GOLF_ONLY_ANNUAL',
                                                'GOLF_7_DAY_GOLF_ONLY_MONTHLY',
                                                'GOLF_7_DAY_RESORT_ANNUAL',
                                                'GOLF_7_DAY_RESORT_MONTHLY',
                                                'GOLF_COMPLIMENTARY',
                                                'GOLF_HERONS_REACH_CLUB_ANNUAL',
                                                'FOR_GOLF_JUNIOR_16_–_18_ANNUAL',
                                                'GOLF_JUNIOR_10_18_ANNUAL',
                                                'GOLF_SEASON_TICKET_ANNUAL',
                                                'GOLF_SEASON_TICKET_MONTHLY',
                                                'GOLF_JUNIOR_19_21_ANNUAL' )
		
    ) x
WHERE
    covid_credit_days > 0
AND INV_TOTAL_AMOUNT > 0
and inv_days > 0 
ORDER BY 1