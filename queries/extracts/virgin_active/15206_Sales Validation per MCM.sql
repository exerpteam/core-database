-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    --    i1.SALES_DATE,
    --    i1.OWNER_CENTER,
    --    i1.OWNER_ID,
    i1.CLUB,
    i1.START_DATE,
    i1.SALES_PERSON,
    i1.ORIG_SALES_PERSON,
    i1.DATE_JOINED,
    i1.MEMBER_NAME,
    i1.MEMBER_ID,
    i1.Scource,
    i1.MEMBERSHIP,
    SUM(
        CASE
            WHEN prod.center IS NOT NULL
            THEN invl.TOTAL_AMOUNT
            ELSE 0
        END ) V_TRAINER_AMOUNT,
    i1.COMMISSIONABLE,
    i1.a "Member Detail",
    i1.b "ID/SSN",
    i1.c "General Conditions",
    i1.d "Payment Method",
    i1.e "Start Date Valid",
    i1.f "Corp ID",
    i1.g "Payment details",
    i1.h "Payment details signed"
FROM
    (
        SELECT
            /*+ NO_BIND_AWARE */
            DISTINCT ss.SALES_DATE,
            ss.OWNER_CENTER,
            ss.OWNER_ID,
            centre.SHORTNAME                      club,
            TO_CHAR(sub.start_date, 'DD-MM-YYYY') start_date,
            CASE
                WHEN salesPersonOverride.CENTER IS NOT NULL
                    AND (salesPersonOverride.CENTER <> salesperson.CENTER
                        OR salesPersonOverride.ID <> salesperson.ID)
                THEN salesPersonOverride.FULLNAME
                ELSE salesperson.FULLNAME
            END sales_person,
            CASE
                WHEN salesPersonOverride.CENTER IS NOT NULL
                    AND (salesPersonOverride.CENTER <> salesperson.CENTER
                        OR salesPersonOverride.ID <> salesperson.ID)
                THEN salesperson.FULLNAME
                ELSE NULL
            END                                                                                 orig_sales_person,
            TO_CHAR(longtodateTZ(sub.CREATION_TIME, 'Europe/Copenhagen'), 'DD-MM-YYYY') DATE_JOINED,
            owner.CENTER || 'p' || owner.ID                                                     member_id,
            owner.FULLNAME                                                                      member_name,
            prod.NAME                                                                           MEMBERSHIP,
            --VALIDATION FIELDS FOR COMMISSION
            CASE
                WHEN a.TXTVALUE IN ('Y',
                                    'N/A')
                    AND b.TXTVALUE IN ('Y',
                                       'N/A')
                    AND c.TXTVALUE IN ('Y',
                                       'N/A')
                    AND d.TXTVALUE IN ('Y',
                                       'N/A')
                    AND e.TXTVALUE IN ('Y',
                                       'N/A')
                    AND f.TXTVALUE IN ('Y',
                                       'N/A')
                    AND g.TXTVALUE IN ('Y',
                                       'N/A')
                    AND h.TXTVALUE IN ('Y',
                                       'N/A')
                THEN 'Y'
                ELSE 'N'
            END             commissionable,
            a.TXTVALUE      a,
            b.TXTVALUE      b,
            c.TXTVALUE      c,
            d.TXTVALUE      d,
            e.TXTVALUE      e,
            f.TXTVALUE      f,
            g.TXTVALUE      g,
            h.TXTVALUE      h,
            source.TXTVALUE Scource
        FROM
            SUBSCRIPTION_SALES ss
        LEFT JOIN
            PERSON_EXT_ATTRS source
        ON
            source.PERSONCENTER = ss.OWNER_CENTER
            AND source.PERSONID = ss.OWNER_ID
            AND source.NAME = 'Source_V1'
        JOIN
            SUBSCRIPTIONS sub
        ON
            sub.CENTER = ss.SUBSCRIPTION_CENTER
            AND sub.ID = ss.SUBSCRIPTION_ID
			AND sub.END_DATE = ss.END_DATE
        JOIN
            SUBSCRIPTIONTYPES stype
        ON
            ss.SUBSCRIPTION_TYPE_CENTER = stype.CENTER
            AND ss.SUBSCRIPTION_TYPE_ID = stype.ID
        JOIN
            PRODUCTS prod
        ON
            stype.CENTER = prod.CENTER
            AND stype.ID = prod.ID
        JOIN
            PERSONS owner
        ON
            owner.CENTER = sub.OWNER_CENTER
            AND owner.ID = sub.OWNER_ID
        JOIN
            CENTERS centre
        ON
            owner.CENTER = centre.ID
        JOIN
            STATE_CHANGE_LOG SCL1
        ON
            (
                SCL1.CENTER = SUB.CENTER
                AND SCL1.ID = SUB.ID
                AND SCL1.ENTRY_TYPE = 2
                AND SCL1.STATEID IN (2,
                                     4,8)
                AND SCL1.ENTRY_START_TIME >= $$CreationFrom$$
                AND (
                    SCL1.ENTRY_END_TIME IS NULL
                    OR SCL1.ENTRY_END_TIME < $$CreationTo$$ + (1000*60*60*24) ))
        LEFT JOIN
            SUBSCRIPTION_ADDON addon
        ON
            sub.CENTER = addon.SUBSCRIPTION_CENTER
            AND sub.ID = addon.SUBSCRIPTION_ID
            AND addon.CANCELLED = 0
        LEFT JOIN
            MASTERPRODUCTREGISTER mp
        ON
            addon.ADDON_PRODUCT_ID = mp.ID
        LEFT JOIN
            PERSON_EXT_ATTRS home
        ON
            owner.center = home.PERSONCENTER
            AND owner.id = home.PERSONID
            AND home.name = '_eClub_PhoneHome'
        LEFT JOIN
            PERSON_EXT_ATTRS mobile
        ON
            owner.center = mobile.PERSONCENTER
            AND owner.id = mobile.PERSONID
            AND mobile.name = '_eClub_PhoneSMS'
        LEFT JOIN
            PERSON_EXT_ATTRS email
        ON
            owner.center = email.PERSONCENTER
            AND owner.id = email.PERSONID
            AND email.name = '_eClub_Email'
        LEFT JOIN
            PERSON_EXT_ATTRS a
        ON
            owner.center = a.PERSONCENTER
            AND owner.id = a.PERSONID
            AND a.name = 'Sono_presenti_tutti_i _dati_anagrafici'
        LEFT JOIN
            PERSON_EXT_ATTRS b
        ON
            owner.center = b.PERSONCENTER
            AND owner.id = b.PERSONID
            AND b.name = 'Sono_presenti_ID_e_codice_fiscale'
        LEFT JOIN
            PERSON_EXT_ATTRS c
        ON
            owner.center = c.PERSONCENTER
            AND owner.id = c.PERSONID
            AND c.name = 'CONDIZIONIGENERALIFIRMATO'
        LEFT JOIN
            PERSON_EXT_ATTRS d
        ON
            owner.center = d.PERSONCENTER
            AND owner.id = d.PERSONID
            AND d.name = 'Sono_presenti_i_dati_bancari_o_il_pagamento_cash'
        LEFT JOIN
            PERSON_EXT_ATTRS e
        ON
            owner.center = e.PERSONCENTER
            AND owner.id = e.PERSONID
            AND e.name = 'LADATAINIZIOEVALIDA'
        LEFT JOIN
            PERSON_EXT_ATTRS f
        ON
            owner.center = f.PERSONCENTER
            AND owner.id = f.PERSONID
            AND f.name = 'PRESENTEILBADGEAZIENDALE'
        LEFT JOIN
            PERSON_EXT_ATTRS g
        ON
            owner.center = g.PERSONCENTER
            AND owner.id = g.PERSONID
            AND g.name = 'MODULODIPAGAMENTOFIRMATO'
        LEFT JOIN
            PERSON_EXT_ATTRS h
        ON
            owner.center = h.PERSONCENTER
            AND owner.id = h.PERSONID
            AND h.name = 'Sono_presenti_le_firme_del_titolare_dei_pagamenti'
        LEFT JOIN
            EMPLOYEES emp
        ON
            ss.EMPLOYEE_CENTER = emp.CENTER
            AND ss.EMPLOYEE_ID = emp.ID
        LEFT JOIN
            PERSONS salesperson
        ON
            salesperson.CENTER = emp.PERSONCENTER
            AND salesperson.ID = emp.PERSONID
        LEFT JOIN
            PERSON_EXT_ATTRS salesPersonOverrideExt
        ON
            owner.center = salesPersonOverrideExt.PERSONCENTER
            AND owner.id = salesPersonOverrideExt.PERSONID
            AND salesPersonOverrideExt.name = 'MC_IT'
        LEFT JOIN
            PERSONS salesPersonOverride
        ON
            salesPersonOverride.CENTER || 'p' || salesPersonOverride.ID = salesPersonOverrideExt.TXTVALUE
        WHERE
            ss.SUBSCRIPTION_CENTER IN ($$Scope$$)
            AND sub.CREATION_TIME >= $$CreationFrom$$
            AND sub.CREATION_TIME < $$CreationTo$$ + (1000*60*60*24)
			AND S.END_DATE >= :End_Date_To OR S.END_DATE IS NULL)
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    SUBSCRIPTIONS oldsub
                JOIN
                    PERSONS oldPerson
                ON
                    oldSub.OWNER_CENTER = oldPerson.CENTER
                    AND oldSub.OWNER_ID = oldPerson.ID
                WHERE
                    oldPerson.CURRENT_PERSON_CENTER = owner.center
                    AND OldPerson.CURRENT_PERSON_ID = owner.ID
                    AND (
                        oldSub.CENTER <> sub.CENTER
                        OR oldSub.ID <> sub.ID)
                    AND oldSub.END_DATE + 30 > longtodateTZ(sub.CREATION_TIME, 'Europe/Copenhagen')
                    AND (
                        oldSub.STATE != 5
                        AND NOT(
                            oldSub.STATE = 3
                            AND oldSub.SUB_STATE = 8)))
            -- Exclude all transfers, extensions, upgrades, downgrades, cancelled and regretted
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    STATE_CHANGE_LOG SCLCHECK
                WHERE
                    SCLCHECK.CENTER = SUB.CENTER
                    AND SCLCHECK.ID = SUB.ID
                    AND SCLCHECK.ENTRY_TYPE = 2
					/*
                    AND SCLCHECK.STATEID IN (2,
                                             4,8)
					*/
                    AND SCLCHECK.SUB_STATE IN (3,4,5,6,7,8)
                    AND SCL1.ENTRY_START_TIME >= $$CreationFrom$$
                    AND SCL1.ENTRY_START_TIME < $$CreationTo$$ + (1000*60*60*24))
            AND EXISTS
            (
                SELECT
                    *
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                WHERE
                    pgl.PRODUCT_CENTER = prod.CENTER
                    AND pgl.PRODUCT_ID = prod.ID
                    AND pgl.PRODUCT_GROUP_ID IN (5401,5402,246,248)) ) i1
LEFT JOIN
    INVOICES inv
ON
    inv.PAYER_CENTER = i1.owner_center
    AND inv.PAYER_ID = i1.owner_id
LEFT JOIN
    INVOICELINES invl
ON
    invl.CENTER = inv.CENTER
    AND invl.ID = inv.ID
    AND longToDate(inv.TRANS_TIME) BETWEEN i1.sales_date AND i1.sales_date + 29
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
    AND prod.PRIMARY_PRODUCT_GROUP_ID IN (5401,5402,246,248,5607)
GROUP BY
    i1.SALES_DATE,
    i1.OWNER_CENTER,
    i1.OWNER_ID,
    i1.CLUB,
    i1.START_DATE,
    i1.SALES_PERSON,
    i1.ORIG_SALES_PERSON,
    i1.DATE_JOINED,
    i1.MEMBER_ID,
    i1.MEMBER_NAME,
    i1.MEMBERSHIP,
    i1.COMMISSIONABLE,
    i1.a,
    i1.b,
    i1.c,
    i1.d,
    i1.e,
    i1.f,
    i1.g,
    i1.h,
    i1.SCOURCE
ORDER BY
    i1.DATE_JOINED,
    i1.sales_person