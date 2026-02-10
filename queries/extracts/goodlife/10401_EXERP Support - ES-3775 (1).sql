-- The extract is extracted from Exerp on 2026-02-08
-- Find Bi-Weekly subscriptions linked to a default Monthly payment agreement. Identify members that are on specific PAP scheduled designed product type.
Biweekly subscription linked to monthly payment

SELECT
    a.PERSON_ID,
    a.MEMBERSHIP_ID,
    a.SUBSCRIPTION_NAME,
    CASE
        WHEN a.SUBSCRIPION_STATE= 2
        THEN 'ACTIVE'
        WHEN a.SUBSCRIPION_STATE = 3
        THEN 'ENDED'
        WHEN a.SUBSCRIPION_STATE = 4
        THEN 'FROZEN'
        WHEN a.SUBSCRIPION_STATE = 7
        THEN 'WINDOW'
        WHEN a.SUBSCRIPION_STATE = 8
        THEN 'CREATED'
        ELSE 'UNKNOWN'
    END AS SUBSCRIPTION_STATE,
    CASE
        WHEN a.SUBSCRIPTION_SUB_STATE = 1
        THEN 'NONE'
        WHEN a.SUBSCRIPTION_SUB_STATE = 2
        THEN 'AWAITING ACTIVATION'
        WHEN a.SUBSCRIPTION_SUB_STATE = 3
        THEN 'UPGRADED'
        WHEN a.SUBSCRIPTION_SUB_STATE = 4
        THEN 'DOWNGRADED'
        WHEN a.SUBSCRIPTION_SUB_STATE = 5
        THEN 'EXTENDED'
        WHEN a.SUBSCRIPTION_SUB_STATE = 6
        THEN 'TRANSFERRED'
        WHEN a.SUBSCRIPTION_SUB_STATE = 7
        THEN 'REGRETTED'
        WHEN a.SUBSCRIPTION_SUB_STATE = 8
        THEN 'CANCELLED'
        WHEN a.SUBSCRIPTION_SUB_STATE = 9
        THEN 'BLOCKED'
        WHEN a.SUBSCRIPTION_SUB_STATE = 10
        THEN 'CHANGED'
        ELSE 'UNKNOWN'
    END AS SUBSCRIPTION_SUB_STATE,
    a.CREATION_TIME,
    a.total AS total_biweekly_pa,
    CASE
        WHEN a.MONTHLY_PA_STATE = 1
        THEN 'CREATED'
        WHEN a.MONTHLY_PA_STATE = 2
        THEN 'SENT'
        WHEN a.MONTHLY_PA_STATE = 3
        THEN 'FAILED'
        WHEN a.MONTHLY_PA_STATE = 4
        THEN 'OK'
        WHEN a.MONTHLY_PA_STATE = 5
        THEN 'ENDED, BANK'
        WHEN a.MONTHLY_PA_STATE = 6
        THEN 'ENDED, CLEARINGHOUSE'
        WHEN a.MONTHLY_PA_STATE = 7
        THEN 'ENDED DEBTOR'
        WHEN a.MONTHLY_PA_STATE = 8
        THEN 'CANCELLED'
        WHEN a.MONTHLY_PA_STATE = 9
        THEN 'CANCELLED SENT'
        WHEN a.MONTHLY_PA_STATE = 10
        THEN 'ENDED, CREDITOR'
        WHEN a.MONTHLY_PA_STATE = 13
        THEN 'AGREEMENT NOT NEEDED'
        WHEN a.MONTHLY_PA_STATE = 14
        THEN 'INCOMPLETE'
        WHEN a.MONTHLY_PA_STATE = 15
        THEN 'TRANSFER'
        WHEN a.MONTHLY_PA_STATE = 16
        THEN 'RECREATED'
        WHEN a.MONTHLY_PA_STATE = 17
        THEN 'SIGNATURE MISSING'
        ELSE 'UNKNOWN'
        END AS DEFAULT_AGREEMENT_STATE
        FROM
            (
                SELECT
                    s.owner_center||'p'||s.owner_id       AS PERSON_ID,
                    s.center||'ss'||s.id                  AS MEMBERSHIP_ID,
                    p.name                                AS SUBSCRIPTION_NAME,
                    r.center||'p'|| r.id                  AS RELATION,
                    r.rtype                               AS RELATION_TYPE,
                    TO_CHAR(longtodateC(s.creation_time,s.center),'YYYY-MM-DD') AS CREATION_TIME,
                    s.state                               AS SUBSCRIPION_STATE,
                    s.sub_state                           AS SUBSCRIPTION_SUB_STATE,
                    pag.state                             AS MONTHLY_PA_STATE,
                    biwkPA.total
                FROM
                    subscriptions s
                JOIN
                    goodlife.subscriptiontypes st
                ON
                    st.center = s.subscriptiontype_center
                    AND st.id = s.subscriptiontype_id
                JOIN
                    goodlife.account_receivables ar
                ON
                    ar.customercenter = s.owner_center
                    AND ar.customerid = s.owner_id
                JOIN
                    goodlife.payment_accounts pa
                ON
                    pa.center = ar.center
                    AND pa.id = ar.id
                JOIN
                    goodlife.payment_agreements pag
                ON
                    pag.center = pa.active_agr_center
                    AND pag.id = pa.active_agr_id
                    AND pag.subid = pa.active_agr_subid
                JOIN
                    goodlife.payment_cycle_config pcc
                ON
                    pcc.id = pag.payment_cycle_config_id
                JOIN
                    products p
                ON
                    p.center = st.productnew_center
                    AND p.id = st.productnew_id
                LEFT JOIN
                    goodlife.relatives r
                ON
                    r.relativecenter = s.owner_center
                    AND r.relativeid = s.owner_id
                    AND r.rtype = 12
                LEFT JOIN
                    (
                        SELECT
                            pag1.center,
                            pag1.id,
                            COUNT(*) AS total
                        FROM
                            goodlife.payment_agreements pag1
                        JOIN
                            payment_cycle_config pcc1
                        ON
                            pcc1.id = pag1.payment_cycle_config_id
                        WHERE
                            pcc1.interval_type = 0
                            AND pag1.active = true
                        GROUP BY
                            pag1.center,
                            pag1.id) biwkPA
                ON
                    biwkPA.center = pa.center
                    AND biwkPA.id = pa.id
                WHERE
                    st.periodunit = 0
                    --AND s.state = 2
                    --AND s.sub_state = 1
                    AND s.payment_agreement_id IS NULL
                    AND pcc.interval_type = 2
                    AND st.st_type IN (1,2) ) a
        WHERE
            a.RELATION_TYPE IS NULL