-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/EC-10398
WITH
    future_freeze AS
    (SELECT
        *
    FROM
        (SELECT
            fr.subscription_center
            , fr.subscription_id
            , TO_CHAR(fr.START_DATE, 'YYYY-MM-DD') AS FreezeFrom
            , TO_CHAR(fr.END_DATE, 'YYYY-MM-DD')   AS FreezeTo
            , fr.text                              AS FreezeReason
            ,ROW_NUMBER() over (
                            PARTITION BY
                                fr.subscription_center
                                , fr.subscription_id
                            ORDER BY
                                fr.START_DATE ASC) AS rnk
        FROM
            SUBSCRIPTION_FREEZE_PERIOD fr
        WHERE
            fr.subscription_center IN ($$scope$$)
        AND fr.END_DATE > CURRENT_TIMESTAMP)
    WHERE
        rnk = 1
    )
    , p_det AS
    (SELECT
        p.*
        , COALESCE(legacyPersonId.txtvalue,p.external_id) AS contactguid
    FROM
        persons p
    LEFT JOIN
        PERSON_EXT_ATTRS legacyPersonId
    ON
        p.center=legacyPersonId.PERSONCENTER
    AND p.id=legacyPersonId.PERSONID
    AND legacyPersonId.name='_eClub_OldSystemPersonId'
    )
    , params AS MATERIALIZED
    ( SELECT
        --            CURRENT_DATE-interval '1 day' AS from_date ,
        --            CURRENT_DATE                  AS to_date
        c.id                                        AS center
        , datetolongc($$from_date$$:: DATE::VARCHAR,c.id)                 AS from_date_long
        , datetolongc($$to_date$$:: DATE::VARCHAR,c.id)+1000*60*60*24-1 AS to_date_long
        , $$from_date$$:: DATE                                            AS from_date
        , $$to_date$$:: DATE                                            AS to_date
    FROM
        centers c
    WHERE
        c.id IN ($$scope$$)
    )
    , overdue_amounts AS
    (SELECT
        art.center
        ,art.id
        ,MIN(
        CASE
            WHEN art.due_date < CURRENT_DATE
            THEN art.due_date
            ELSE NULL
        END) AS debt_start
        ,SUM(
        CASE
            WHEN art.due_date < CURRENT_DATE
            THEN art.amount
            ELSE NULL
        END) AS total_debt
        ,SUM(
        CASE
            WHEN art.due_date >= CURRENT_DATE
            THEN art.amount
            ELSE NULL
        END) AS future_charges
    FROM
        ar_trans art
    WHERE
        art.status != 'CLOSED'
    GROUP BY
        art.center
        ,art.id
    )
    , included_subs AS
    (SELECT
        DISTINCT s.*
        ,ROW_NUMBER() over (
                        PARTITION BY
                            p.transfers_current_prs_center
                            ,p.transfers_current_prs_id
                        ORDER BY
                            (s.state IN (2,4))::INTEGER DESC
                            ,s.creation_time DESC
                            , (ppgl.product_center IS NOT NULL)::INTEGER DESC) AS rnk
    FROM
        subscriptions s
    LEFT JOIN
        product_and_product_group_link ppgl
    ON
        ppgl.product_center = s.subscriptiontype_center
    AND ppgl.product_id = s.subscriptiontype_id
    AND ppgl.product_group_id= 203
    JOIN
        subscriptiontypes st
    ON
        st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND NOT
        (
            st.IS_ADDON_SUBSCRIPTION)
    JOIN
        persons p
    ON
        p.center = s.owner_center
    AND p.id = s.owner_id
    )
    , ca_spons AS
    (SELECT
        *
    FROM
        (SELECT
            pg.GRANTER_CENTER
            ,pg.GRANTER_ID
            ,pg.GRANTER_SUBID
            , ROUND(pg.sponsorship_amount,2) sponsorship_amount
            , pg.sponsorship_name
            ,ROW_NUMBER() over (
                            PARTITION BY
                                pg.GRANTER_CENTER
                                ,pg.GRANTER_ID
                                ,pg.GRANTER_SUBID
                            ORDER BY
                                (pg.sponsorship_name = 'FULL')::        INTEGER DESC
                                , (pg.sponsorship_name = 'PERCENTAGE')::INTEGER DESC
                                , (pg.sponsorship_name = 'FIXED')::     INTEGER DESC) AS rnk
        FROM
            privilege_grants pg

        WHERE
            pg.granter_service ='CompanyAgreement'
            and pg.sponsorship_name != 'NONE'
        AND pg.valid_to IS NULL)
    WHERE
        rnk = 1
    )
