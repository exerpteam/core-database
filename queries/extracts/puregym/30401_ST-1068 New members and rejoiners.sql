SELECT
    table1.ClubId    AS "Club Id",
    table1.ClubName  AS "Club name",
    CASE
        WHEN table1.scl_state=2
        AND table1.days<31
        THEN 'True'
        ELSE 'False'
    END AS "Reinstated",
    CASE
        WHEN table1.scl_state=2
        AND table1.days>30
        AND table1.days<366
        THEN 'True'
        ELSE 'False'
    END AS "Re-joined",
    CASE
        WHEN table1.scl_state=2
        AND table1.days>365
        THEN 'True'
        ELSE 'False'
    END AS "Ex-members",
    CASE
        WHEN table1.scl_state IN (0,6,9)
        THEN 'True'
        ELSE 'False'
    END AS "New members",
    CASE
        WHEN table1.scl_state IN (4)
        THEN 'True'
        ELSE 'False'
    END                    AS "Transferred",
    table1.OwnerKey        AS "Owner Key",
    table1.SubscriptionKey AS "Subscription Key",
    table1.TransactionId   AS "Transaction Id"
FROM
    (
        SELECT
            longtodate(sub.CREATION_TIME),
            longtodate(scl.BOOK_START_TIME),
            longtodate(scl.BOOK_END_TIME),
            sub.OWNER_CENTER                        AS ClubId,
            c.NAME                                  AS ClubName,
            sub.OWNER_CENTER || 'p' || sub.OWNER_ID AS OwnerKey,
            pr.NAME                                 AS SubscriptionName,
            sub.CENTER || 'ss' || sub.ID            AS SubscriptionKey,
            CASE
                WHEN artCC.INFO LIKE 'PG%'
                THEN artCC.INFO
                ELSE NULL
            END AS TransactionId,
            --DECODE(scl.STATEID,0,'LEAD',1,'ACTIVE',2,'INACTIVE',3,'TEMPORARYINACTIVE',4,'
            -- TRANSFERED',6,'PROSPECT',9,'CONTACT',NULL,'NOCHANGE', 'UNKNOWN') AS scl_state,
            scl.STATEID AS scl_state,
            NVL(TRUNC(longtodate(scl.BOOK_END_TIME)) - TRUNC(longtodate
            (scl.BOOK_START_TIME)),0) AS days
        FROM
            SUBSCRIPTION_SALES ss
        JOIN
            SUBSCRIPTIONS sub
        ON
            sub.CENTER = ss.SUBSCRIPTION_CENTER
        AND sub.ID = ss.SUBSCRIPTION_ID
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            sub.SUBSCRIPTIONTYPE_CENTER = st.CENTER
        AND sub.SUBSCRIPTIONTYPE_ID = st.ID
        JOIN
            PRODUCTS pr
        ON
            pr.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
        AND pr.ID = sub.SUBSCRIPTIONTYPE_ID
        JOIN
            CENTERS c
        ON
            c.ID = sub.OWNER_CENTER
        JOIN
            INVOICELINES il
        ON
            il.CENTER = sub.INVOICELINE_CENTER
        AND il.ID = sub.INVOICELINE_ID
        AND il.SUBID = sub.INVOICELINE_SUBID
        JOIN
            INVOICES inv
        ON
            inv.CENTER = il.CENTER
        AND inv.ID = il.ID
        LEFT JOIN
            AR_TRANS artSale
        ON
            artSale.REF_CENTER=inv.CENTER
        AND artSale.REF_ID=inv.ID
        AND artSale.REF_TYPE='INVOICE'
        LEFT JOIN
            ART_MATCH am
        ON
            am.ART_PAID_CENTER = artSale.CENTER
        AND am.ART_PAID_ID = artSale.ID
        AND am.ART_PAID_SUBID = artSale.SUBID
        AND am.ENTRY_TIME > artSale.ENTRY_TIME
		AND artSale.AMOUNT = am.AMOUNT*(-1)
        LEFT JOIN
            AR_TRANS artCC
        ON
            am.ART_PAYING_CENTER = artCC.CENTER
        AND am.ART_PAYING_ID = artCC.ID
        AND am.ART_PAYING_SUBID = artCC.SUBID
        AND artCC.TEXT = 'API Sale Transaction'
        LEFT JOIN
            STATE_CHANGE_LOG scl
        ON
            scl.CENTER = sub.OWNER_CENTER
        AND scl.ID = sub.OWNER_ID
        AND scl.ENTRY_TYPE = 1
        AND TO_CHAR(longtodate(sub.CREATION_TIME),'YYYY-MM-DD HH24:MI:SS') = TO_CHAR
            (longtodate(scl.BOOK_END_TIME),'YYYY-MM-DD HH24:MI:SS')
        WHERE
            ss.SALES_DATE BETWEEN :dateFrom AND :dateTo
        AND (
                st.CENTER, st.ID) NOT IN
            (
                SELECT
                    CENTER,
                    ID
                FROM
                    V_EXCLUDED_SUBSCRIPTIONS)
        AND (
                TO_CHAR(longtodate(scl.BOOK_START_TIME),'YYYY-MM-DD HH24:MI:SS') != TO_CHAR
                (longtodate(scl.BOOK_END_TIME),'YYYY-MM-DD HH24:MI:SS')
            OR  (
                    scl.BOOK_START_TIME IS NULL))
        ORDER BY
            sub.OWNER_CENTER,
            sub.OWNER_ID) table1