WITH
    params AS
    (
        SELECT
            c.id ,
            c.shortname,
            cast($$CutDate$$ as date)                                                AS cutdate,
            datetolongC(TO_CHAR(cast($$CutDate$$ as date), 'YYYY-MM-dd HH24:MI'), c.id) AS cutDateLong
        FROM
            centers c
        WHERE
            c.id IN ($$Scope$$)
    )
SELECT
    t.CenterName,
    t.PersonKey,
    t.PersonName,
    t.SubscriptionKey,
    t.SubscriptionName,
    TO_CHAR(t.SalesTransactionDate, 'YYYY-MM-DD') AS SalesTransactionDate,
    TO_CHAR(t.InvoicedStartDate, 'YYYY-MM-DD')    AS InvoicedStartDate,
    TO_CHAR(t.InvoicedEndDate, 'YYYY-MM-DD')      AS InvoicedEndDate,
    t.InvoicedDays,
    t.JoiningFeeAmount,
    ROUND(t.JoiningFeeAmount/t.InvoicedDays,2) AS JoiningFeeDailyPrice,
    t.AdminFeeAmount,
    ROUND(t.AdminFeeAmount/t.InvoicedDays,2) AS AdminFeeDailyPrice,
    t.DaysSinceStart,
    t.HistoricFreezeDays,
    t.HistoricFreeDays,
    t.RealizedDays,
    t.InvoicedDays -t.RealizedDays                                                      AS DeferredDays,
    ROUND((t.JoiningFeeAmount * t.RealizedDays)/t.InvoicedDays, 2)                      AS RealizedJoiningFeeRevenue,
    t.JoiningFeeAmount - ROUND((t.JoiningFeeAmount * t.RealizedDays)/t.InvoicedDays, 2) AS DeferredJoiningFeeRevenue,
    ROUND((t.AdminFeeAmount * t.RealizedDays)/t.InvoicedDays, 2)                        AS RealizedAdminFeeRevenue,
    t.AdminFeeAmount - ROUND((t.AdminFeeAmount * t.RealizedDays)/t.InvoicedDays, 2)     AS DeferredAdminFeeRevenue ,
    TO_CHAR(t.SubscriptionStart, 'YYYY-MM-DD')                                          AS SubscriptionStart,
    TO_CHAR(t.SubscriptionEnd, 'YYYY-MM-DD')                                            AS SubscriptionEnd
FROM
    (
        SELECT
            params.shortname                                                                AS CenterName,
            PE.CENTER || 'p' || PE.ID                                                       AS PersonKey,
            pe.fullname                                                                     AS PersonName,
            su.center || 'ss' || su.id                                                      AS SubscriptionKey,
            PR.NAME                                                                         AS SubscriptionName,
            longtodatec(su.creation_time, su.center)                                        AS SalesTransactionDate,
            SPP.FROM_DATE                                                                   AS InvoicedStartDate,
            SPP.TO_DATE                                                                     AS InvoicedEndDate,
            SPP.TO_DATE- SPP.FROM_DATE +1                                                   AS InvoicedDays,
            joiningfee.net_amount                                                           AS JoiningFeeAmount,
            adminfee.net_amount                                                             AS AdminFeeAmount,
            params.cutdate - SPP.FROM_DATE +1                                               AS DaysSinceStart,
            (sfp.end_date -sfp.start_date) +1                                               AS HistoricFreezeDays,
            (srp.end_date -srp.start_date) +1                                               AS HistoricFreeDays,
            (params.cutdate - SPP.FROM_DATE +1) - COALESCE((sfp.end_date -sfp.start_date +1), 0) AS RealizedDays,
            SU.START_DATE                                                                   AS SubscriptionStart,
            SU.END_DATE                                                                     AS SubscriptionEnd
        FROM
            subscriptionperiodparts SPP
        JOIN
            SUBSCRIPTIONS SU
        ON
            SPP.CENTER = SU.CENTER
            AND SPP.ID = SU.ID
        JOIN
            PERSONS PE
        ON
            SU.OWNER_CENTER = PE.CENTER
            AND SU.OWNER_ID = PE.ID
        JOIN
            params
        ON
            params.id = pe.center
        JOIN
            SUBSCRIPTIONTYPES ST
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
            AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
        JOIN
            PRODUCTS PR
        ON
            ST.CENTER = PR.CENTER
            AND ST.ID = PR.ID
        JOIN
            invoice_lines_mt joiningfee
        ON
            joiningfee.center = su.invoiceline_center
            AND joiningfee.id = su.invoiceline_id
            AND joiningfee.subid = su.invoiceline_subid
            AND joiningfee.total_amount > 0
        LEFT JOIN
            invoice_lines_mt adminfee
        ON
            adminfee.center = su.invoiceline_center
            AND adminfee.id = su.invoiceline_id
            AND adminfee.productcenter = st.adminfeeproduct_center
            AND adminfee.productid = st.adminfeeproduct_id
            AND adminfee.total_amount > 0
        LEFT JOIN
            subscription_freeze_period sfp
        ON
            sfp.subscription_center = su.center
            AND sfp.subscription_id = su.id
            AND (
                sfp.state = 'ACTIVE'
                OR sfp.cancel_time >= params.cutDateLong)
            AND sfp.end_date >= spp.from_date
            AND sfp.entry_time < params.cutDateLong
        LEFT JOIN
            subscription_reduced_period srp
        ON
            srp.subscription_center = su.center
            AND srp.subscription_id = su.id
            AND srp.type != 'FREEZE'
            AND (
                srp.state = 'ACTIVE'
                OR srp.cancel_time >= params.cutDateLong)
            AND srp.end_date >= spp.from_date
            AND srp.entry_time < params.cutDateLong
        WHERE
            ST.ST_TYPE = 0
            AND SU.END_DATE > params.cutdate
            AND SPP.SPP_STATE = 1 )t