SELECT
    c.name                                            AS "Center Name"
    , c.email                                         AS "Center Email"
    , gmp.fullname                                    AS "Center General manager"
    , p.external_id                                   AS "External ID"
    , p.firstname                                     AS "First name"
    , p.lastname                                      AS "Last name"
    , COALESCE(legacyPersonId.txtvalue,p.external_id) AS "Contactguid"
    , CASE
        WHEN p.external_id = first_value(p.external_id) over
                                                              (
                                                          PARTITION BY
                                                              COALESCE ( opp.external_id ,
                                                              mfp.external_id , p.external_id )
                                                          ORDER BY
                                                              ( COALESCE ( opp.external_id ,
                                                              mfp.external_id , p.external_id ) =
                                                              p.external_id ) :: INTEGER DESC )
        THEN 'Primary Linked Member'
        WHEN opp.center IS NULL
        AND mfp.center IS NULL
        THEN 'Individual Member'
        WHEN COALESCE(opp.center ,mfp.center) IS NOT NULL
        THEN 'Associate Linked Member'
    END                               AS "Member type"
    , phone.txtvalue                  AS "Phone number"
    , mobile.txtvalue                 AS "Mobile number"
    , email.txtvalue                  AS "Email"
    , latest_join_attr.txtvalue::DATE AS "Latest join date"
    , oa.total_debt                   AS "Total debt"
    , CURRENT_DATE - oa.debt_start    AS "Days since debt"
    ,ar.balance                       AS "Account Balance"
    , oa.future_charges               AS "Future charges"
    , CASE pag.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
    END                         AS "status of payment agreement"
    , pr.name                   AS "Package description"
    , comp.fullname             AS "Organization"
    , comp.center||'p'||comp.id AS "Organization ID - Company ID"
    , cag.NAME                  AS "Organization benefit"
    , ca_spons.sponsorship_name AS "Sponsorship"
    , CASE
        WHEN fh.subscription_center IS NOT NULL
        THEN 'FROZEN'
        WHEN s.end_date IS NOT NULL
        AND s.end_date > CURRENT_DATE
        THEN 'EXPIRED'
    END AS "Future pending status"
    , CASE
        WHEN fh.subscription_center IS NOT NULL
        THEN CAST(fh.FreezeFrom AS DATE)
        WHEN s.end_date IS NOT NULL
        AND s.end_date > CURRENT_DATE
        THEN s.end_date
    END AS "Future pending status date"
    , CASE
        WHEN p.status = 1
        OR  (
                p.status IN(0,6)
            AND p.persontype =8)
        OR  (
                p.status = 3
            AND s.state = 8)
        THEN 'Package OK'
        WHEN p.status = 2
        THEN 'Package Cancelled'
        WHEN p.status = 3
        AND s.state = 4
        THEN 'Package Frozen'
    END    AS "Current status"
    , NULL AS "Pulling of notes"
FROM
    p_det p
JOIN
    account_receivables ar
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
AND ar.ar_type = 4
JOIN
    overdue_amounts oa
ON
    oa.center = ar.center
AND oa.id = ar.id
JOIN
    centers c
ON
    c.id = p.center
LEFT JOIN
    persons gmp
ON
    gmp.center = c.manager_center
AND gmp.id= c.manager_id
LEFT JOIN
    PERSON_EXT_ATTRS legacyPersonId
ON
    p.center=legacyPersonId.PERSONCENTER
AND p.id=legacyPersonId.PERSONID
AND legacyPersonId.name='_eClub_OldSystemPersonId'
LEFT JOIN
    relatives op
ON
    op.relativecenter = p.center
AND op.relativeid = p.id
AND op.rtype = 12
AND op.status <2
LEFT JOIN
    p_det opp
ON
    opp.center = op.center
AND opp.id = op.id
LEFT JOIN
    relatives mf
ON
    mf.center = p.center
AND mf.id = p.id
AND mf.rtype = 4
AND mf.status <2
LEFT JOIN
    p_det mfp
ON
    mfp.center = mf.relativecenter
AND mfp.id = mf.relativeid
LEFT JOIN
    PERSON_EXT_ATTRS phone
ON
    p.center =phone.PERSONCENTER
AND p.id =phone.PERSONID
AND phone.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center =mobile.PERSONCENTER
AND p.id =mobile.PERSONID
AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center =email.PERSONCENTER
AND p.id =email.PERSONID
AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS latest_join_attr
ON
    p.center=latest_join_attr.PERSONCENTER
AND p.id=latest_join_attr.PERSONID
AND latest_join_attr.name='LATESTJOINDATE'
LEFT JOIN
    included_subs s
ON
    p.center = s.owner_center
AND p.id = s.owner_id
AND s.rnk = 1
LEFT JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
AND pr.id = s.subscriptiontype_id
LEFT JOIN
    payment_accounts pac
ON
    pac.center = ar.center
AND pac.id = ar.id
LEFT JOIN
    payment_agreements pag
ON
    pag.center = pac.active_agr_center
AND pag.id = pac.active_agr_id
AND pag.subid = pac.active_agr_subid
LEFT JOIN
    relatives rc
ON
    rc.relativecenter = p.center
AND rc.relativeid = p.id
AND rc.rtype = 2
LEFT JOIN
    persons comp
ON
    comp.center = rc.center
AND comp.id = rc.id
AND rc.status <2
LEFT JOIN
    RELATIVES comp_rel
ON
    comp_rel.center=p.center
AND comp_rel.id=p.id
AND comp_rel.RTYPE = 3
AND comp_rel.STATUS < 3
LEFT JOIN
    COMPANYAGREEMENTS cag
ON
    cag.center= comp_rel.RELATIVECENTER
AND cag.id=comp_rel.RELATIVEID
AND cag.subid = comp_rel.RELATIVESUBID
LEFT JOIN
    future_freeze AS fh
ON
    fh.subscription_center = s.center
AND fh.subscription_id = s.id
LEFT JOIN
    ca_spons
ON
    ca_spons.GRANTER_CENTER = cag.center
AND ca_spons.GRANTER_ID = cag.id
AND ca_spons.GRANTER_SUBID = cag.SUBID
WHERE
    oa.total_debt IS NOT NULL