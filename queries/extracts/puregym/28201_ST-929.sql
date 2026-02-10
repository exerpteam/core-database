-- The extract is extracted from Exerp on 2026-02-08
--  
        SELECT DISTINCT
            p.FULLNAME "Member Name"
          ,p.CENTER || 'p' || p.ID "P ref"
          ,c.SHORTNAME "Club name"
          , ss.SALES_DATE "Sale Date"
          , prod.NAME "Subscription name"
          , s.BINDING_PRICE "Subscription amount"
          , UTL_RAW.CAST_TO_VARCHAR2(je.BIG_TEXT) "sage pay ref"
          , pa.REF "ClubLead Ref"
        FROM
            SUBSCRIPTION_SALES ss
        JOIN
            PERSONS p
        ON
            p.CENTER = ss.OWNER_CENTER
            AND p.ID = ss.OWNER_ID
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = ss.SUBSCRIPTION_CENTER
            AND s.id = ss.SUBSCRIPTION_ID
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = ss.SUBSCRIPTION_TYPE_CENTER
            AND prod.ID = ss.SUBSCRIPTION_TYPE_ID
        LEFT JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK link
        ON
            link.PRODUCT_CENTER = prod.CENTER
            AND link.PRODUCT_ID = prod.ID
        LEFT JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = link.PRODUCT_GROUP_ID
            AND pg.id = 603
        JOIN
            CENTERS c
        ON
            c.ID = p.CENTER
        LEFT JOIN
            PUREGYM.JOURNALENTRIES je
        ON
            p.ID = je.PERSON_ID
            AND p.CENTER = je.PERSON_CENTER
            AND je.NAME IN ('Debts Payment Sage Pay'
                          , 'Day Pass Purchase Sage Pay'
                          , 'Pure Loser Purchase Sage Pay'
                          , 'Grit Course Purchase Sage Pay'
                          , 'Join Payment Sage Pay'
                          , 'Debt Payment Sage Pay'
                          , 'Day-pass Payment Sage Pay'
                          , 'Pureloser Payment Sage Pay'
                          , 'Course Payment Sage Pay')
            AND je.CREATION_TIME BETWEEN s.CREATION_TIME-300000 AND s.CREATION_TIME+300000
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.CENTER
            AND ar.CUSTOMERID = p.ID
            AND ar.AR_TYPE = 4
        LEFT JOIN
            PAYMENT_ACCOUNTS pac
        ON
            pac.CENTER = ar.CENTER
            AND pac.ID = ar.ID
        LEFT JOIN
            AGREEMENT_CHANGE_LOG acl
        ON
            acl.AGREEMENT_CENTER = pac.ACTIVE_AGR_CENTER
            AND acl.AGREEMENT_ID = pac.ACTIVE_AGR_ID
            AND acl.AGREEMENT_SUBID = pac.ACTIVE_AGR_SUBID
            and acl.ENTRY_TIME BETWEEN s.CREATION_TIME-3000000 AND s.CREATION_TIME+3000000
        LEFT JOIN
            PAYMENT_AGREEMENTS pa
        ON
            pa.CENTER = acl.AGREEMENT_CENTER
            AND pa.ID = acl.AGREEMENT_ID
            AND pa.SUBID = acl.AGREEMENT_SUBID
        WHERE
            ss.EMPLOYEE_CENTER = 100
            AND ss.EMPLOYEE_ID = 203
            AND ss.TYPE = 1
			and p.center in ($$scope$$)