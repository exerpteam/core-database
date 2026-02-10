-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT

            s.OWNER_CENTER||'p'||s.OWNER_ID
        FROM
            SUBSCRIPTION_REDUCED_PERIOD srp
        JOIN
            FW.SUBSCRIPTIONPERIODPARTS spp
        ON
            spp.CENTER = srp.SUBSCRIPTION_CENTER
            AND spp.ID = srp.SUBSCRIPTION_ID
            AND spp.FROM_DATE <= srp.END_DATE
            AND spp.TO_DATE >= srp.START_DATE
            AND spp.SPP_TYPE = 3
        JOIN
            FW.SPP_INVOICELINES_LINK sppi
        ON
            sppi.PERIOD_CENTER = spp.center
            AND sppi.PERIOD_ID = spp.id
            AND sppi.PERIOD_SUBID = spp.SUBID
        JOIN
            FW.AR_TRANS art
        ON
            art.REF_TYPE = 'INVOICE'
            AND art.REF_CENTER = sppi.INVOICELINE_CENTER
            AND art.REF_ID = sppi.INVOICELINE_ID
        LEFT JOIN
            FW.ART_MATCH artm
        ON
            artm.ART_PAID_CENTER = art.center
            AND artm.ART_PAID_ID = art.id
            AND artm.ART_PAID_SUBID = art.SUBID
        LEFT JOIN
            FW.AR_TRANS sart
        ON
            sart.CENTER = artm.ART_PAYING_CENTER
            AND sart.ID = artm.ART_PAYING_ID
            AND sart.SUBID = artm.ART_PAYING_SUBID
        JOIN
            FW.CREDIT_NOTES cn
        ON
            cn.CENTER = sart.REF_CENTER
            AND cn.ID = sart.REF_ID
            AND sart.REF_TYPE = 'CREDIT_NOTE'
        JOIN
            FW.SPP_INVOICELINES_LINK sppi2
        ON
            sppi2.INVOICELINE_CENTER = cn.INVOICE_CENTER
            AND sppi2.INVOICELINE_ID = cn.INVOICE_ID
        JOIN
            FW.SUBSCRIPTIONPERIODPARTS spp2
        ON
            spp2.CENTER = sppi2.PERIOD_CENTER
            AND spp2.id = sppi2.PERIOD_ID
            AND sppi2.PERIOD_SUBID = spp2.SUBID
        JOIN
            FW.SUBSCRIPTIONS s
        ON
            s.center = spp.center
            AND s.id = spp.id
        WHERE
 srp.SUBSCRIPTION_CENTER in ($$Subscription_Center$$)
            and srp.start_date >= to_date('2020-03-12','YYYY-MM-DD')
            AND srp.STATE = 'ACTIVE'
            AND srp.TYPE = 'FREE_ASSIGNMENT'
            AND (
                CAST(EXTRACT(MONTH FROM spp2.FROM_DATE) AS INTEGER) > CAST(EXTRACT(MONTH FROM srp.END_DATE) AS INTEGER)
                OR CAST(EXTRACT(MONTH FROM spp2.FROM_DATE) AS INTEGER) < CAST(EXTRACT(MONTH FROM srp.START_DATE) AS INTEGER))