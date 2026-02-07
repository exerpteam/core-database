SELECT DISTINCT
    "Club",
    "Member ID",
    "old system person ID",
    PERSONTYPE,
    MAX("Family Link")   AS "Family Link",
    MAX("My payer ID")   AS "My payer ID",
    --MAX("My payer Name") AS "My payer Name",
    --"Title",
    --FIRSTNAME,
    --LASTNAME,
    --ADDRESS1,
    --ADDRESS2,
    --ADDRESS3,
    --"Post Code",
    --"Email",
    --"Mobile",
    --"Home Phone",
    "Join Date",
    "Date of Birth",
    "Membership Start Date",
    "Membership End Date",
    "Membership Subscription",
    "Membership Subscription Value",
    "Membership Status",
    --"Age of oldest debt (DAYS)",
    --"Membership Arrears Balance",
    --DECODE(MAX("Upfront"),1,'y',0,'n') AS "Upfront",
    --DECODE(MAX("Pru"),1,'y',0,'n')     AS "Pru",
    --DECODE(MAX("staff"),1,'y',0,'n')   AS "staff",
    --DECODE(MAX("Buddy"),1,'y',0,'n')   AS "Buddy",
    --MAX("Buddy of")                    AS "Buddy of",
    "Corporate Funded",
    MAX("Company Name")                         AS "Company Name",
    --MAX("Company Contact's Title")              AS "Company Contact's Title",
    --MAX("Comp Contact's Firstname")             AS "Comp Contact's Firstname",
    --MAX("Comp Contact's Last Name")             AS "Comp Contact's Last Name",
    --MAX("Comp Contact's Address Line 1")        AS "Comp Contact's Address Line 1" ,
    --MAX("Comp Contact's Address Line 2")        AS "Comp Contact's Address Line 2" ,
    --MAX("Comp Contact's Address Line 3")        AS "Comp Contact's Address Line 3" ,
    --MAX("Comp Contact's Post Code")             AS "Comp Contact's Post Code" ,
    --MAX("Comp Contact's E-mail")                AS "Comp Contact's E-mail" ,
    --MAX("Comp Contact's Mobile")                AS "Comp Contact's Mobile" ,
    --DECODE(MAX("Has Recurring PT"),1,'y',0,'n') AS "Has Recurring PT",
    --"Recurring PT Pack Product",
    --"Recurring PT Value",
    CASE
        WHEN "Recurring PT Pack Product" IS NOT NULL
            AND instr("Recurring PT Pack Product",'4') !=0
        THEN 4 - NVL("sessions used on recurring PT",0)
        WHEN "Recurring PT Pack Product" IS NOT NULL
            AND instr("Recurring PT Pack Product",'8') !=0
        THEN 8 - NVL("sessions used on recurring PT",0)
        WHEN "Recurring PT Pack Product" IS NOT NULL
            AND instr("Recurring PT Pack Product",'12') !=0
        THEN 12 - NVL("sessions used on recurring PT",0)
        WHEN "Recurring PT Pack Product" = 'Deployment PT'
        THEN 0
        WHEN "Recurring PT Pack Product" IS NULL
        THEN NULL
        ELSE -1
    END                                            --AS "sessions left on recurring PT",
    DECODE(MAX("Has Current PT Pack"),1,'y',0,'n') --AS "Has Current PT Pack",
    --"PT Pack Product",
    --"PT Pack Value",
    --"PT Pack Expiry Date",
    --"No of sessions left on PT Pack",
    --"Last Swim Purchase Date",
    --"Last Swim Purchase Value",
   -- "Bank Sort Code",
   -- "Bank Account Code",
    --"Payment Agreement Reference",
    --"Payment Agreement Status",
    MAX(DECODE("Company agreement id",'prpt',NULL,"Company agreement id")) AS "Company agreement id",
    MAX("Company agreement name")                                          AS "Company agreement name"
    DECODE(IS_PRICE_UPDATE_EXCLUDED,0,'No',1,'Yes')                        --AS "Manually Excluded"
