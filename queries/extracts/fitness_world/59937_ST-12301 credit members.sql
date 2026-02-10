-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    ditinct_persons AS
    (
        SELECT DISTINCT
            center,
            id
        FROM
            EXERP_DB.ST12301_PERSONS
        WHERE 
			center IN (:Scope)
    ),
v_main AS
(
        SELECT distinct
            p.center||'p'||p.id AS membershipid,
            p.External_id,
            DECODE(p.STATUS,0,'LEAD',1,'ACTIVE',2,'INACTIVE',3,'TEMPORARYINACTIVE',4,'TRANSFERRED',5,
            'DUPLICATE',6,'PROSPECT',7,'DELETED',8,'ANONYMIZED',9,'CONTACT','Undefined') AS Statusprofil,
            DECODE (p.PERSONTYPE,0,'PRIVATE',1,'STUDENT',2,'STAFF',3,'FRIEND',4,'CORPORATE',5,
            'ONEMANCORPORATE',6, 'FAMILY',7,'SENIOR',8,'GUEST',9,'CHILD',10,'EXTERNAL_STAFF','Undefined') AS Persontype,
            pr.NAME                                        AS Medlemskabnavn,
            s.SUBSCRIPTION_PRICE                           AS MedlemskabNuvpris,
            s.center||'ss'||s.id                           AS MedlemskabID,
            s.END_DATE                                     AS Stopdato,
            sa_pr.name                                     AS AddonMedlemskabNavn,
            NVL(sa.INDIVIDUAL_PRICE_PER_UNIT, sa_pr.price) AS AddonNuvPris,
            cash_ar.balance                                AS Kontantkontosaldo,
            eft_ar.balance                                 AS Betalingkontosaldo,
            (CASE
                WHEN r.CENTER IS NOT NULL THEN r.CENTER || 'p' || r.ID
                ELSE NULL
            END) AS PayerId,
            eft_ar_payer.balance                                 AS Betalingkontosaldo_Payer,
            TO_CHAR(longtodatetz(
            (
                SELECT
                    MAX(att.START_TIME)
                FROM
                    attends att
                JOIN
                    centers c
                ON
                    c.id = att.CENTER
                WHERE
                    att.PERSON_CENTER = p.center
                AND att.PERSON_ID = p.id ), c.TIME_ZONE),'yyyy-MM-dd') AS Fremmødehistorik
        FROM
            ditinct_persons fwp
        JOIN
            FW.PERSONS p
        ON
            p.center = fwp.center
        AND p.id = fwp .id
        JOIN
            centers c
        ON
            c.id = p.center
        LEFT JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.OWNER_ID = p.id
        AND s.STATE IN (2,4,8)
        LEFT JOIN
            FW.SUBSCRIPTION_ADDON sa
        ON
            sa.SUBSCRIPTION_CENTER = s.center
        AND sa.SUBSCRIPTION_ID = s.id
        AND sa.CANCELLED = 0
        AND sa.START_DATE <= SYSDATE
        AND (
                sa.END_DATE IS NULL
            OR  sa.END_DATE > SYSDATE)
        LEFT JOIN
            FW.PRODUCTS pr
        ON
            pr.center = s.SUBSCRIPTIONTYPE_CENTER
        AND pr.id = s.SUBSCRIPTIONTYPE_ID
        LEFT JOIN
            FW.MASTERPRODUCTREGISTER sa_mpr
        ON
            sa_mpr.id = sa.ADDON_PRODUCT_ID
        LEFT JOIN
            FW.PRODUCTS sa_pr
        ON
            sa_pr.center = sa.CENTER_ID
        AND sa_pr.GLOBALID = sa_mpr.GLOBALID
        LEFT JOIN
            FW.ACCOUNT_RECEIVABLES cash_ar
        ON
            cash_ar.CUSTOMERCENTER = p.center
        AND cash_ar.CUSTOMERID = p.id
        AND cash_ar.AR_TYPE = 1
        LEFT JOIN
            FW.ACCOUNT_RECEIVABLES eft_ar
        ON
            eft_ar.CUSTOMERCENTER = p.center
        AND eft_ar.CUSTOMERID = p.id
        AND eft_ar.AR_TYPE = 4
        LEFT JOIN
            FW.RELATIVES r
        ON
            r.RELATIVECENTER = p.CENTER
            AND r.RELATIVEID = p.ID
            AND r.RTYPE = 12
            AND r.STATUS = 1
        LEFT JOIN
            FW.ACCOUNT_RECEIVABLES eft_ar_payer
        ON
            eft_ar_payer.CUSTOMERCENTER = r.center
        AND eft_ar_payer.CUSTOMERID = r.id
        AND eft_ar_payer.AR_TYPE = 4
        
),
v_pivot AS
(
        SELECT
                vm.*,
                LEAD(AddonMedlemskabNavn,1) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonName2,
                LEAD(AddonNuvPris,1) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonPrice2,
                LEAD(AddonMedlemskabNavn,2) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonName3,
                LEAD(AddonNuvPris,2) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonPrice3, 
                LEAD(AddonMedlemskabNavn,3) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonName4,
                LEAD(AddonNuvPris,3) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonPrice4, 
                LEAD(AddonMedlemskabNavn,4) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonName5,
                LEAD(AddonNuvPris,4) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonPrice5, 
                LEAD(AddonMedlemskabNavn,5) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonName6,
                LEAD(AddonNuvPris,5) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonPrice6, 
                LEAD(AddonMedlemskabNavn,6) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonName7,
                LEAD(AddonNuvPris,6) OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS AddonPrice7, 
                ROW_NUMBER() OVER (PARTITION BY membershipid, External_id, Statusprofil, Persontype, Medlemskabnavn, MedlemskabNuvpris, MedlemskabID, Stopdato, Kontantkontosaldo, Betalingkontosaldo, PayerId, Betalingkontosaldo_Payer, Fremmødehistorik ORDER BY membershipid) AS ADDONSEQ
        FROM v_main vm
)
SELECT
        vp.membershipid AS "Membership ID", 
        vp.External_id AS "External ID",
        vp.Statusprofil AS "Status - profil",
        vp.Persontype AS "Person type",
        vp.Medlemskabnavn AS "Medlemskab - navn",
        vp.MedlemskabNuvpris AS "Medlemskab - Nuv. pris",
        vp.MedlemskabID AS "Medlemskab - ID",
        vp.Stopdato AS "Stop-dato",
        vp.Kontantkontosaldo AS "Kontantkonto saldo",
        vp.Betalingkontosaldo AS "Betalingkonto saldo",
        vp.PayerId AS "Payer ID",
        vp.Betalingkontosaldo_Payer AS "Payer - Betalingkonto saldo",
        vp.Fremmødehistorik AS "Fremmøde historik",
        vp.AddonMedlemskabNavn AS "Add-on-1 - Medlemskab - Navn",
        vp.AddonNuvPris AS "Add-on-1 Nuv. Pris",
        vp.AddonName2 AS "Add-on-2 - Medlemskab - Navn",
        vp.AddonPrice2 AS "Add-on-2 Nuv. Pris",
        vp.AddonName3 AS "Add-on-3 - Medlemskab - Navn",
        vp.AddonPrice3 AS "Add-on-3 Nuv. Pris",
        vp.AddonName4 AS "Add-on-4 - Medlemskab - Navn",
        vp.AddonPrice4 AS "Add-on-4 Nuv. Pris",
        vp.AddonName5 AS "Add-on-5 - Medlemskab - Navn",
        vp.AddonPrice5 AS "Add-on-5 Nuv. Pris",
        vp.AddonName6 AS "Add-on-6 - Medlemskab - Navn",
        vp.AddonPrice6 AS "Add-on-6 Nuv. Pris",
        vp.AddonName7 AS "Add-on-7 - Medlemskab - Navn",
        vp.AddonPrice7 AS "Add-on-7 Nuv. Pris"
FROM v_pivot vp
WHERE
        ADDONSEQ = 1
