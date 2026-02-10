-- The extract is extracted from Exerp on 2026-02-08
-- Copy of Full Member Extract with the following differences:
Additional filters (Added by Exerp in ST-842).
Subscription binding end date added (not by Exerp).
https://clublead.atlassian.net/browse/ST-3732
 SELECT DISTINCT
     "Club",
     "Member ID",
     "old system person ID",
     PERSONTYPE,
     MAX("Family Link")   AS "Family Link",
     MAX("My payer ID")   AS "My payer ID",
     MAX("My payer Name") AS "My payer Name",
     "Title",
         FIRSTNAME,
     LASTNAME,
     "Post Code",
     "Join Date",
     "Date of Birth",
     "Membership Start Date",
     "Membership End Date",
     "Membership Binding Date",
     "Membership Subscription",
     "Membership Subscription Value",
     "Membership Status",
     "Age of oldest debt (DAYS)",
     "Membership Arrears Balance",
     CASE MAX("Upfront") WHEN 1 THEN 'y' WHEN 0 THEN 'n' END AS "Upfront",
     CASE MAX("Pru") WHEN 1 THEN 'y' WHEN 0 THEN 'n' END     AS "Pru",
     CASE MAX("staff") WHEN 1 THEN 'y' WHEN 0 THEN 'n' END   AS "staff",
     CASE MAX("Buddy") WHEN 1 THEN 'y' WHEN 0 THEN 'n' END   AS "Buddy",
     MAX("Buddy of")                    AS "Buddy of",
     "Corporate Funded",
 MAX ("Company ID") AS "Company ID",
     MAX("Company Name")                         AS "Company Name",
 "Employee Number",
     MAX("Company Contact's Title")              AS "Company Contact's Title",
     MAX("Comp Contact's Firstname")             AS "Comp Contact's Firstname",
     MAX("Comp Contact's Last Name")             AS "Comp Contact's Last Name",
     MAX("Comp Contact's Address Line 1")        AS "Comp Contact's Address Line 1" ,
     MAX("Comp Contact's Address Line 2")        AS "Comp Contact's Address Line 2" ,
     MAX("Comp Contact's Address Line 3")        AS "Comp Contact's Address Line 3" ,
 MAX ("Comp Contact's City") AS "Comp Contact's City",
     MAX("Comp Contact's Post Code")             AS "Comp Contact's Post Code" ,
     MAX("Comp Contact's E-mail")                AS "Comp Contact's E-mail" ,
     MAX("Comp Contact's Mobile")                AS "Comp Contact's Mobile" ,
     CASE MAX("Has Recurring PT") WHEN 1 THEN 'y' WHEN 0 THEN 'n' END AS "Has Recurring PT",
     "Recurring PT Pack Product",
     "Recurring PT Value",
     CASE
         WHEN "Recurring PT Pack Product" IS NOT NULL
             AND strpos("Recurring PT Pack Product",'4') !=0
         THEN 4 - COALESCE("sessions used on recurring PT",0)
         WHEN "Recurring PT Pack Product" IS NOT NULL
             AND strpos("Recurring PT Pack Product",'8') !=0
         THEN 8 - COALESCE("sessions used on recurring PT",0)
         WHEN "Recurring PT Pack Product" IS NOT NULL
             AND strpos("Recurring PT Pack Product",'12') !=0
         THEN 12 - COALESCE("sessions used on recurring PT",0)
         WHEN "Recurring PT Pack Product" = 'Deployment PT'
         THEN 0
         WHEN "Recurring PT Pack Product" IS NULL
         THEN NULL
         ELSE -1
     END                                            AS "sessions left on recurring PT",
     CASE MAX("Has Current PT Pack") WHEN 1 THEN 'y' WHEN 0 THEN 'n' END AS "Has Current PT Pack",
     "PT Pack Product",
     "PT Pack Value",
     "PT Pack Expiry Date",
     "No of sessions left on PT Pack",
     "Last Swim Purchase Date",
     "Last Swim Purchase Value",
    -- "Bank Sort Code",
    -- "Bank Account Code",
     "Payment Agreement Reference",
     "Payment Agreement Status",
     MAX(CASE "Company agreement id" WHEN 'prpt' THEN NULL ELSE "Company agreement id" END) AS "Company agreement id",
     MAX("Company agreement name")                                          AS "Company agreement name",
     CASE IS_PRICE_UPDATE_EXCLUDED WHEN 0 THEN 'No' WHEN 1 THEN 'Yes' END                        AS "Manually Excluded"
 FROM
     (
         SELECT
             c.NAME                                                                                                                                                  AS "Club",
             p.center||'p'||p.id                                                                                                                                     AS "Member ID",
             OldID.TXTVALUE                                                                                                                                          AS "old system person ID",
             CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE,
             CASE r.RTYPE WHEN 4 THEN CASE r.RELATIVECENTER||'p'||r.RELATIVEID WHEN 'p' THEN NULL ELSE r.RELATIVECENTER||'p'||r.RELATIVEID END ELSE NULL END                                         AS "Family Link",
             CASE r2.RTYPE WHEN 12 THEN r2.center||'p'||r2.id ELSE NULL END                                                                                                          AS "My payer ID",
             CASE r2.RTYPE WHEN 12 THEN payer.FULLNAME ELSE NULL END                                                                                                                 AS "My payer Name",
             salutation.TXTVALUE                                                                                                                                     AS "Title",
 EmployeeNumber.TXTVALUE                                                                                                                                 AS "Employee Number",
             p.FIRSTNAME,
             p.LASTNAME,
             p.ADDRESS1,
             p.ADDRESS2,
             p.ADDRESS3,
             p.ZIPCODE                                                                                                       AS "Post Code",
             Creationdate.TXTVALUE                                                                                           AS "Join Date",
             TO_CHAR(p.BIRTHDATE,'yyyy-MM-dd')                                                                               AS "Date of Birth",
             TO_CHAR(s.START_DATE,'yyyy-MM-dd')                                                                              AS "Membership Start Date",
             TO_CHAR(s.END_DATE,'yyyy-MM-dd')                                                                                AS "Membership End Date",
  TO_CHAR(s.BINDING_END_DATE,'yyyy-MM-dd')                                                                                AS "Membership Binding Date",
             pr.NAME                                                                                                         AS "Membership Subscription",
             s.SUBSCRIPTION_PRICE                                                                                            AS "Membership Subscription Value",
             CASE s.STATE WHEN 2 THEN  'ACTIVE'  WHEN 4  THEN  'FROZEN' END                                                                       AS "Membership Status",
             TRUNC(CURRENT_TIMESTAMP+1) - ccc.STARTDATE                                                                                AS "Age of oldest debt (DAYS)",
             COALESCE(ar.BALANCE + ar2.BALANCE,0)                                                                                 AS "Membership Arrears Balance",
             CASE st.ST_TYPE WHEN 0 THEN 1 ELSE 0 END                                                                                        AS "Upfront",
             CASE  WHEN ppgl.PRODUCT_GROUP_ID IS NULL THEN 0 ELSE 1 END                                                                          AS "Pru",
             CASE pr.GLOBALID WHEN '21' THEN 1 WHEN '25' THEN 1 ELSE 0 END                                                                             AS "staff",
             CASE pr.GLOBALID WHEN '22' THEN 1 WHEN '26' THEN 1 ELSE 0 END                                                                             AS "Buddy",
             CASE r.RTYPE WHEN 1 THEN CASE r.RELATIVECENTER||'p'||r.RELATIVEID WHEN 'p' THEN NULL ELSE r.RELATIVECENTER||'p'||r.RELATIVEID END ELSE NULL END AS "Buddy of",
             CASE  WHEN is_sponsored.center IS NULL THEN 'n' ELSE 'y' END                                                                        AS "Corporate Funded",
 comp.center||'p'||comp.id AS "Company ID",
             comp.FULLNAME                                                                                                   AS "Company Name",
             cont_salutation.TXTVALUE                                                                                        AS "Company Contact's Title",
             cont.FIRSTNAME                                                                                                  AS "Comp Contact's Firstname",
             cont.LASTNAME                                                                                                   AS "Comp Contact's Last Name",
             comp.ADDRESS1                                                                                                   AS "Comp Contact's Address Line 1",
             comp.ADDRESS2                                                                                                   AS "Comp Contact's Address Line 2",
             comp.ADDRESS3                                                                                                   AS "Comp Contact's Address Line 3",
             comp.CITY                                                                                                    AS "Comp Contact's City",
             comp.ZIPCODE                                                                                                    AS "Comp Contact's Post Code",
             cont_email.TXTVALUE                                                                                             AS "Comp Contact's E-mail",
             cont_mobile.TXTVALUE                                                                                            AS "Comp Contact's Mobile",
             CASE  WHEN rec_pt.name IS NULL THEN 0 ELSE 1 END                                                                                    AS "Has Recurring PT",
             rec_pt.name                                                                                                     AS "Recurring PT Pack Product",
             rec_pt.price                                                                                                    AS "Recurring PT Value",
             rec_pt_packs_counter.num                                                                                        AS "sessions used on recurring PT",
             CASE
                 WHEN cc.valid_until > dateToLong(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-dd HH24:MI'))
                     AND cc.clips_left>0
                 THEN 1
                 ELSE 0
             END                                                                                                                                                                                                        AS "Has Current PT Pack",
             cc.pr_name                                                                                                                                                                                                        AS "PT Pack Product",
             cc.pr_price                                                                                                                                                                                                        AS "PT Pack Value",
             longtodate(cc.valid_until)                                                                                                                                                                                                        AS "PT Pack Expiry Date",
             cc.clips_left                                                                                                                                                                                                        AS "No of sessions left on PT Pack",
             longtodate(last_swim.TRANS_TIME)                                                                                                                                                                                                        AS "Last Swim Purchase Date",
             last_swim.price                                                                                                                                                                                                        AS "Last Swim Purchase Value",
             pa.BANK_ACCNO                                                                                                                                                                                                        AS "Bank Account Code",
             pa.BANK_REGNO                                                                                                                                                                                                        AS "Bank Sort Code",
             pa.REF                                                                                                                                                                                                        AS "Payment Agreement Reference",
             CASE pa.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' END AS "Payment Agreement Status",
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
                     AND s.START_DATE <= CURRENT_TIMESTAMP
                     AND (
                         s.END_DATE > CURRENT_TIMESTAMP
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
                     sa.START_DATE <= CURRENT_TIMESTAMP
                     AND (
                         sa.END_DATE > CURRENT_TIMESTAMP
                         OR sa.END_DATE IS NULL)
                     AND s1.center IN ($$scope$$))) rec_pt
         ON
             rec_pt.OWNER_CENTER = p.CENTER
             AND rec_pt.OWNER_ID = p.ID -- recurring PT
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
                 LEFT JOIN
             PERSON_EXT_ATTRS EmployeeNumber
         ON
             p.center=EmployeeNumber.PERSONCENTER
             AND p.id=EmployeeNumber.PERSONID
             AND EmployeeNumber.name='COMPANY_AGREEMENT_EMPLOYEE_NUMBER'
             AND EmployeeNumber.TXTVALUE IS NOT NULL
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
             comp.CENTER = CASE  WHEN r21.CENTER IS NULL THEN compa.center ELSE r21.CENTER END
             AND comp.ID = CASE  WHEN r21.id IS NULL THEN compa.id ELSE r21.id END
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
                     AND cc.valid_until > dateToLong(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-dd HH24:MI'))
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
                     AND pg.VALID_FROM < dateToLong(TO_CHAR(CURRENT_TIMESTAMP+1, 'YYYY-MM-dd HH24:MI'))
                     AND (
                         pg.VALID_TO >=dateToLong(TO_CHAR(CURRENT_TIMESTAMP+1, 'YYYY-MM-dd HH24:MI'))
                         OR pg.VALID_TO IS NULL)
  and pg.GRANTER_SERVICE = 'CompanyAgreement'
                 JOIN
                     PRODUCT_PRIVILEGES pp
                 ON
                     pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
                     AND pp.VALID_FROM < dateToLong(TO_CHAR(CURRENT_TIMESTAMP+1, 'YYYY-MM-dd HH24:MI'))
                     AND (
                         pp.VALID_TO >= dateToLong(TO_CHAR(CURRENT_TIMESTAMP+1, 'YYYY-MM-dd HH24:MI'))
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
                     pu.USE_TIME BETWEEN datetolong(TO_CHAR(TRUNC(CURRENT_TIMESTAMP,'MM'), 'YYYY-MM-DD HH24:MM')) AND datetolong(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MM'))
                 GROUP BY
                     par.PARTICIPANT_CENTER ,
                     par.PARTICIPANT_ID,
                     ps.FREQUENCY_RESTRICTION_COUNT) rec_pt_packs_counter
         ON
             rec_pt_packs_counter.center = p.CENTER
             AND rec_pt_packs_counter.id = p.id
         WHERE
             p.CENTER IN ($$scope$$)
             AND (( -1 in ($$PersonType$$)) or (p.persontype in ($$PersonType$$)))
             AND (( 'ALL' in ($$CompanyName$$)) or (comp.FULLNAME in ($$CompanyName$$)))
             AND ccc2.center IS NULL
     ) t1
 GROUP BY
     "Club",
     "Member ID",
     "old system person ID",
     PERSONTYPE,
     "Title",
         "Employee Number",
     FIRSTNAME,
     LASTNAME,
     ADDRESS1,
     ADDRESS2,
     ADDRESS3,
     "Post Code",
     "Join Date",
     "Date of Birth",
     "Membership Start Date",
     "Membership End Date",
     "Membership Binding Date",
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
             AND strpos("Recurring PT Pack Product",'4') !=0
         THEN 4 - COALESCE("sessions used on recurring PT",0)
         WHEN "Recurring PT Pack Product" IS NOT NULL
             AND strpos("Recurring PT Pack Product",'8') !=0
         THEN 8 - COALESCE("sessions used on recurring PT",0)
         WHEN "Recurring PT Pack Product" IS NOT NULL
             AND strpos("Recurring PT Pack Product",'12') !=0
         THEN 12 - COALESCE("sessions used on recurring PT",0)
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
     CASE IS_PRICE_UPDATE_EXCLUDED WHEN 0 THEN 'No' WHEN 1 THEN 'Yes' END
