WITH
    v_main AS
    (
        SELECT DISTINCT
            center.id                          AS centerId,
            center.NAME                        AS centerName,
            p.center || 'p' || p.id            AS personid,
            personCreation.txtvalue            AS personCreationDate,
            salutation.txtvalue                AS title,
            p.firstname                        AS firstname,
            p.MIDDLENAME                       AS middlename,
            p.lastname                         AS lastname,
            p.ssn                              AS ssn,
            TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS birthdate,
            p.sex                              AS gender,
			REPLACE(REPLACE( p.ADDRESS1, CHR(10) ), CHR(13) ) AS AddressLine1,
            REPLACE(REPLACE( p.ADDRESS2, CHR(10) ), CHR(13) ) AS AddressLine2,
            REPLACE(REPLACE( p.ADDRESS3, CHR(10) ), CHR(13) ) AS AddressLine3,
            REPLACE(REPLACE( p.zipcode, CHR(10) ), CHR(13) ) AS zipcode,
            REPLACE(REPLACE( p.city, CHR(10) ), CHR(13))  AS city,
            REPLACE(REPLACE( zipcode.county, CHR(10) ), CHR(13) ) AS county,
            REPLACE(REPLACE( p.country, CHR(10) ), CHR(13) ) AS country,
            home.txtvalue                      AS homephone,
            workphone.txtvalue                 AS workphone,
            mobile.txtvalue                    AS mobilephone,
            email.txtvalue                     AS email,
            CASE
                WHEN has_sub.OWNER_CENTER IS NOT NULL
                THEN 'ACTIVE_EFT'
                WHEN has_cash_sub.OWNER_CENTER IS NOT NULL
                THEN 'ACTIVE_CASH'
                WHEN has_clipcard.OWNER_CENTER IS NOT NULL
                THEN 'CLIPCARD'
                WHEN pay_for.payer_CENTER IS NOT NULL
                THEN 'OTHER_PAYER'
                ELSE 'INACTIVE'
            END                                                                                                                                                       AS personcomment,
            DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PersonType,
            DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS PersonStatus,
            DECODE ( channelEmail.txtvalue, 'true', 1, 0)                                                                                                             AS ALLOWEDCHANNELEMAIL,
            DECODE ( channelLetter.txtvalue, 'true', 1, 0)                                                                                                            AS ALLOWEDCHANNELLETTER,
            DECODE ( channelPhone.txtvalue, 'true', 1, 0)                                                                                                             AS ALLOWEDCHANNELPHONE,
            DECODE ( channelSMS.txtvalue, 'true', 1, 0)                                                                                                               AS ALLOWEDCHANNELSMS,
            DECODE ( emailNewsLetter.txtvalue, 'true', 1, 0)                                                                                                          AS ALLOWEDCHANNELNEWSLETTERS,
            DECODE ( thirdPartyOffers.txtvalue, 'true', 1, 0)                                                                                                         AS ALLOWEDCHANNELTHIRDPARTYOFFERS,
            CASE
                WHEN pt_rel_p.center IS NOT NULL
                THEN pt_rel_p.center || 'p' || pt_rel_p.id
                ELSE NULL
            END               AS RelatedToId,
            pt_rel_p.fullname AS RelatedToName,
            CASE
                WHEN comp.CENTER IS NOT NULL
                THEN comp.CENTER||'p'||comp.ID
                ELSE NULL
            END                                                             AS RelatedToCompanyID,
            comp.lastname                                                   AS RelatedToCompanyName,
            cag.NAME                                                        AS RelatedToCompanyAgreement,
            cash_ar.balance                                                 AS CashAccountBalance,
            payment_ar.balance                                              AS PaymentAccountBalance,
            ei."IDENTITY"                                                   AS membercardid,
            pa.REF                                                          AS dd_referenceid,
            pa.CLEARINGHOUSE_REF                                            AS dd_contractid,
            pa.BANK_REGNO                                                      dd_bankreg,
            pa.BANK_BRANCH_NO                                               AS dd_bankbranch,
            pa.BANK_ACCNO                                                   AS dd_bankaccount,
            pa.BANK_ACCOUNT_HOLDER                                             dd_accountholder,
            pa.EXTRA_INFO                                                   AS dd_extrainfo,
            pa.IBAN                                                            dd_iban,
            TO_CHAR(longtodateC(pa.CREATION_TIME, pa.center), 'YYYY-MM-DD') AS dd_creationdate,
            CASE
                WHEN ( op.center IS NULL
                        AND pa.state IS NOT NULL
                        AND ( has_sub.owner_center IS NOT NULL
                            OR pay_for.payer_center IS NOT NULL ) )
                THEN DECODE(pa.STATE, 1,'CREATED', 2,'SENT', 3,'FAILED', 4,'OK', 5,'ENDED BY DEBITOR''S BANK', 6, 'ENDED BY THE CLEARING HOUSE', 7,'ENDED BY DEBITOR', 8,'SHAL BE CANCELLED', 9,'END REQUEST SENT', 10, 'ENDED BY CREDITOR', 11,'NO AGREEMENT WITH DEBITOR', 12,'DEPRECATED', 13,'NOT NEEDED',14, 'INCOMPLETE',15, 'TRANSFERRED','UNKNOWN')
                ELSE ''
            END AS dd_state,
            pa.REQUESTS_SENT,
            CASE
                WHEN op.center IS NOT NULL
                THEN op.FIRSTNAME || ' ' || op.LASTNAME
                ELSE NULL
            END    AS OTHERPAYERNAME,
            op.ssn AS OTHERPAYERSSN,
            CASE
                WHEN op.CENTER IS NOT NULL
                THEN op.center || 'p' || op.id
                ELSE ''
            END AS OTHERPAYERID,
            CASE
                WHEN pay_for.PAYER_CENTER IS NOT NULL
                THEN 'YES'
                ELSE 'NO'
            END AS IS_OTHER_PAYER,
            CASE
                WHEN has_sub.OWNER_CENTER IS NOT NULL
                THEN 'YES'
                ELSE 'NO'
            END AS HAS_EFT_SUB,
            CASE
                WHEN has_cash_sub.OWNER_CENTER IS NOT NULL
                THEN 'YES'
                ELSE 'NO'
            END AS HAS_CASH_SUB,
            CASE
                WHEN has_clipcard.OWNER_CENTER IS NOT NULL
                THEN 'YES'
                ELSE 'NO'
            END                                                           AS HAS_CLIP_CARD,
            s.center || 'ss' || s.id                                      AS MembershipId,
            TO_CHAR(longtodateC(s.CREATION_TIME, s.center), 'YYYY-MM-DD') AS MembershipCreationDate,
            TO_CHAR(s.START_DATE, 'YYYY-MM-DD')                           AS MembershipStartDate,
            TO_CHAR(s.END_DATE, 'YYYY-MM-DD')                             AS MembershipEndDate,
            pd.GLOBALID                                                   AS MembershipGlobalName,
            pd.name                                                       AS MembershipName,
            DECODE(st.st_type, 0, 'CASH', 1, 'DD')                        AS MembershipType,
            s.BINDING_PRICE,
            TO_CHAR(s.BINDING_END_DATE, 'YYYY-MM-DD') bindingenddate,
            s.SUBSCRIPTION_PRICE,
            CASE
                WHEN st.st_type = 0
                THEN TO_CHAR(s.end_date, 'YYYY-MM-DD')
                ELSE TO_CHAR(s.BILLED_UNTIL_DATE, 'YYYY-MM-DD')
            END AS BilledUntilDate ,
            longtodateC(sc.CHANGE_TIME, sc.new_subscription_center) as MembershipCancelDate,
            CASE
                WHEN st.ST_TYPE = 1
                    AND priv.SPONSORSHIP_NAME IS NOT NULL
                THEN priv.SPONSORSHIP_NAME
                ELSE NULL
            END AS SponsorshipName ,
            CASE
                WHEN st.ST_TYPE = 1
                    AND priv.SPONSORSHIP_NAME IS NOT NULL
                THEN priv.SPONSORSHIP_AMOUNT
                ELSE NULL
            END                                AS Sponsorship_amount,
            companyAgreementEmpNumber.txtvalue AS companyAgreementEmployeeNumber,
            fh.FreezeFrom,
            fh.FreezeTo,
            fh.FreezeReason,
            NVL2(fh.FreezeFrom, freezeproduct.price, null) as freezeprice,
            m.GLOBALID                                                                                              AS addonname,
            sa.individual_price_per_unit                                                                            AS addonprice,
            sa.start_date                                                                                           AS addonstartdate,
            sa.end_date                                                                                             AS addonenddate,
            sa.binding_end_date                                                                                     AS addonbindingenddate,
            DECODE (s.sub_state, 9, 'YES', 'NO')                                                                    AS blockedmembership,
            TO_CHAR(longToDateC(last_checkin.last_checkintime, last_checkin.person_center),'yyyy-MM-dd HH24:MI:SS') AS LastVisitTime,
            pruEntityNumber.TXTVALUE                                                                                AS PruEntityNumber,
            pruEntityAuthCode.TXTVALUE                                                                              AS PruEntityAuthCode,
            pruPlanType.TXTVALUE                                                                                    AS PruPlanType
        FROM
            persons p
        JOIN
            CENTERS center
        ON
            p.center = center.id
        LEFT JOIN
            subscriptions s
        ON
            s.owner_center = p.center
            AND s.owner_id = p.id
            AND s.STATE IN (2,4,8)
        LEFT JOIN
            SUBSCRIPTION_CHANGE sc
        ON
            NVL(sc.NEW_SUBSCRIPTION_CENTER,sc.OLD_SUBSCRIPTION_CENTER)=s.CENTER
            AND NVL(sc.NEW_SUBSCRIPTION_ID,sc.OLD_SUBSCRIPTION_ID)=s.ID
            AND sc.TYPE='END_DATE'
            AND sc.CANCEL_TIME IS NULL
        LEFT JOIN
            SUBSCRIPTION_ADDON sa
        ON
            sa.SUBSCRIPTION_CENTER = s.CENTER
            AND sa.SUBSCRIPTION_ID=s.ID
            AND NVL(sa.end_date, SYSDATE) > SYSDATE -1
        LEFT JOIN
            MASTERPRODUCTREGISTER m
        ON
            sa.ADDON_PRODUCT_ID=m.ID
        LEFT JOIN
            SUBSCRIPTIONTYPES st
        ON
            s.SUBSCRIPTIONTYPE_CENTER=st.center
            AND s.SUBSCRIPTIONTYPE_ID=st.id
        LEFT JOIN
            PRODUCTS pd
        ON
            st.center=pd.center
            AND st.id=pd.id
        LEFT JOIN
            PRODUCTS freezeproduct
        ON
            freezeproduct.center = st.FREEZEPERIODPRODUCT_CENTER
            AND freezeproduct.id = st.FREEZEPERIODPRODUCT_ID
            and freezeproduct.PTYPE=7
        LEFT JOIN
            (
                SELECT
                    fr.subscription_center,
                    fr.subscription_id,
                    TO_CHAR(MIN(fr.START_DATE), 'YYYY-MM-DD') AS FreezeFrom,
                    TO_CHAR(MAX(fr.END_DATE), 'YYYY-MM-DD')   AS FreezeTo,
                    MIN(fr.text)                              AS FreezeReason
                FROM
                    SUBSCRIPTION_FREEZE_PERIOD fr
                WHERE
                    fr.subscription_center IN (26,451,73)
                    AND fr.END_DATE > SYSDATE
                GROUP BY
                    fr.subscription_center,
                    fr.subscription_id ) fh
        ON
            fh.subscription_center = s.center
            AND fh.subscription_id = s.id
        LEFT JOIN
            (
                SELECT
                    car.center,
                    car.id,
                    pg.SPONSORSHIP_NAME,
                    pp.REF_GLOBALID,
                    pg.SPONSORSHIP_AMOUNT
                FROM
                    relatives car
                JOIN
                    COMPANYAGREEMENTS ca
                ON
                    ca.center = car.RELATIVECENTER
                    AND ca.id = car.RELATIVEID
                    AND ca.SUBID = car.RELATIVESUBID
                JOIN
                    PRIVILEGE_GRANTS pg
                ON
                    pg.GRANTER_SERVICE='CompanyAgreement'
                    AND pg.GRANTER_CENTER=ca.center
                    AND pg.granter_id=ca.id
                    AND pg.GRANTER_SUBID = ca.SUBID
                    AND pg.SPONSORSHIP_NAME!= 'NONE'
                    AND (
                        pg.VALID_TO IS NULL
                        OR pg.VALID_TO > datetolong(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MM')) )
                JOIN
                    PRODUCT_PRIVILEGES pp
                ON
                    pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
                WHERE
                    car.RTYPE = 3
                    AND car.STATUS < 3
                    AND car.center IN (26,451,73)
                GROUP BY
                    car.center,
                    car.id,
                    pg.SPONSORSHIP_NAME,
                    pp.REF_GLOBALID,
                    pg.SPONSORSHIP_AMOUNT ) priv
        ON
            priv.center=p.center
            AND priv.id = p.id
            AND priv.REF_GLOBALID = pd.GLOBALID
        LEFT JOIN
            zipcodes zipcode
        ON
            zipcode.country = p.country
            AND zipcode.zipcode = p.zipcode
        LEFT JOIN
            PERSON_EXT_ATTRS salutation
        ON
            p.center=salutation.PERSONCENTER
            AND p.id=salutation.PERSONID
            AND salutation.name='_eClub_Salutation'
        LEFT JOIN
            PERSON_EXT_ATTRS personCreation
        ON
            p.center=personCreation.PERSONCENTER
            AND p.id=personCreation.PERSONID
            AND personCreation.name='CREATION_DATE'
        LEFT JOIN
            PERSON_EXT_ATTRS home
        ON
            p.center=home.PERSONCENTER
            AND p.id=home.PERSONID
            AND home.name='_eClub_PhoneHome'
        LEFT JOIN
            PERSON_EXT_ATTRS mobile
        ON
            p.center=mobile.PERSONCENTER
            AND p.id=mobile.PERSONID
            AND mobile.name='_eClub_PhoneSMS'
        LEFT JOIN
            PERSON_EXT_ATTRS workphone
        ON
            p.center=workphone.PERSONCENTER
            AND p.id=workphone.PERSONID
            AND workphone.name='_eClub_PhoneWork'
        LEFT JOIN
            PERSON_EXT_ATTRS email
        ON
            p.center=email.PERSONCENTER
            AND p.id=email.PERSONID
            AND email.name='_eClub_Email'
        LEFT JOIN
            PERSON_EXT_ATTRS personcomment
        ON
            p.center=personcomment.PERSONCENTER
            AND p.id=personcomment.PERSONID
            AND personcomment.name='_eClub_Comment'
        LEFT JOIN
            PERSON_EXT_ATTRS channelEmail
        ON
            p.center=channelEmail.PERSONCENTER
            AND p.id=channelEmail.PERSONID
            AND channelEmail.name='_eClub_AllowedChannelEmail'
        LEFT JOIN
            PERSON_EXT_ATTRS channelLetter
        ON
            p.center=channelLetter.PERSONCENTER
            AND p.id=channelLetter.PERSONID
            AND channelLetter.name='_eClub_AllowedChannelLetter'
        LEFT JOIN
            PERSON_EXT_ATTRS channelPhone
        ON
            p.center=channelPhone.PERSONCENTER
            AND p.id=channelPhone.PERSONID
            AND channelPhone.name='_eClub_AllowedChannelPhone'
        LEFT JOIN
            PERSON_EXT_ATTRS channelSMS
        ON
            p.center=channelSMS.PERSONCENTER
            AND p.id=channelSMS.PERSONID
            AND channelSMS.name='_eClub_AllowedChannelSMS'
        LEFT JOIN
            PERSON_EXT_ATTRS emailNewsLetter
        ON
            p.center=emailNewsLetter.PERSONCENTER
            AND p.id=emailNewsLetter.PERSONID
            AND emailNewsLetter.name='_eClub_IsAcceptingEmailNewsLetters'
        LEFT JOIN
            PERSON_EXT_ATTRS thirdPartyOffers
        ON
            p.center=thirdPartyOffers.PERSONCENTER
            AND p.id=thirdPartyOffers.PERSONID
            AND thirdPartyOffers.name='_eClub_IsAcceptingThirdPartyOffers'
        LEFT JOIN
            PERSON_EXT_ATTRS companyAgreementEmpNumber
        ON
            p.center=companyAgreementEmpNumber.PERSONCENTER
            AND p.id=companyAgreementEmpNumber.PERSONID
            AND companyAgreementEmpNumber.name='COMPANY_AGREEMENT_EMPLOYEE_NUMBER'
        LEFT JOIN
            PERSON_EXT_ATTRS pruEntityNumber
        ON
            pruEntityNumber.PERSONCENTER=p.CENTER
            AND pruEntityNumber.PERSONID=p.ID
            AND pruEntityNumber.NAME='_eClub_PBLookupPartnerPersonId'
        LEFT JOIN
            PERSON_EXT_ATTRS pruEntityAuthCode
        ON
            pruEntityAuthCode.PERSONCENTER=p.CENTER
            AND pruEntityAuthCode.PERSONID=p.ID
            AND pruEntityAuthCode.NAME='_eClub_PBLookupAuthorizationCode'
        LEFT JOIN
            PERSON_EXT_ATTRS pruPlanType
        ON
            pruPlanType.PERSONCENTER=p.CENTER
            AND pruPlanType.PERSONID=p.ID
            AND pruPlanType.NAME='_eClub_PBLookupEligibleBenefitId'
        LEFT JOIN
            ACCOUNT_RECEIVABLES payment_ar
        ON
            payment_ar.CUSTOMERCENTER = p.center
            AND payment_ar.CUSTOMERID = p.id
            AND payment_ar.AR_TYPE = 4
        LEFT JOIN
            ACCOUNT_RECEIVABLES cash_ar
        ON
            cash_ar.CUSTOMERCENTER=p.center
            AND cash_ar.CUSTOMERID=p.id
            AND cash_ar.AR_TYPE = 1
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
            persons comp
        ON
            comp.center = cag.center
            AND comp.id=cag.id
        LEFT JOIN
            ENTITYIDENTIFIERS ei
        ON
            ei.REF_CENTER = p.CENTER
            AND ei.REF_ID = p.id
            AND ei.entitystatus = 1
        LEFT JOIN
            PAYMENT_ACCOUNTS paymentaccount
        ON
            paymentaccount.center = payment_ar.center
            AND paymentaccount.id = payment_ar.id
        LEFT JOIN
            PAYMENT_AGREEMENTS pa
        ON
            paymentaccount.ACTIVE_AGR_CENTER = pa.center
            AND paymentaccount.ACTIVE_AGR_ID = pa.id
            AND paymentaccount.ACTIVE_AGR_SUBID = pa.subid
        LEFT JOIN
            RELATIVES op_rel
        ON
            op_rel.relativecenter=p.center
            AND op_rel.relativeid=p.id
            AND op_rel.RTYPE = 12
            AND op_rel.STATUS < 3
        LEFT JOIN
            PERSONS op
        ON
            op.center = op_rel.center
            AND op.id = op_rel.id
        LEFT JOIN
            ACCOUNT_RECEIVABLES otherPayerAR
        ON
            otherPayerAR.CUSTOMERCENTER = op.center
            AND otherPayerAR.CUSTOMERID = op.id
            AND otherPayerAR.AR_TYPE = 4
            -- other payer
        LEFT JOIN
            (
                SELECT DISTINCT
                    rel.center AS PAYER_CENTER,
                    rel.id     AS PAYER_ID
                FROM
                    PERSONS mem
                JOIN
                    SUBSCRIPTIONS sub
                ON
                    mem.center = sub.OWNER_CENTER
                    AND mem.id = sub.OWNER_ID
                    AND sub.STATE IN (2,4,8)
                    AND (
                        sub.end_date IS NULL
                        OR sub.end_date > sub.BILLED_UNTIL_DATE )
                JOIN
                    SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
                    AND st.id = sub.SUBSCRIPTIONTYPE_ID
                JOIN
                    RELATIVES rel
                ON
                    rel.RELATIVECENTER = mem.center
                    AND rel.RELATIVEID = mem.id
                    AND rel.RTYPE = 12
                    AND rel.STATUS < 3
                WHERE
                    st.ST_TYPE = 1
                    AND mem.persontype NOT IN (2,8) ) pay_for
        ON
            pay_for.payer_center = p.center
            AND pay_for.payer_id = p.id
            -- has eft sub
        LEFT JOIN
            (
                SELECT DISTINCT
                    sub.owner_center,
                    sub.owner_id
                FROM
                    SUBSCRIPTIONS sub
                JOIN
                    SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
                    AND st.id = sub.SUBSCRIPTIONTYPE_ID
                WHERE
                    st.ST_TYPE = 1
                    AND sub.STATE IN (2,4,8) ) has_sub
        ON
            has_sub.owner_center = p.center
            AND has_sub.owner_id = p.id
            -- has cash sub
        LEFT JOIN
            (
                SELECT DISTINCT
                    sub.owner_center,
                    sub.owner_id
                FROM
                    SUBSCRIPTIONS sub
                JOIN
                    SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
                    AND st.id = sub.SUBSCRIPTIONTYPE_ID
                WHERE
                    st.ST_TYPE = 0
                    AND sub.STATE IN (2,4,8) ) has_cash_sub
        ON
            has_cash_sub.owner_center = p.center
            AND has_cash_sub.owner_id = p.id
            -- clipcards
        LEFT JOIN
            (
                SELECT DISTINCT
                    clips.OWNER_CENTER,
                    clips.OWNER_ID
                FROM
                    clipcards clips
                JOIN
                    products pd
                ON
                    pd.center = clips.center
                    AND pd.id = clips.id
                WHERE
                    clips.CLIPS_LEFT > 0
                    AND clips.FINISHED = 0
                    AND clips.CANCELLED = 0
                    AND clips.BLOCKED = 0 ) has_clipcard
        ON
            has_clipcard.owner_center = p.center
            AND has_clipcard.owner_id = p.id
            -- get friends, family relation
        LEFT JOIN
            RELATIVES pt_rel
        ON
            pt_rel.CENTER = p.center
            AND pt_rel.id = p.id
            AND pt_rel.STATUS < 3
            AND ( (
                    p.PERSONTYPE = 3
                    AND pt_rel.RTYPE = 1 )
                OR (
                    p.PERSONTYPE = 6
                    AND pt_rel.RTYPE = 4 ) )
        LEFT JOIN
            PERSONS pt_rel_p
        ON
            pt_rel_p.center = pt_rel.RELATIVECENTER
            AND pt_rel_p.id = pt_rel.RELATIVEID
        LEFT JOIN
            CASHCOLLECTIONCASES ccc
        ON
            ccc.PERSONCENTER = p.center
            AND ccc.PERSONID = p.id
            AND ccc.CLOSED = 0
            AND ccc.MISSINGPAYMENT = 1
        LEFT JOIN
            (
                SELECT
                    ch.person_center,
                    ch.person_id,
                    MAX(ch.checkin_time) AS last_checkintime
                FROM
                    checkins ch
                GROUP BY
                    ch.person_center,
                    ch.person_id) last_checkin
        ON
            last_checkin.person_center = p.center
            AND last_checkin.person_id = p.id
        WHERE
           p.center IN(26,451,73)
            -- no guest records
            AND p.persontype NOT IN (8)
            AND (
                -- active,temp inactive, prospect,contact
                p.status IN (1,3,6,9)
                -- Open debt collection case member
                OR ccc.id IS NOT NULL
                -- inactive member from last 6 months
                OR (
                    p.status = 2
                    AND EXISTS
                    (
                        SELECT
                            1
                        FROM
                            STATE_CHANGE_LOG scl
                        WHERE
                            scl.CENTER = p.CENTER
                            AND scl.ID = p.ID
                            AND scl.ENTRY_TYPE=1
                            AND scl.BOOK_END_TIME IS NULL
                            AND scl.STATEID=2
                            AND scl.ENTRY_START_TIME > exerpro.datetolong(TO_CHAR(add_months(SYSDATE,-6),'YYYY-MM-DD HH24:MI')))) )
    )    
    ,
    v_pivot AS
    (
        SELECT
            v_main.* ,
            LEAD(ADDONNAME,1) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)           AS ADDONNAME2 ,
            LEAD(ADDONPRICE,1) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)          AS ADDONPRICE2 ,
            LEAD(ADDONSTARTDATE,1) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)      AS ADDONSTARTDATE2 ,
            LEAD(ADDONENDDATE,1) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)        AS ADDONENDDATE2 ,
            LEAD(ADDONBINDINGENDDATE,1) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME) AS ADDONBINDINGENDDATE2
            --
            ,
            LEAD(ADDONNAME,2) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)           AS ADDONNAME3 ,
            LEAD(ADDONPRICE,2) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)          AS ADDONPRICE3 ,
            LEAD(ADDONSTARTDATE,2) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)      AS ADDONSTARTDATE3 ,
            LEAD(ADDONENDDATE,2) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)        AS ADDONENDDATE3 ,
            LEAD(ADDONBINDINGENDDATE,2) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME) AS ADDONBINDINGENDDATE3
            --
            ,
            LEAD(ADDONNAME,3) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)           AS ADDONNAME4 ,
            LEAD(ADDONPRICE,3) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)          AS ADDONPRICE4 ,
            LEAD(ADDONSTARTDATE,3) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)      AS ADDONSTARTDATE4 ,
            LEAD(ADDONENDDATE,3) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)        AS ADDONENDDATE4 ,
            LEAD(ADDONBINDINGENDDATE,3) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME) AS ADDONBINDINGENDDATE4
            --
            ,
            LEAD(ADDONNAME,4) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)           AS ADDONNAME5 ,
            LEAD(ADDONPRICE,4) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)          AS ADDONPRICE5 ,
            LEAD(ADDONSTARTDATE,4) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)      AS ADDONSTARTDATE5 ,
            LEAD(ADDONENDDATE,4) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME)        AS ADDONENDDATE5 ,
            LEAD(ADDONBINDINGENDDATE,4) OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME) AS ADDONBINDINGENDDATE5
            --
            ,
            ROW_NUMBER() OVER (PARTITION BY PERSONID, MEMBERSHIPID ORDER BY ADDONSTARTDATE, ADDONNAME) AS ADDONSEQ
        FROM
            v_main
    )
