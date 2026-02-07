SELECT
    clubId,
    club,
    subscription,
    legacy,
    persontype,
    "PRODUCT PRICE",
    "CURRENT PRICE",
    "NEW PRICE",
    "VARIANCE",
    APPLY_DATE,
    pricestate,
    MESSAGE "MESSAGE SENT",
    approvedBy,
    COUNT(*) "COUNT",
    SUM("VARIANCE") "SUM",
    template_name,
    OUTPUTMIMETYPE
FROM
    (
        SELECT
            centre.ID clubId,
            centre.SHORTNAME club,
            prod.name AS subscription,
            CASE
                WHEN prod.BLOCKED = 1
                    OR joinProd.BLOCKED = 1
                THEN 'YES'
                ELSE 'NO'
            END LEGACY,
            CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'
             WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE,
            prod.PRICE "PRODUCT PRICE",
            sub.SUBSCRIPTION_PRICE "CURRENT PRICE",
            pc.PRICE "NEW PRICE",
            pc.PRICE - sub.SUBSCRIPTION_PRICE "VARIANCE",
            TO_CHAR(pc.FROM_DATE, 'YYYY-MM-DD') APPLY_DATE,
            CASE
                WHEN pc.CANCELLED = 1
                THEN 'CANCELLED'
                WHEN pc.APPLIED = 1
                THEN 'APPLIED'
                WHEN pc.PENDING = 1
                THEN 'PENDING'
                WHEN pc.APPROVED = 1
                THEN 'APPROVED'
                WHEN pc.APPROVED = 0
                    AND pc.PENDING = 0
                    AND pc.APPLIED = 0
                    AND pc.CANCELLED = 0
                THEN 'DRAFT'
                ELSE 'ERROR'
            END priceState,
            CASE
                WHEN pc.NOTIFIED = 1
                THEN 'Yes'
                ELSE 'No'
            END MESSAGE,
            pc.APPROVED,
            pc.NOTIFIED,
            pc.APPLIED,
            CASE
                WHEN pc.APPROVED_EMPLOYEE_CENTER IS NOT NULL
                    AND pc.APPROVED = 1
                THEN pc.APPROVED_EMPLOYEE_CENTER || 'emp' || pc.APPROVED_EMPLOYEE_ID
                ELSE NULL
            END approvedBy,
            longtodate(pc.APPROVED_ENTRY_TIME) approveTime,
            template.DESCRIPTION template_name,
            template.OUTPUTMIMETYPE
        FROM
            SUBSCRIPTIONS sub
        JOIN
            SUBSCRIPTION_PRICE pc
        ON
            pc.SUBSCRIPTION_CENTER = sub.CENTER
            AND pc.SUBSCRIPTION_ID = sub.ID
        JOIN
            SUBSCRIPTIONTYPES stype
        ON
            sub.SUBSCRIPTIONTYPE_CENTER = stype.CENTER
            AND sub.SUBSCRIPTIONTYPE_ID = stype.ID
        JOIN
            PRODUCTS prod
        ON
            stype.CENTER = prod.CENTER
            AND stype.ID = prod.ID
        JOIN
            CENTERS centre
        ON
            sub.CENTER = centre.ID
        JOIN
            PRODUCTS joinProd
        ON
            stype.PRODUCTNEW_CENTER = joinProd.CENTER
            AND stype.PRODUCTNEW_ID = joinProd.ID
        JOIN
            PERSONS p
        ON
            p.CENTER = sub.OWNER_CENTER
            AND p.ID = sub.OWNER_ID
        LEFT JOIN
            TEMPLATES template
        ON
            template.id = pc.TEMPLATE_ID
        WHERE
            pc.FROM_DATE = CAST($$ApplyDate$$ AS DATE)
            AND sub.CENTER IN ($$Scope$$)
            AND pc.TYPE IN ('SCHEDULED')
            AND (
                -- All
                (
                    CAST($$State$$ AS INT) = 0)
                OR
                -- Draft
                (
                    CAST($$State$$ AS INT) = 1
                    AND pc.APPROVED = 0
                    AND pc.PENDING = 0
                    AND pc.APPLIED = 0
                    AND pc.CANCELLED = 0)
                OR
                -- Approved
                (
                    CAST($$State$$ AS INT) = 2
                    AND pc.APPROVED = 1
                    AND pc.PENDING = 0
                    AND pc.APPLIED = 0
                    AND pc.CANCELLED = 0)
                OR
                -- Pending
                (
                    CAST($$State$$ AS INT) = 3
                    AND pc.PENDING = 1
                    AND pc.APPLIED = 0
                    AND pc.CANCELLED = 0)
                OR
                -- Applied
                (
                    CAST($$State$$ AS INT) = 4
                    AND pc.APPLIED = 1
                    AND pc.CANCELLED = 0)
                OR
                -- Cancelled
                (
                    CAST($$State$$ AS INT) = 9
                    AND pc.CANCELLED = 1) )) t
GROUP BY
    clubId,
    club,
    subscription,
    legacy,
    persontype,
    "PRODUCT PRICE",
    "CURRENT PRICE",
    "NEW PRICE",
    "VARIANCE",
    MESSAGE,
    APPLY_DATE,
    pricestate,
    approvedBy,
    template_name,
    OUTPUTMIMETYPE
ORDER BY
    clubId,
    subscription,
    pricestate