select min(FROM_DATE) invoiced_from,ssid,payer,sum(total_amount),globalid from 
(
SELECT
    i1.center || 'ss' || i1.id                ssid,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID payer,
    spp.FROM_DATE,
    spp.TO_DATE,
    prs.ORIGINAL_DUE_DATE due_date,
    prs.REQUESTED_AMOUNT,
    prs.OPEN_AMOUNT                                                                                                                                                                                                        unpaid_amount,
    DECODE(pr.state,1, 'New',2, 'Sent',3, 'Done',4, 'Done, manuel',5, 'Rejected, clearinghouse',6, 'Rejected, bank',7, 'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',12, 'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed','UNDEFINED') AS request_state,
    prs.REF                                                                                                                                                                                                        request_ref,
    invl.CENTER || 'inv' || invl.ID || 'ln' || invl.SUBID                                                                                                                                                                                                        line_id,
    invl.QUANTITY,
    invl.TOTAL_AMOUNT,
    prod.GLOBALID
FROM
    (
        SELECT
            s.CENTER,
            s.ID,
            sa.ID addon_id,
            sa.START_DATE,
            mpr.GLOBALID 
        FROM
            SUBSCRIPTION_ADDON sa
        JOIN
            MASTERPRODUCTREGISTER mpr
        ON
            mpr.ID = sa.ADDON_PRODUCT_ID
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sa.SUBSCRIPTION_CENTER
            AND s.ID = sa.SUBSCRIPTION_ID
            AND s.STATE IN (2,4,8)
        JOIN
            PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.ID = s.OWNER_ID
            AND p.STATUS NOT IN (4,5,6,7,8)
        WHERE
            mpr.GLOBALID = 'EFT_GX_ADD_ON_TRONDHEIM'
            AND sa.SUBSCRIPTION_CENTER NOT IN (229,
                                               232,
                                               233,
                                               234,
                                               235 )
            AND sa.CREATION_TIME > 1448924400000
            AND (
                sa.END_DATE IS NULL
                OR sa.END_DATE > exerpsysdate())
        UNION
        SELECT
            s2.CENTER,
            s2.ID,
            sa2.ID,
            sa2.START_DATE,
            mpr2.GLOBALID 
        FROM
            SUBSCRIPTION_ADDON sa2
        JOIN
            SUBSCRIPTIONS s2
        ON
            s2.CENTER = sa2.SUBSCRIPTION_CENTER
            AND s2.ID = sa2.SUBSCRIPTION_ID
        JOIN
            MASTERPRODUCTREGISTER mpr2
        ON
            mpr2.ID = sa2.ADDON_PRODUCT_ID
        WHERE
            mpr2.CACHED_PRODUCTNAME = 'EFT GX add-on'
            AND sa2.CREATION_TIME > 1448924400000
            AND (
                sa2.SUBSCRIPTION_CENTER,sa2.SUBSCRIPTION_ID) IN
            (
                SELECT
                    s.CENTER,
                    s.ID
                FROM
                    SUBSCRIPTION_ADDON sa
                JOIN
                    SUBSCRIPTIONS s
                ON
                    s.CENTER = sa.SUBSCRIPTION_CENTER
                    AND s.ID = sa.SUBSCRIPTION_ID
                    AND s.STATE IN (2,4,8)
                JOIN
                    PERSONS p
                ON
                    p.CENTER = s.OWNER_CENTER
                    AND p.ID = s.OWNER_ID
                    AND p.STATUS NOT IN (4,5,6,7,8)
                WHERE
                    (
                        sa.END_DATE IS NULL
                        OR sa.END_DATE > exerpsysdate())
                    AND sa.CANCELLED = 0
                    AND p.CENTER IN (229,
                                     232,
                                     233,
                                     234,
                                     235 )
                GROUP BY
                    s.CENTER,
                    s.ID
                HAVING
                    COUNT(sa.ID) > 1 ) )i1
JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    i1.center = spp.CENTER
    AND i1.id = spp.ID
    AND spp.SPP_STATE = 1
    AND spp.FROM_DATE >= i1.start_date
JOIN
    SPP_INVOICELINES_LINK link
ON
    link.PERIOD_CENTER = spp.CENTER
    AND link.PERIOD_ID = spp.ID
    AND link.PERIOD_SUBID = spp.SUBID
JOIN
    INVOICELINES invl
ON
    invl.CENTER = link.INVOICELINE_CENTER
    AND invl.id = link.INVOICELINE_ID
    AND invl.SUBID = link.INVOICELINE_SUBID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
    and prod.GLOBALID = i1.GLOBALID
LEFT JOIN
    AR_TRANS art
ON
    art.REF_TYPE = 'INVOICE'
    AND art.REF_CENTER = invl.CENTER
    AND art.REF_ID = invl.ID
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
    AND ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = art.PAYREQ_SPEC_CENTER
    AND prs.ID = art.PAYREQ_SPEC_ID
    AND prs.SUBID = art.PAYREQ_SPEC_SUBID
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
    )
    group by 
    ssid,payer,globalid