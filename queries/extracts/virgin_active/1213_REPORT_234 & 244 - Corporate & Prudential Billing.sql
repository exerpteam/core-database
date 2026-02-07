SELECT DISTINCT
    *
FROM
    (
        SELECT
            c.NAME "Club",
            nvl2(s.CENTER,s.CENTER || 'ss' || s.ID,NULL) "Membership Number",
            p.FIRSTNAME "First Names",
            p.LASTNAME "Last Name",
            /* Should be gotten from person ext atts when ready */
            NULL "Status",
            FIRST_VALUE(scl.BOOK_START_TIME) OVER (PARTITION BY p.CENTER,p.ID ORDER BY scl.BOOK_START_TIME ASC) "Join Date",
            prod.NAME "Subscription Type",
            s.START_DATE "Start Date",
            NULL "End Date",
            pruNbr.TXTVALUE "Pru Entity No",
            p.CENTER || 'p' || p.ID "Member ID",
            NULL "Contract Start",
            FIRST_VALUE(prs.REQUESTED_AMOUNT) OVER (PARTITION BY p.CENTER,p.ID ORDER BY prs.ENTRY_TIME DESC) "Amount",
            NULL "Date Last Billed",
            p.BIRTHDATE "DOB",
            comp.LASTNAME "Company Name"
        FROM
            PERSONS comp
        JOIN COMPANYAGREEMENTS ca
        ON
            ca.CENTER = comp.CENTER
            AND ca.ID = comp.ID
        JOIN RELATIVES ca_link
        ON
            ca_link.RELATIVECENTER = ca.CENTER
            AND ca_link.RELATIVEID = ca.ID
            AND ca_link.RELATIVESUBID = ca.SUBID
            AND ca_link.RTYPE = 3
        LEFT JOIN PERSONS p
        ON
            p.CENTER = ca_link.CENTER
            AND p.ID = ca_link.ID
        LEFT JOIN ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.CENTER
            AND ar.CUSTOMERID = p.ID
            AND ar.AR_TYPE = 4
        LEFT JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.CENTER = ar.CENTER
            AND prs.id = ar.id
            AND prs.CANCELLED = 1
        LEFT JOIN PERSON_EXT_ATTRS pruNbr
        ON
            pruNbr.PERSONCENTER = p.CENTER
            AND pruNbr.PERSONID = p.ID
            AND pruNbr.NAME = '_eClub_PBLookupPartnerPersonId'
        LEFT JOIN CENTERS c
        ON
            c.id = p.CENTER
        LEFT JOIN STATE_CHANGE_LOG scl
        ON
            scl.CENTER = p.CENTER
            AND scl.id = p.id
            AND scl.ENTRY_TYPE = 1
            AND scl.STATEID = 1
        LEFT JOIN SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.STATE IN (2,4,8)
        LEFT JOIN PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.id = s.SUBSCRIPTIONTYPE_ID
        WHERE
            comp.SEX = 'C'
            AND comp.CENTER IN (:scope)
        ORDER BY
            comp.CENTER,
            comp.ID,
            ca.SUBID,
            p.CENTER
    )