SELECT
    CENTERID ,
    CENTERNAME ,
    PERSONID ,
    PERSONCREATIONDATE ,
    TITLE ,
    FIRSTNAME ,
    MIDDLENAME ,
    LASTNAME ,
    SSN ,
    BIRTHDATE ,
    GENDER ,
    ADDRESSLINE1 ,
    ADDRESSLINE2 ,
    ADDRESSLINE3 ,
    ZIPCODE ,
    CITY ,
    COUNTY ,
    COUNTRY ,
    HOMEPHONE ,
    WORKPHONE ,
    MOBILEPHONE ,
    EMAIL ,
    PERSONCOMMENT ,
    PERSONTYPE ,
    PersonStatus,
    ALLOWEDCHANNELEMAIL ,
    ALLOWEDCHANNELLETTER ,
    ALLOWEDCHANNELPHONE ,
    ALLOWEDCHANNELSMS ,
    ALLOWEDCHANNELNEWSLETTERS ,
    ALLOWEDCHANNELTHIRDPARTYOFFERS ,
    RELATEDTOID ,
    RELATEDTONAME ,
    RELATEDTOCOMPANYID ,
    RELATEDTOCOMPANYNAME ,
    RELATEDTOCOMPANYAGREEMENT ,
    CASHACCOUNTBALANCE ,
    PAYMENTACCOUNTBALANCE ,
    MEMBERCARDID ,
    DD_REFERENCEID ,
    DD_CONTRACTID ,
    DD_BANKREG ,
    DD_BANKBRANCH ,
    DD_BANKACCOUNT ,
    DD_ACCOUNTHOLDER ,
    DD_EXTRAINFO ,
    DD_IBAN ,
    DD_CREATIONDATE ,
    DD_STATE ,
    REQUESTS_SENT ,
    OTHERPAYERNAME ,
    OTHERPAYERSSN ,
    OTHERPAYERID ,
    IS_OTHER_PAYER ,
    HAS_EFT_SUB ,
    HAS_CASH_SUB ,
    HAS_CLIP_CARD ,
    MEMBERSHIPID ,
    MEMBERSHIPCREATIONDATE ,
    MEMBERSHIPSTARTDATE ,
    MEMBERSHIPENDDATE ,
    MEMBERSHIPGLOBALNAME ,
    MEMBERSHIPNAME ,
    MEMBERSHIPTYPE ,
    BINDING_PRICE ,
    BINDINGENDDATE ,
    SUBSCRIPTION_PRICE ,
    BILLEDUNTILDATE ,
    MembershipCancelDate,
    SPONSORSHIPNAME ,
    SPONSORSHIP_AMOUNT ,
    COMPANYAGREEMENTEMPLOYEENUMBER ,
    FREEZEFROM ,
    FREEZETO ,
    FREEZEREASON ,
    FREEZEPRICE,
    ADDONNAME           AS ADDONNAME1 ,
    ADDONPRICE          AS ADDONPRICE1 ,
    ADDONSTARTDATE      AS ADDONSTARTDATE1 ,
    ADDONENDDATE        AS ADDONENDDATE1 ,
    ADDONBINDINGENDDATE AS ADDONBINDINGENDDATE1 ,
    ADDONNAME2 ,
    ADDONPRICE2 ,
    ADDONSTARTDATE2 ,
    ADDONENDDATE2 ,
    ADDONBINDINGENDDATE2 ,
    ADDONNAME3 ,
    ADDONPRICE3 ,
    ADDONSTARTDATE3 ,
    ADDONENDDATE3 ,
    ADDONBINDINGENDDATE3 ,
    ADDONNAME4 ,
    ADDONPRICE4 ,
    ADDONSTARTDATE4 ,
    ADDONENDDATE4 ,
    ADDONBINDINGENDDATE4 ,
    ADDONNAME5 ,
    ADDONPRICE5 ,
    ADDONSTARTDATE5 ,
    ADDONENDDATE5 ,
    ADDONBINDINGENDDATE5 ,
    BLOCKEDMEMBERSHIP ,
    LASTVISITTIME ,
    PRUENTITYNUMBER ,
    PRUENTITYAUTHCODE ,
    PRUPLANTYPE
FROM
    v_pivot
WHERE
    ADDONSEQ=1