FROM
    (
        SELECT
            c.NAME                                                                                                                                                  AS "Club",
            p.center||'p'||p.id                                                                                                                                     AS "Member ID",
            OldID.TXTVALUE                                                                                                                                          AS "old system person ID",
            DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
            DECODE(r.RTYPE,4,DECODE(r.RELATIVECENTER||'p'||r.RELATIVEID,'p',NULL,r.RELATIVECENTER||'p'||r.RELATIVEID),NULL)                                         AS "Family Link",
            DECODE(r2.RTYPE,12,r2.center||'p'||r2.id,NULL)                                                                                                          AS "My payer ID",
            DECODE(r2.RTYPE,12,payer.FULLNAME,NULL)                                                                                                                 AS "My payer Name",
            salutation.TXTVALUE                                                                                                                                     AS "Title",
            p.FIRSTNAME,
            p.LASTNAME,
            p.ADDRESS1,
            p.ADDRESS2,
            p.ADDRESS3,
            p.ZIPCODE                                                                                                       AS "Post Code",
            email.TXTVALUE                                                                                                  AS "Email",
            mobile.TXTVALUE                                                                                                 AS "Mobile",
            home.TXTVALUE                                                                                                   AS "Home Phone",
            Creationdate.TXTVALUE                                                                                           AS "Join Date",
            TO_CHAR(p.BIRTHDATE,'yyyy-MM-dd')                                                                               AS "Date of Birth",
            TO_CHAR(s.START_DATE,'yyyy-MM-dd')                                                                              AS "Membership Start Date",
            TO_CHAR(s.END_DATE,'yyyy-MM-dd')                                                                                AS "Membership End Date",
            pr.NAME                                                                                                         AS "Membership Subscription",
            s.SUBSCRIPTION_PRICE                                                                                            AS "Membership Subscription Value",
            DECODE(s.STATE,2, 'ACTIVE', 4 , 'FROZEN')                                                                       AS "Membership Status",
            TRUNC(SYSDATE+1) - ccc.STARTDATE                                                                                AS "Age of oldest debt (DAYS)",
            NVL(ar.BALANCE + ar2.BALANCE,0)                                                                                 AS "Membership Arrears Balance",
            DECODE(st.ST_TYPE,0,1,0)                                                                                        AS "Upfront",
            DECODE(ppgl.PRODUCT_GROUP_ID,NULL,0,1)                                                                          AS "Pru",
            DECODE(pr.GLOBALID,'21',1,'25',1,0)                                                                             AS "staff",
            DECODE(pr.GLOBALID,'22',1,'26',1,0)                                                                             AS "Buddy",
            DECODE(r.RTYPE,1,DECODE(r.RELATIVECENTER||'p'||r.RELATIVEID,'p',NULL,r.RELATIVECENTER||'p'||r.RELATIVEID),NULL) AS "Buddy of",
            DECODE(is_sponsored.center,NULL,'n','y')                                                                        AS "Corporate Funded",
            comp.FULLNAME                                                                                                   AS "Company Name",
            cont_salutation.TXTVALUE                                                                                        AS "Company Contact's Title",
            cont.FIRSTNAME                                                                                                  AS "Comp Contact's Firstname",
            cont.LASTNAME                                                                                                   AS "Comp Contact's Last Name",
            cont.ADDRESS1                                                                                                   AS "Comp Contact's Address Line 1",
            cont.ADDRESS2                                                                                                   AS "Comp Contact's Address Line 2",
            cont.ADDRESS3                                                                                                   AS "Comp Contact's Address Line 3",
            cont.ZIPCODE                                                                                                    AS "Comp Contact's Post Code",
            cont_email.TXTVALUE                                                                                             AS "Comp Contact's E-mail",
            cont_mobile.TXTVALUE                                                                                            AS "Comp Contact's Mobile",
            DECODE(rec_pt.name,NULL,0,1)                                                                                    AS "Has Recurring PT",
            rec_pt.name                                                                                                     AS "Recurring PT Pack Product",
            rec_pt.price                                                                                                    AS "Recurring PT Value",
            rec_pt_packs_counter.num                                                                                        AS "sessions used on recurring PT",
            CASE
                WHEN cc.valid_until > exerpro.dateToLong(TO_CHAR(SYSDATE, 'YYYY-MM-dd HH24:MI'))
                    AND cc.clips_left>0
                THEN 1
                ELSE 0
            END                                                                                                                                                                                                        AS "Has Current PT Pack",
            cc.pr_name                                                                                                                                                                                                        AS "PT Pack Product",
            cc.pr_price                                                                                                                                                                                                        AS "PT Pack Value",
            exerpro.longtodate(cc.valid_until)                                                                                                                                                                                                        AS "PT Pack Expiry Date",
            cc.clips_left                                                                                                                                                                                                        AS "No of sessions left on PT Pack",
            exerpro.longtodate(last_swim.TRANS_TIME)                                                                                                                                                                                                        AS "Last Swim Purchase Date",
            last_swim.price                                                                                                                                                                                                        AS "Last Swim Purchase Value",
            pa.BANK_ACCNO                                                                                                                                                                                                        AS "Bank Account Code",
            pa.BANK_REGNO                                                                                                                                                                                                        AS "Bank Sort Code",
            pa.REF                                                                                                                                                                                                        AS "Payment Agreement Reference",
            DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') AS "Payment Agreement Status",
            compa.NAME                                                                                                                                                                                                        AS "Company agreement name",
            compa.center||'p'||compa.id||'rpt'||compa.SUBID                                                                                                                                                                                                        AS "Company agreement id",
            st.IS_PRICE_UPDATE_EXCLUDED
        FROM
            PERSONS p
        JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.STATE IN (2,4)
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.id = s.SUBSCRIPTIONTYPE_ID
        JOIN
            PRODUCTS pr
        ON
            pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND pr.id = s.SUBSCRIPTIONTYPE_ID
            --staff,pru,buddy PT DD standard
        LEFT JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        ON
            ppgl.PRODUCT_CENTER = pr.CENTER
            AND ppgl.PRODUCT_ID = pr.ID
            AND ppgl.PRODUCT_GROUP_ID IN(247,268)
        LEFT JOIN
            (
            (
                SELECT
                    s.OWNER_CENTER,
                    s.OWNER_ID,
                    pr.NAME,
                    pr.PRICE
                FROM
                    SUBSCRIPTIONS s
                JOIN
                    PRODUCTS pr
                ON
                    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND pr.id = s.SUBSCRIPTIONTYPE_ID
                JOIN
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
                ON
                    ppgl.PRODUCT_CENTER = pr.CENTER
                    AND ppgl.PRODUCT_ID = pr.ID
                    AND ppgl.PRODUCT_GROUP_ID IN( 277 )
                WHERE
                    s.center IN ($$scope$$)
                    AND s.START_DATE <= SYSDATE
                    AND (
                        s.END_DATE > SYSDATE
                        OR s.END_DATE IS NULL))
        UNION
            (
                SELECT
                    s1.OWNER_CENTER,
                    s1.OWNER_ID,
                    pr2.NAME,
                    pr2.PRICE
                FROM
                    SUBSCRIPTION_ADDON sa
                JOIN
                    SUBSCRIPTIONS s1
                ON
                    sa.SUBSCRIPTION_CENTER = s1.CENTER
                    AND sa.SUBSCRIPTION_ID = s1.id
                JOIN
                    MASTERPRODUCTREGISTER mpr
                ON
                    mpr.ID = sa.ADDON_PRODUCT_ID
                JOIN
                    PRODUCTS pr2
                ON
                    pr2.GLOBALID = mpr.GLOBALID
                    AND pr2.CENTER = s1.CENTER
                JOIN
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl2
                ON
                    ppgl2.PRODUCT_CENTER = pr2.CENTER
                    AND ppgl2.PRODUCT_ID = pr2.ID
                    AND ppgl2.PRODUCT_GROUP_ID IN(276,
                                                  277)
                WHERE
                    sa.START_DATE <= SYSDATE
                    AND (
                        sa.END_DATE > SYSDATE
                        OR sa.END_DATE IS NULL)
                    AND s1.center IN ($$scope$$))) rec_pt
        ON
            rec_pt.OWNER_CENTER = p.CENTER
            AND rec_pt.OWNER_ID = p.ID -- recurring PT
        LEFT JOIN
            PERSON_EXT_ATTRS home
        ON
            p.center=home.PERSONCENTER
            AND p.id=home.PERSONID
            AND home.name='_eClub_PhoneHome'
            AND home.TXTVALUE IS NOT NULL
        LEFT JOIN
            PERSON_EXT_ATTRS mobile
        ON
            p.center=mobile.PERSONCENTER
            AND p.id=mobile.PERSONID
            AND mobile.name='_eClub_PhoneSMS'
            AND mobile.TXTVALUE IS NOT NULL
        LEFT JOIN
            PERSON_EXT_ATTRS email
        ON
            p.center=email.PERSONCENTER
            AND p.id=email.PERSONID
            AND email.name='_eClub_Email'
            AND email.TXTVALUE IS NOT NULL
        LEFT JOIN
            PERSON_EXT_ATTRS OldID
        ON
            p.center=OldID.PERSONCENTER
            AND p.id=OldID.PERSONID
            AND OldID.name='_eClub_OldSystemPersonId'
            AND OldID.TXTVALUE IS NOT NULL
        LEFT JOIN
            PERSON_EXT_ATTRS salutation
        ON
            p.center=salutation.PERSONCENTER
            AND p.id=salutation.PERSONID
            AND salutation.name='_eClub_Salutation'
            AND salutation.TXTVALUE IS NOT NULL
        LEFT JOIN
            PERSON_EXT_ATTRS Creationdate
        ON
            p.center=Creationdate.PERSONCENTER
            AND p.id=Creationdate.PERSONID
            AND Creationdate.name='CREATION_DATE'
            AND Creationdate.TXTVALUE IS NOT NULL
        JOIN
            CENTERS c
        ON
            c.id = p.CENTER
        LEFT JOIN --Family relation / Friend
            RELATIVES r
        ON
            r.CENTER = p.CENTER
            AND r.id = p.ID
            AND r.RTYPE IN (4,1,3)
            AND r.STATUS =1
        LEFT JOIN --Other Payer
            RELATIVES r2
        ON
            r2.RELATIVECENTER = p.CENTER
            AND r2.RELATIVEID = p.ID
            AND r2.RTYPE IN (2,12)
            AND r2.STATUS = 1
        LEFT JOIN --company relation
            RELATIVES r21
        ON
            r21.RELATIVECENTER = p.CENTER
            AND r21.RELATIVEID = p.ID
            AND r21.RTYPE IN (2)
            AND r21.STATUS = 1
        LEFT JOIN
            COMPANYAGREEMENTS compa
        ON
            compa.CENTER = r.RELATIVECENTER
            AND compa.ID = r.RELATIVEID
            AND compa.SUBID = r.RELATIVESUBID
            AND r.RTYPE = 3
        LEFT JOIN
            PERSONS payer
        ON
            payer.CENTER = r2.CENTER
            AND payer.ID = r2.ID
            AND r2.RTYPE = 12
        LEFT JOIN
            PERSONS comp
        ON
            comp.CENTER = DECODE(r21.CENTER,NULL,compa.center,r21.CENTER)
            AND comp.ID = DECODE(r21.id,NULL,compa.id,r21.id)
        LEFT JOIN --company contact
            RELATIVES r3
        ON
            r3.CENTER = comp.CENTER
            AND r3.ID = comp.ID
            AND r3.RTYPE =7
            AND r3.STATUS = 1
        LEFT JOIN
            PERSONS cont
        ON
            cont.CENTER= r3.RELATIVECENTER
            AND cont.id = r3.RELATIVEID
        LEFT JOIN
            PERSON_EXT_ATTRS cont_mobile
        ON
            cont.center=cont_mobile.PERSONCENTER
            AND cont.id=cont_mobile.PERSONID
            AND cont_mobile.name='_eClub_PhoneSMS'
            AND cont_mobile.TXTVALUE IS NOT NULL
        LEFT JOIN
            PERSON_EXT_ATTRS cont_email
        ON
            cont.center=cont_email.PERSONCENTER
            AND cont.id=cont_email.PERSONID
            AND cont_email.name='_eClub_Email'
            AND cont_email.TXTVALUE IS NOT NULL
        LEFT JOIN
            PERSON_EXT_ATTRS cont_salutation
        ON
            cont.center=cont_salutation.PERSONCENTER
            AND cont.id=cont_salutation.PERSONID
            AND cont_salutation.name='_eClub_Salutation'
            AND cont_salutation.TXTVALUE IS NOT NULL
        LEFT JOIN
            (
                SELECT DISTINCT
                    last_swim.CENTER,
                    last_swim.ID,
                    last_swim.TRANS_TIME,
                    il_swim.TOTAL_AMOUNT / il_swim.QUANTITY AS price
                FROM
                    (
                        SELECT DISTINCT
                            il_swim.PERSON_CENTER AS CENTER,
                            il_swim.PERSON_ID     AS ID,
                            MAX(inv.TRANS_TIME)      TRANS_TIME
                        FROM
                            INVOICELINES il_swim
                        JOIN
                            INVOICES inv
                        ON
                            inv.CENTER=il_swim.CENTER
                            AND inv.ID = il_swim.ID
                        JOIN
                            PRODUCTS pr_swim
                        ON
                            pr_swim.CENTER = il_swim.PRODUCTCENTER
                            AND pr_swim.id = il_swim.PRODUCTID
                        JOIN
                            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl_swim
                        ON
                            ppgl_swim.PRODUCT_CENTER = pr_swim.CENTER
                            AND ppgl_swim.PRODUCT_ID = pr_swim.ID
                            AND ppgl_swim.PRODUCT_GROUP_ID = 1030
                        GROUP BY
                            il_swim.PERSON_CENTER,
                            il_swim.PERSON_ID) last_swim
                JOIN
                    INVOICELINES il_swim
                ON
                    il_swim.PERSON_CENTER = last_swim.CENTER
                    AND il_swim.PERSON_ID = last_swim.id
                JOIN
                    INVOICES inv_swim
                ON
                    inv_swim.CENTER=il_swim.CENTER
                    AND inv_swim.ID = il_swim.ID
                    AND inv_swim.TRANS_TIME = last_swim.TRANS_TIME
                JOIN
                    PRODUCTS pr_swim
                ON
                    pr_swim.CENTER = il_swim.PRODUCTCENTER
                    AND pr_swim.id = il_swim.PRODUCTID
                JOIN
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl_swim
                ON
                    ppgl_swim.PRODUCT_CENTER = pr_swim.CENTER
                    AND ppgl_swim.PRODUCT_ID = pr_swim.ID
                    AND ppgl_swim.PRODUCT_GROUP_ID = 1030) last_swim
        ON
            last_swim.center = p.center
            AND last_swim.id = p.id
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.CENTER
            AND ar.CUSTOMERID = p.ID
            AND ar.AR_TYPE = 4
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar2
        ON
            ar2.CUSTOMERCENTER = p.CENTER
            AND ar2.CUSTOMERID = p.ID
            AND ar2.AR_TYPE = 1
        LEFT JOIN
            PAYMENT_ACCOUNTS pac
        ON
            pac.CENTER = ar.CENTER
            AND pac.id = ar.id
        LEFT JOIN
            PAYMENT_AGREEMENTS pa
        ON
            pa.CENTER = pac.ACTIVE_AGR_CENTER
            AND pa.id = pac.ACTIVE_AGR_ID
            AND pa.SUBID = pac.ACTIVE_AGR_SUBID
        LEFT JOIN
            CASHCOLLECTIONCASES ccc
        ON
            ccc.PERSONCENTER = p.CENTER
            AND ccc.PERSONID = p.id
            AND ccc.CLOSED = 0
            AND ccc.MISSINGPAYMENT = 1
        LEFT JOIN
            CASHCOLLECTIONCASES ccc2
        ON
            ccc2.PERSONCENTER = p.CENTER
            AND ccc2.PERSONID = p.id
            AND ccc2.CLOSED = 0
            AND ccc2.MISSINGPAYMENT = 1
            AND ccc2.STARTDATE < ccc.STARTDATE
        LEFT JOIN
            (
                SELECT DISTINCT
                    cc.OWNER_CENTER,
                    cc.OWNER_ID,
                    cc.CENTER||'cc'||cc.ID||'sub'||    cc.SUBID,
                    pr.NAME                         AS pr_name,
                    il.TOTAL_AMOUNT / il.QUANTITY   AS pr_price,
                    cc.VALID_UNTIL,
                    cc.CLIPS_LEFT
                FROM
                    CLIPCARDS cc
                JOIN
                    INVOICELINES il
                ON
                    cc.INVOICELINE_CENTER = il.CENTER
                    AND cc.INVOICELINE_ID = il.id
                    AND cc.INVOICELINE_SUBID = il.SUBID
                JOIN
                    PRODUCTS pr
                ON
                    pr.CENTER = il.PRODUCTCENTER
                    AND pr.id = il.PRODUCTID
                JOIN
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
                ON
                    ppgl.PRODUCT_CENTER = pr.CENTER
                    AND ppgl.PRODUCT_ID = pr.id
                    AND ppgl.PRODUCT_GROUP_ID = 275
                    AND cc.valid_until > exerpro.dateToLong(TO_CHAR(SYSDATE, 'YYYY-MM-dd HH24:MI'))
                    AND cc.clips_left>0) cc
        ON
            cc.OWNER_CENTER = p.CENTER
            AND cc.OWNER_ID = p.ID
        LEFT JOIN
            (
                SELECT
                    s.center,
                    s.id
                FROM
                    subscriptions s
                JOIN
                    SUBSCRIPTIONTYPES st
                ON
                    s.subscriptiontype_center = st.center
                    AND s.subscriptiontype_id = st.id
                JOIN
                    products pr
                ON
                    st.center = pr.center
                    AND st.id = pr.id
                JOIN --Family relation / Friend 401 681
                    RELATIVES r
                ON
                    r.CENTER = s.owner_center
                    AND r.id = s.owner_ID
                    AND r.RTYPE IN (3)
                    AND r.STATUS =1
                JOIN
                    COMPANYAGREEMENTS ca
                ON
                    ca.CENTER = r.RELATIVECENTER
                    AND ca.ID = r.RELATIVEID
                    AND ca.SUBID = r.RELATIVESUBID
                JOIN
                    PRIVILEGE_GRANTS pg
                ON
                    pg.GRANTER_CENTER = ca.CENTER
                    AND pg.GRANTER_ID = ca.ID
                    AND pg.GRANTER_SUBID = ca.SUBID
                    AND pg.SPONSORSHIP_NAME != 'NONE'
                    AND pg.VALID_FROM < exerpro.dateToLong(TO_CHAR(SYSDATE+1, 'YYYY-MM-dd HH24:MI'))
                    AND (
                        pg.VALID_TO >=exerpro.dateToLong(TO_CHAR(SYSDATE+1, 'YYYY-MM-dd HH24:MI'))
                        OR pg.VALID_TO IS NULL)
 and pg.GRANTER_SERVICE = 'CompanyAgreement'
                JOIN
                    PRODUCT_PRIVILEGES pp
                ON
                    pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
                    AND pp.VALID_FROM < exerpro.dateToLong(TO_CHAR(SYSDATE+1, 'YYYY-MM-dd HH24:MI'))
                    AND (
                        pp.VALID_TO >= exerpro.dateToLong(TO_CHAR(SYSDATE+1, 'YYYY-MM-dd HH24:MI'))
                        OR pp.VALID_TO IS NULL)
                    AND pp.REF_GLOBALID = pr.GLOBALID
                WHERE
                    s.CENTER IN ($$scope$$) ) is_sponsored
        ON
            is_sponsored.center = s.CENTER
            AND is_sponsored.id = s.id
        LEFT JOIN
            (
                SELECT --all PT's booked in current month booked with frequency restricted privileges granted from a subscription
                    par.PARTICIPANT_CENTER         AS center,
                    par.PARTICIPANT_ID             AS id,
                    ps.FREQUENCY_RESTRICTION_COUNT AS limit,
                    COUNT(DISTINCT par.START_TIME) AS num
                FROM
                    MASTERPRODUCTREGISTER mpr
                JOIN
                    PRIVILEGE_GRANTS pg
                ON
                    mpr.id = pg.GRANTER_ID
                JOIN
                    PRIVILEGE_SETS ps
                ON
                    ps.id = pg.PRIVILEGE_SET
                    AND ps.FREQUENCY_RESTRICTION_COUNT IS NOT NULL
                JOIN
                    BOOKING_PRIVILEGES bp
                ON
                    bp.PRIVILEGE_SET = ps.ID
                JOIN
                    PRIVILEGE_USAGES pu
                ON
                    bp.id = pu.PRIVILEGE_ID
                    AND pu.PRIVILEGE_TYPE = 'BOOKING'
                JOIN
                    PARTICIPATIONS par
                ON
                    par.CENTER = pu.TARGET_CENTER
                    AND par.ID = pu.TARGET_ID
                    AND pu.TARGET_SERVICE='Participation'
                JOIN
                    BOOKINGS bo
                ON
                    bo.CENTER = par.BOOKING_CENTER
                    AND bo.id = par.BOOKING_ID
                JOIN
                    ACTIVITY ac
                ON
                    ac.id = bo.ACTIVITY
                    AND ac.ACTIVITY_GROUP_ID IN (206)
                JOIN
                    PRODUCTS pr
                ON
                    pr.CENTER = par.PARTICIPANT_CENTER
                    AND pr.GLOBALID = mpr.GLOBALID
                JOIN
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
                ON
                    ppgl.PRODUCT_CENTER = pr.CENTER
                    AND ppgl.PRODUCT_ID = pr.ID
                    AND ppgl.PRODUCT_GROUP_ID IN (277,276)
                WHERE
                    pu.USE_TIME BETWEEN exerpro.datetolong(TO_CHAR(TRUNC(SYSDATE,'MM'), 'YYYY-MM-DD HH24:MM')) AND exerpro.datetolong(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MM'))
                GROUP BY
                    par.PARTICIPANT_CENTER ,
                    par.PARTICIPANT_ID,
                    ps.FREQUENCY_RESTRICTION_COUNT) rec_pt_packs_counter
        ON
            rec_pt_packs_counter.center = p.CENTER
            AND rec_pt_packs_counter.id = p.id
        WHERE
            p.CENTER IN ($$scope$$)
            --AND p.id = 1026
            AND ccc2.center IS NULL
            /* AND NOT EXISTS
            (
            SELECT
            1
            FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl2
            WHERE
            ppgl2.PRODUCT_CENTER = pr.CENTER
            AND ppgl2.PRODUCT_ID = pr.ID
            AND ppgl2.PRODUCT_GROUP_ID IN(247,
            277 ))*/
    )
GROUP BY
    "Club",
    "Member ID",
    "old system person ID",
    PERSONTYPE,
    "Title",
    FIRSTNAME,
    LASTNAME,
    ADDRESS1,
    ADDRESS2,
    ADDRESS3,
    "Post Code",
    "Email",
    "Mobile",
    "Home Phone",
    "Join Date",
    "Date of Birth",
    "Membership Start Date",
    "Membership End Date",
    "Membership Subscription",
    "Membership Subscription Value",
    "Membership Status",
    "Age of oldest debt (DAYS)",
    "Membership Arrears Balance",
    "Corporate Funded",
    "Recurring PT Pack Product",
    "Recurring PT Value",
    CASE
        WHEN "Recurring PT Pack Product" IS NOT NULL
            AND instr("Recurring PT Pack Product",'4') !=0
        THEN 4 - NVL("sessions used on recurring PT",0)
        WHEN "Recurring PT Pack Product" IS NOT NULL
            AND instr("Recurring PT Pack Product",'8') !=0
        THEN 8 - NVL("sessions used on recurring PT",0)
        WHEN "Recurring PT Pack Product" IS NOT NULL
            AND instr("Recurring PT Pack Product",'12') !=0
        THEN 12 - NVL("sessions used on recurring PT",0)
        WHEN "Recurring PT Pack Product" = 'Deployment PT'
        THEN 0
        WHEN "Recurring PT Pack Product" IS NULL
        THEN NULL
        ELSE -1
    END ,
    "PT Pack Product",
    "PT Pack Value",
    "PT Pack Expiry Date",
    "No of sessions left on PT Pack",
    "Last Swim Purchase Date",
    "Last Swim Purchase Value",
    "Bank Sort Code",
    "Bank Account Code",
    "Payment Agreement Reference",
    "Payment Agreement Status",
    DECODE(IS_PRICE_UPDATE_EXCLUDED,0,'No',1,'Yes')