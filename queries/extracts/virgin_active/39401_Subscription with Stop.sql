 WITH
     v_sub AS
     (
         SELECT
             sub.end_date AS sub_end_date,
             sub.center,
             sub.id,
             sub.owner_center,
             sub.owner_id,
             sub.subscriptiontype_center,
             sub.subscriptiontype_id,
             sub.creation_time,
             st.st_type
         FROM
             subscriptions sub
         JOIN
             subscriptiontypes st
         ON
             st.center = sub.subscriptiontype_center
             AND st.id = sub.subscriptiontype_id
         JOIN
             products prod
         ON
             prod.center = sub.subscriptiontype_center
             AND prod.id = sub.subscriptiontype_id
         WHERE
             sub.owner_center IN ($$Scope$$)
             AND TRUNC(sub.end_date) BETWEEN $$FromDate$$ AND $$ToDate$$
             AND EXISTS
             (
                 SELECT
                     1
                 FROM
                     PRODUCT_AND_PRODUCT_GROUP_LINK prlink,
                     product_group pg
                 WHERE
                     prlink.PRODUCT_CENTER = prod.center
                     AND prlink.product_id = prod.id
                     AND prlink.product_group_id = pg.id
                     AND pg.name IN ('Subscription With Stop Extract') )
     )
     ,
     v_sub_term_je AS
     (
         SELECT
             t.sub_center,
             t.sub_id,
             t.owner_center,
             t.owner_id,
             CASE
                 WHEN t.st_type = 1
                 THEN COALESCE(t.je_creation_time, t.tje_creation_time)
                 ELSE NULL
             END AS creation_time,
             CASE
                 WHEN t.st_type = 1
                 THEN longtodatec(COALESCE(t.je_creation_time, t.tje_creation_time), t.owner_center)
                 WHEN t.st_type = 0
                 THEN longtodatec(t.creation_time, t.owner_center)
             END AS Cancellation_Date
         FROM
             (
                 SELECT
                     sub.center AS sub_center,
                     sub.id     AS sub_id,
                     sub.owner_center,
                     sub.owner_id,
                     sub.st_type,
                     sub.creation_time,
                     je.creation_time                                                                            AS je_creation_time,
                     tje.creation_time                                                                           AS tje_creation_time,
                     rank() over (partition BY je.person_center, je.person_id ORDER BY je.creation_time DESC)    AS rnk,
                     rank() over (partition BY tje.person_center, tje.person_id ORDER BY tje.creation_time DESC) AS trnk
                 FROM
                     v_sub sub
                 LEFT JOIN
                     subscriptions tsub
                 ON
                     tsub.transferred_center = sub.center
                     AND tsub.transferred_id = sub.id
                 LEFT JOIN
                     journalentries je
                 ON
                     sub.center = je.ref_center
                     AND sub.id = je.ref_id
                     AND je.jetype = 18
                 LEFT JOIN
                     journalentries tje
                 ON
                     tsub.center = tje.ref_center
                     AND tsub.id = tje.ref_id
                     AND tje.jetype = 18 ) t
         WHERE
             t.rnk = 1
             AND t.trnk = 1
     )
     ,
     v_sub_down_up AS
     (
         SELECT
             sub.center,
             sub.id,
             longtodatec(newsub.creation_time, newsub.center)                           AS created_date,
             rank() over (partition BY sub.center, sub.id ORDER BY sc.change_time DESC) AS rnk
         FROM
             v_sub sub
         JOIN
             subscription_change sc
         ON
             sc.old_subscription_center = sub.center
             AND sc.old_subscription_id = sub.id
         JOIN
             subscriptions newsub
         ON
             newsub.center = sc.new_subscription_center
             AND newsub.id = sc.new_subscription_id
         WHERE
             sc.type LIKE 'TYPE'
             AND sc.cancel_time IS NULL
     )
     ,
     v_sub_addon AS
     (
         SELECT
             t.*,
             rank() over (partition BY t.center, t.id ORDER BY t.addonId desc) AS rnk
         FROM
             (
                 SELECT
                     s.center,
                     s.id,
                     sa.id                        AS addonId,
                     mp.CACHED_PRODUCTNAME        AS addonName,
                     sa.INDIVIDUAL_PRICE_PER_UNIT AS addonPrice,
                     sa.QUANTITY                  AS addonQty,
                     CASE
                         WHEN addonprod.globalid LIKE 'COLLECTION_%'
                         THEN 1
                         WHEN addonprod.globalid LIKE 'PREMIUM_PLUS_%'
                         THEN 2
                         WHEN addonprod.globalid LIKE 'PREMIUM_%'
                         THEN 3
                         WHEN addonprod.globalid LIKE 'LIFE_%'
                         THEN 4
                         ELSE 5
                     END AS priority
                 FROM
                     v_sub s
                 JOIN
                     subscription_addon sa
                 ON
                     sa.subscription_center = s.center
                     AND sa.subscription_id = s.id
                     AND sa.cancelled = 0
                     AND sa.start_date < CURRENT_TIMESTAMP
                 JOIN
                     MASTERPRODUCTREGISTER mp
                 ON
                     mp.ID = sa.ADDON_PRODUCT_ID
                 JOIN
                     PRODUCTS addonprod
                 ON
                     addonprod.GLOBALID = mp.GLOBALID
                     AND addonprod.CENTER = sa.SUBSCRIPTION_CENTER
                 JOIN
                     PRODUCT_AND_PRODUCT_GROUP_LINK addonpgl
                 ON
                     addonpgl.PRODUCT_CENTER = addonprod.center
                     AND addonpgl.product_id = addonprod.id
                 JOIN
                     PRODUCT_GROUP addonpg
                 ON
                     addonpg.id = addonpgl.product_group_id
                     AND addonpg.name IN ('NCS Add-Ons') ) t
     )
     ,
     v_att AS
     (
         SELECT
             a.person_center,
             a.person_id,
             COUNT(*)          AS total,
             MAX(a.start_time) AS latest
         FROM
             attends a
         JOIN
             v_sub s
         ON
             s.owner_center = a.person_center
             AND s.owner_id = a.person_id
         JOIN
             booking_resources br
         ON
             br.center = a.booking_resource_center
             AND br.id = a.booking_resource_id
             AND br.name NOT IN ('Exec Room',
                                 'Car Park')
         LEFT JOIN
             v_sub_addon sub_addon
         ON
             sub_addon.center = s.center
             AND sub_addon.id = s.id
         JOIN
             PRIVILEGE_USAGES pu
         ON
             pu.TARGET_SERVICE = 'Attend'
             AND pu.TARGET_CENTER = a.center
             AND pu.TARGET_ID = a.id
             AND ( (
                     pu.SOURCE_CENTER = s.center
                     AND pu.SOURCE_ID = s.id)
                 OR pu.SOURCE_ID = sub_addon.addonId)
         WHERE
             a.state = 'ACTIVE'
         GROUP BY
             a.person_center,
             a.person_id
     )
     ,
     v_quest AS
     (
         SELECT DISTINCT
             p.transfers_current_prs_center AS center,
             p.transfers_current_prs_id     AS id,
             qa.number_answer,
             qaa.log_time,
             qc.questionnaire,
             CASE
                 WHEN qa.number_answer IS NOT NULL
                     AND q.id IS NOT NULL
                 THEN 

				 CAST((xpath('//question[id/text()='||CAST(qa.QUESTION_ID AS VARCHAR)||']/options/option[id/text()='||CAST(qa.NUMBER_ANSWER AS VARCHAR)||']/optionText', xmlparse(document convert_from(q.QUESTIONS,'UTF-8'))))[1] AS VARCHAR)

				 ELSE NULL
             END                                                                                                              AS Reason,
             rank() over (partition BY p.transfers_current_prs_center, p.transfers_current_prs_id ORDER BY qaa.log_time DESC) AS rnk,
             s.sub_center                                                                                                     AS sub_center,
             s.sub_id                                                                                                         AS sub_id
         FROM
             questionnaire_answer qaa
         JOIN
             PERSONS p
         ON
             p.center = qaa.center
             AND p.id = qaa.id
         JOIN
             v_sub_term_je s
         ON
             s.owner_center = p.transfers_current_prs_center
             AND s.owner_id = p.transfers_current_prs_id
         JOIN
             questionnaire_campaigns qc
         ON
             qc.id = qaa.questionnaire_campaign_id
         JOIN
             QUESTION_ANSWER qa
         ON
             qa.ANSWER_CENTER =qaa.CENTER
             AND qa.ANSWER_ID=qaa.ID
             AND qa.answer_subid = qaa.subid
         JOIN
             QUESTIONNAIRES q
         ON
             q.id = qc.questionnaire
         WHERE
             qc.name = 'Cancellation Reasons'
             AND qaa.log_time BETWEEN s.creation_time-10000 AND s.creation_time+10000
     )
     ,
     v_camp_code AS
     (
         SELECT DISTINCT
             camp.*,
             rank() over (partition BY center, id ORDER BY entry_time DESC) AS rnk
         FROM
             (
                 SELECT
                     s.center,
                     s.id,
                     COALESCE(prg.name, COALESCE(sc.name, sc1.name)) AS CampaignName,
                     CASE
                         WHEN s.startup_free_period_id IS NOT NULL
                         THEN COALESCE(sc.name, sc1.name)
                         ELSE NULL
                     END AS FreeMonthCampaignName,
                     sp.entry_time
                 FROM
                     v_sub sub
                 JOIN
                     subscriptions s
                 ON
                     s.center = sub.center
                     AND s.id = sub.id
                 LEFT JOIN
                     SUBSCRIPTION_PRICE sp
                 ON
                     s.CENTER = sp.SUBSCRIPTION_CENTER
                     AND s.ID = sp.SUBSCRIPTION_ID
                     AND sp.CANCELLED = 0
                 LEFT JOIN
                     PRIVILEGE_USAGES camppu
                 ON
                     sp.ID = camppu.TARGET_ID
                     AND camppu.TARGET_SERVICE IN ('SubscriptionPrice')
                 LEFT JOIN
                     PRIVILEGE_GRANTS pg
                 ON
                     pg.ID = camppu.GRANT_ID
                     AND pg.GRANTER_SERVICE IN ('StartupCampaign',
                                                'ReceiverGroup')
                 LEFT JOIN
                     PRIVILEGE_RECEIVER_GROUPS prg
                 ON
                     prg.ID = pg.GRANTER_ID
                     AND pg.GRANTER_SERVICE = 'ReceiverGroup'
                 LEFT JOIN
                     STARTUP_CAMPAIGN sc
                 ON
                     sc.id = pg.GRANTER_ID
                     AND pg.GRANTER_SERVICE='StartupCampaign'
                 LEFT JOIN
                     STARTUP_CAMPAIGN sc1
                 ON
                     sc1.id = s.startup_free_period_id) camp
         WHERE
             CampaignName IS NOT NULL
     )
     ,
     v_apply_step AS
     (
         SELECT
             *
         FROM
             (
                 SELECT
                     s.owner_center AS center,
                     s.owner_id     AS id,
                     s.sub_end_date,
                     -- Only convert if the date is valid
                     CASE
                      WHEN CAST(REPLACE(TRIM(SUBSTR(convert_from(je.big_text,'UTF-8'),LENGTH('Subscription credit date: '),3)),'/','') AS INT)  <= 12                       
						THEN TO_DATE(TRIM(substr(convert_from(je.big_text,'UTF-8'),LENGTH('Subscription credit date: '),8)),'MM/DD/YY') 

					 
					 END                                                                                      AS stop_date,
                     rank() over (partition BY je.person_center, je.person_id ORDER BY je.creation_time DESC) AS rnk
                 FROM
                     v_sub s
                 JOIN
                     journalentries je
                 ON
                     je.person_center = s.owner_center
                     AND je.person_id = s.owner_id
                     AND je.jetype = 3
                     AND je.name = 'Apply: Stop subscriptions' ) t1
         WHERE
             TO_CHAR(sub_end_date, 'DD-MM') = TO_CHAR(stop_date, 'DD-MM')
             AND rnk = 1
     )
 SELECT DISTINCT
     p.center || 'p' || p.id                                                                                                                                                              AS "Person Id",
     p.fullname                                                                                                                                                                           AS "Nome e Cognome",
     s.center || 'ss' ||s.id                                                                                                                                                              AS "Subscription ID",
     prod.name                                                                                                                                                                            AS "Nome Subscription",
     s.subscription_price                                                                                                                                                                 AS "Subscription Price",
     sub_addon.addonName                                                                                                                                                                  AS "Addon Name",
     sub_addon.addonPrice*sub_addon.addonQty                                                                                                                                              AS "Addon Price",
     camp.CampaignName                                                                                                                                                                    AS "Campaign Name",
     camp.FreeMonthCampaignName                                                                                                                                                           AS "Free Month Campaign Name",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END      AS "Person Status",
     CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END                                                                                               AS "Subscription Status",
     CASE  s.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'UNKNOWN' END AS "Subscription Sub State",
     CASE  sub.st_type  WHEN 0 THEN  'CASH'  WHEN 1 THEN  'EFT'  END                                                                                                                                           AS "Subscription Type",
     TO_CHAR(longtodatec(s.creation_time, s.owner_center), 'DD.MM.YYYY')                                                                                                                  AS "Sales Date",
     TO_CHAR(s.start_date, 'DD.MM.YYYY')                                                                                                                                                  AS "Start Date",
     TO_CHAR(s.end_date, 'DD.MM.YYYY')                                                                                                                                                    AS "Stop Date",
     TO_CHAR(s.binding_end_date, 'DD.MM.YYYY')                                                                                                                                            AS "Binding Exp",
     CASE
         WHEN sub.st_type = 0
         THEN 'CASH'
         WHEN quest.Reason IS NOT NULL
         THEN quest.Reason
         WHEN apply_step.center IS NOT NULL
         THEN 'STOP IN BULK'
     END                                                                             AS "Cancellation Reasons",
     TO_CHAR(COALESCE(term_je.Cancellation_Date, sub_up_down.created_date), 'DD.MM.YYYY') AS "Cancellation Date",
     c.shortname                                                                     AS "Home Center",
     tsubc.shortname                                                                 AS "Transfer In",
     email.txtvalue                                                                  AS "Email",
     mobile.txtvalue                                                                 AS "Mobile",
     consultPer.fullname                                                             AS "Membership Consultant",
     att.total                                                                       AS "Total Access",
     TO_CHAR(longtodatec(att.latest, att.person_center), 'DD.MM.YYYY')               AS "Date of Last Access",
     floor(months_between(CURRENT_TIMESTAMP, p.birthdate) / 12)                                AS "Eta",
     p.sex                                                                           AS "Sesso",
     TO_CHAR(p.birthdate, 'DD.MM.YYYY')                                              AS "Birthday",
     p.ssn                                                                           AS "SSN",
     percomment.txtvalue                                                             AS "VAT Number",
     payment_ar.balance                                                              AS "Member Account Balance",
     CASE
         WHEN op.center IS NOT NULL
         THEN op.fullname
         ELSE NULL
     END AS "Other Payer Name",
     CASE
         WHEN op.CENTER IS NOT NULL
         THEN op.center || 'p' || op.id
         ELSE ''
     END                   AS "Other Payer Id",
     op_payment_ar.balance AS "Other Payer Account Balance"
 FROM
     v_sub sub
 JOIN
     subscriptions s
 ON
     s.center = sub.center
     AND s.id = sub.id
 JOIN
     PERSONS p
 ON
     p.center = s.owner_center
     AND p.id = s.owner_id
 JOIN
     centers c
 ON
     c.id = p.center
 JOIN
     products prod
 ON
     prod.center = s.subscriptiontype_center
     AND prod.id = s.subscriptiontype_id
 LEFT JOIN
     ACCOUNT_RECEIVABLES payment_ar
 ON
     payment_ar.CUSTOMERCENTER = p.center
     AND payment_ar.CUSTOMERID = p.id
     AND payment_ar.AR_TYPE = 4
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     p.center=email.PERSONCENTER
     AND p.id=email.PERSONID
     AND email.name='_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS mobile
 ON
     p.center=mobile.PERSONCENTER
     AND p.id=mobile.PERSONID
     AND mobile.name='_eClub_PhoneSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS percomment
 ON
     p.center=percomment.PERSONCENTER
     AND p.id=percomment.PERSONID
     AND percomment.name='_eClub_Comment'
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
     ACCOUNT_RECEIVABLES op_payment_ar
 ON
     op_payment_ar.CUSTOMERCENTER = op.center
     AND op_payment_ar.CUSTOMERID = op.id
     AND op_payment_ar.AR_TYPE = 4
 LEFT JOIN
     PERSON_EXT_ATTRS memconsult
 ON
     p.center=memconsult.PERSONCENTER
     AND p.id=memconsult.PERSONID
     AND memconsult.name='MC_IT'
 LEFT JOIN
     PERSONS consultPer
 ON
     consultPer.center||'p'||consultPer.id = memconsult.txtvalue
 LEFT JOIN
     v_att att
 ON
     att.person_center = p.center
     AND att.person_id = p.id
 LEFT JOIN
     v_quest quest
 ON
     quest.center = p.center
     AND quest.id = p.id
     AND quest.sub_center = s.center
     AND quest.sub_id = s.id
     AND quest.rnk = 1
 LEFT JOIN
     subscriptions transsub
 ON
     transsub.center = s.transferred_center
     AND transsub.id = s.transferred_id
 LEFT JOIN
     centers tsubc
 ON
     tsubc.id = transsub.center
 LEFT JOIN
     v_camp_code camp
 ON
     camp.center = s.center
     AND camp.id = s.id
     AND camp.rnk = 1
 LEFT JOIN
     v_sub_addon sub_addon
 ON
     sub_addon.center = s.center
     AND sub_addon.id = s.id
     AND sub_addon.rnk = 1
 LEFT JOIN
     v_apply_step apply_step
 ON
     apply_step.center = p.center
     AND apply_step.id = p.id
 LEFT JOIN
     v_sub_term_je term_je
 ON
     term_je.owner_center = p.center
     AND term_je.owner_id = p.id
     AND term_je.sub_center = s.center
     AND term_je.sub_id = s.id
 LEFT JOIN
     v_sub_down_up sub_up_down
 ON
     sub_up_down.center = s.center
     AND sub_up_down.id = s.id
     AND sub_up_down.rnk = 1
