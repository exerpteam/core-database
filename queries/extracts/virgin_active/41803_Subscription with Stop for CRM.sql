 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             datetolongTZ(TO_CHAR(TRUNC(CURRENT_TIMESTAMP-1), 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')                   AS StartDateLong,
             (datetolongTZ(TO_CHAR(TRUNC(CURRENT_TIMESTAMP-1), 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')+ 86400 * 1000)-1 AS EndDateLong,
             TRUNC(CURRENT_TIMESTAMP-1)                                                                               AS StartDate
         
     )
     ,
     v_sub AS
     (
         SELECT
             sub.*
         FROM
             (
                 SELECT
                     longtodatec(je.creation_time, je.person_center) AS Cancellation_Date,
                     s.center,
                     s.id,
                     s.owner_center,
                     s.owner_id,
                     s.subscriptiontype_center,
                     s.subscriptiontype_id
                 FROM
                     journalentries je
                 CROSS JOIN
                     params
                 JOIN
                     subscriptions s
                 ON
                     s.center = je.ref_center
                     AND s.id = je.ref_id
                 WHERE
                     je.person_center IN ($$Scope$$)
                     AND s.sub_state != 8
                     AND je.jetype = 18
                     AND je.creation_time >= params.StartDateLong
                     AND je.creation_time <= params.EndDateLong
                 UNION
                 SELECT
                     s.end_date AS Cancellation_Date,
                     s.center,
                     s.id,
                     s.owner_center,
                     s.owner_id,
                     s.subscriptiontype_center,
                     s.subscriptiontype_id
                 FROM
                     subscriptions s
                 CROSS JOIN
                     params
                 JOIN
                     subscriptiontypes st
                 ON
                     st.center = s.subscriptiontype_center
                     AND st.id = s.subscriptiontype_id
                     AND st.st_type = 1
                 WHERE
                     s.owner_center IN ($$Scope$$)
                     AND s.sub_state = 6
                     AND s.sub_state != 8
                     AND TRUNC(s.end_date) = params.StartDate
                 UNION
                 SELECT
                     longtodatec(s.creation_time, s.owner_center) AS Cancellation_Date,
                     s.center,
                     s.id,
                     s.owner_center,
                     s.owner_id,
                     s.subscriptiontype_center,
                     s.subscriptiontype_id
                 FROM
                     subscriptions s
                 CROSS JOIN
                     params
                 JOIN
                     subscriptiontypes st
                 ON
                     st.center = s.subscriptiontype_center
                     AND st.id = s.subscriptiontype_id
                     AND st.st_type = 0
                 WHERE
                     s.owner_center IN ($$Scope$$)
                     AND s.sub_state != 8
                     AND s.creation_time >= params.StartDateLong
                     AND s.creation_time <= params.EndDateLong ) sub
         JOIN
             products prod
         ON
             prod.center = sub.subscriptiontype_center
             AND prod.id = sub.subscriptiontype_id
         WHERE
             EXISTS
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
     v_sub_addon AS
     (
         SELECT
             s.*,
             sa.id                        AS addonId,
             mp.CACHED_PRODUCTNAME        AS addonName,
             sa.INDIVIDUAL_PRICE_PER_UNIT AS addonPrice,
             sa.QUANTITY                  AS addonQty
         FROM
             v_sub s
         JOIN
             subscription_addon sa
         ON
             sa.subscription_center = s.center
             AND sa.subscription_id = s.id
                         AND sa.cancelled = 0
             AND sa.start_date < current_timestamp
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
             AND addonpg.name IN ('NCS Add-Ons')
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
             AND br.name = 'Gym Floor'
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
         SELECT
             qaa.center,
             qaa.id,
             qa.number_answer,
             qaa.log_time,
             qc.questionnaire,
             CASE
                 WHEN qa.number_answer IS NOT NULL
                     AND q.id IS NOT NULL
                                 THEN CAST(COALESCE(
                    						  (xpath('//question[id/text()='||qa.QUESTION_ID ||']/options/option[id/text()='||qa.NUMBER_ANSWER ||']/optionText/text()', xmlparse(document convert_from(q.QUESTIONS,'UTF-8'))))[1],
											  (xpath('//question[id/text()='|| 1 ||']/options/option[id/text()='||qa.NUMBER_ANSWER ||']/optionText/text()', xmlparse(document convert_from(q.QUESTIONS,'UTF-8'))))[1]
								              ) AS VARCHAR)
                 ELSE NULL
             END                                                                      AS Reason,
             rank() over (partition BY qaa.center, qaa.id, s.Cancellation_Date ORDER BY qaa.log_time DESC) AS rnk,
                         s.center AS sub_center,
                         s.id AS sub_id
         FROM
             questionnaire_answer qaa
         JOIN
             v_sub s
         ON
             s.owner_center = qaa.center
             AND s.owner_id = qaa.id
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
                         AND longtodatec(qaa.log_time, qaa.center) < s.Cancellation_Date
     )
     ,
     v_camp_code AS
     (
         SELECT DISTINCT
             *
         FROM
             (
                 SELECT
                     s.center,
                     s.id,
                     COALESCE(prg.name, sc.name) AS CampaignName,
                     CASE
                         WHEN s.startup_free_period_id IS NOT NULL
                         THEN sc.name
                         ELSE NULL
                     END AS FreeMonthCampaignName
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
                                         AND pg.GRANTER_SERVICE IN ('StartupCampaign','ReceiverGroup')
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
                                 ) t1
         WHERE
             CampaignName IS NOT NULL
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
     TO_CHAR(longtodatec(s.creation_time, s.owner_center), 'DD.MM.YYYY')                                                                                                                  AS "Sales Date",
     TO_CHAR(s.start_date, 'DD.MM.YYYY')                                                                                                                                                  AS "Start Date",
     TO_CHAR(s.end_date, 'DD.MM.YYYY')                                                                                                                                                    AS "Stop Date",
     TO_CHAR(s.binding_end_date, 'DD.MM.YYYY')                                                                                                                                            AS "Binding Exp",
     quest.Reason                                                                                                                                                                         AS "Cancellation Reasons",
     TO_CHAR(sub.Cancellation_Date, 'DD.MM.YYYY')                                                                                                                                         AS "Cancellation Date",
     c.shortname                                                                                                                                                                          AS "Home Center",
     tsubc.shortname                                                                                                                                                                      AS "Transfer In",
     email.txtvalue                                                                                                                                                                       AS "Email",
     mobile.txtvalue                                                                                                                                                                      AS "Mobile",
     consultPer.fullname                                                                                                                                                                  AS "Membership Consultant",
     att.total                                                                                                                                                                            AS "Total Access",
     TO_CHAR(longtodatec(att.latest, att.person_center), 'DD.MM.YYYY')                                                                                                                    AS "Date of Last Access",
     floor(months_between(CURRENT_TIMESTAMP, p.birthdate) / 12)                                                                                                                                     AS "Eta",
     p.sex                                                                                                                                                                                AS "Sesso",
     TO_CHAR(p.birthdate, 'DD.MM.YYYY')                                                                                                                                                   AS "Birthday",
     p.ssn                                                                                                                                                                                AS "SSN",
     percomment.txtvalue                                                                                                                                                                  AS "VAT Number",
     payment_ar.balance                                                                                                                                                                   AS "Member Account Balance",
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
 LEFT JOIN
     v_sub_addon sub_addon
 ON
     sub_addon.center = s.center
     AND sub_addon.id = s.id
