 WITH
     PARAMS AS
     (
         SELECT 
             datetolongTZ(TO_CHAR(TRUNC(currentdate , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London' )  AS STARTTIME ,
             datetolongTZ(TO_CHAR(TRUNC(currentdate +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS ENDTIME,
             datetolongTZ(TO_CHAR(TRUNC(currentdate +2, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS HARDCLOSETIME
         FROM
             (
                 SELECT
                     $$thedate$$ AS currentdate
                  ) t
     ),
     V_EXCLUDED_SUBSCRIPTIONS AS
    (
        SELECT
            ppgl.PRODUCT_CENTER as center,
            ppgl.PRODUCT_ID as id
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = True
    )
 SELECT
     xx.NAME,
     xx.FULLNAME,
     xx.FIRSTNAME,
     xx.LASTNAME,
     xx.MemberID,
     xx.ADDRESS1,
     xx.ADDRESS2,
     xx.ADDRESS3,
     xx.ZIPCODE,
     xx.PIN,
     xx.Email,
     xx.PHONEHOME,
     xx.MOBILE,
     xx.MemberSinceDate,
     TO_CHAR(longtodatetz(MAX(xx.MemberSinceTime),'Europe/London'),'HH24:MI') AS MemberSinceTime,
     last_chkin.CHECKIN_TIME,
     CASE Yes_PT.NUMBER_ANSWER WHEN 1 THEN 'yes' WHEN 2 THEN 'no' ELSE NULL END AS "PT" ,
     newsletter.TXTVALUE                              AS "Newsletter",
     offers.TXTVALUE                                  AS "3rd party offers",
     xx.staff                                         AS Sale_Staff
 FROM
     (
         -- Outoing balance members
         SELECT DISTINCT
             cen.NAME,
             p.center,
             p.id,
             p.FULLNAME,
             p.FIRSTNAME,
             p.LASTNAME,
             p.center||'p'||p.id AS MemberID,
             p.ADDRESS1,
             p.ADDRESS2,
             p.ADDRESS3,
             p.ZIPCODE,
             e.IDENTITY                                                         AS PIN,
             email.TXTVALUE                                                     AS Email,
             home.TXTVALUE                                                      AS PHONEHOME,
             mobile.TXTVALUE                                                    AS MOBILE,
             COALESCE(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea.txtvalue) AS MemberSinceDate,
             su.CREATION_TIME                                                   AS MemberSinceTime,
             staff.FULLNAME                                                     AS staff
         FROM
             PARAMS,
             SUBSCRIPTIONTYPES ST
         JOIN
             SUBSCRIPTIONS SU
         ON
             SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
             AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
         JOIN
             PERSONS p
         ON
             su.OWNER_CENTER = p.center
             AND su.OWNER_ID = p.id
         LEFT JOIN
             PERSON_EXT_ATTRS email
         ON
             p.center=email.PERSONCENTER
             AND p.id=email.PERSONID
             AND email.name='_eClub_Email'
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
             PERSON_EXT_ATTRS pea
         ON
             p.center=pea.PERSONCENTER
             AND p.id=pea.PERSONID
             AND pea.name='CREATION_DATE'
         LEFT JOIN
             ENTITYIDENTIFIERS e
         ON
             e.IDMETHOD = 5
             AND e.ENTITYSTATUS = 1
             AND e.REF_CENTER=p.CENTER
             AND e.REF_ID = p.ID
             AND e.REF_TYPE = 1
         LEFT JOIN
             CENTERS cen
         ON
             cen.ID = p.CENTER
         LEFT JOIN
             EMPLOYEES emp
         ON
             emp.center = su.CREATOR_CENTER
             AND emp.id = su.CREATOR_ID
         LEFT JOIN
             PERSONS staff
         ON
             staff.center = emp.PERSONCENTER
             AND staff.id = emp.PERSONID
         WHERE
              (ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS)
             AND SU.CENTER IN( $$center$$)
             AND EXISTS
             (
                 -- In outgoing balance
                 SELECT
                     1
                 FROM
                     STATE_CHANGE_LOG SCL
                 WHERE
                     SCL.CENTER = SU.CENTER
                     AND SCL.ID = SU.ID
                     AND SCL.ENTRY_TYPE = 2
                     AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                     AND (
                         SCL.BOOK_END_TIME IS NULL
                         OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                         OR SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
                     AND SCL.ENTRY_TYPE = 2
                     AND SCL.STATEID IN ( 2,
                                         4,8)
                     -- Time safety. We need to exclude subscriptions started in the past so they do
                     -- not
                     -- get
                     -- into the incoming balance because they will not be in the outgoing balance
                     -- of
                     -- the
                     -- previous day
                     AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME )
         EXCEPT
         -- That are not in incoming balance
         SELECT DISTINCT
             cen.NAME,
             p.center,
             p.id,
             p.FULLNAME,
             p.FIRSTNAME,
             p.LASTNAME,
             p.center||'p'||p.id,
             p.ADDRESS1,
             p.ADDRESS2,
             p.ADDRESS3,
             p.ZIPCODE,
             e.IDENTITY                                                         AS PIN,
             email.TXTVALUE                                                     AS Email,
             home.TXTVALUE                                                      AS PHONEHOME,
             mobile.TXTVALUE                                                    AS MOBILE,
             COALESCE(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea.txtvalue) AS MemberSinceDate,
             su.CREATION_TIME                                                   AS MemberSinceTime,
             staff.FULLNAME                                                     AS staff
         FROM
             PARAMS,
             SUBSCRIPTIONTYPES ST
         JOIN
             SUBSCRIPTIONS SU
         ON
             SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
             AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
         JOIN
             PERSONS p
         ON
             su.OWNER_CENTER = p.center
             AND su.OWNER_ID = p.id
         LEFT JOIN
             PERSON_EXT_ATTRS email
         ON
             p.center=email.PERSONCENTER
             AND p.id=email.PERSONID
             AND email.name='_eClub_Email'
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
             PERSON_EXT_ATTRS pea
         ON
             p.center=pea.PERSONCENTER
             AND p.id=pea.PERSONID
             AND pea.name='CREATION_DATE'
         LEFT JOIN
             ENTITYIDENTIFIERS e
         ON
             e.IDMETHOD = 5
             AND e.ENTITYSTATUS = 1
             AND e.REF_CENTER=p.CENTER
             AND e.REF_ID = p.ID
             AND e.REF_TYPE = 1
         LEFT JOIN
             CENTERS cen
         ON
             cen.ID = p.CENTER
         LEFT JOIN
             EMPLOYEES emp
         ON
             emp.center = su.CREATOR_CENTER
             AND emp.id = su.CREATOR_ID
         LEFT JOIN
             PERSONS staff
         ON
             staff.center = emp.PERSONCENTER
             AND staff.id = emp.PERSONID
         WHERE
              (ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS)
             AND SU.CENTER IN($$center$$)
             AND EXISTS
             (
                 -- In outgoing balance
                 SELECT
                     1
                 FROM
                     STATE_CHANGE_LOG SCL
                 WHERE
                     SCL.CENTER = SU.CENTER
                     AND SCL.ID = SU.ID
                     AND SCL.ENTRY_TYPE = 2
                     AND SCL.BOOK_START_TIME < PARAMS.STARTTIME
                     AND (
                         SCL.BOOK_END_TIME IS NULL
                         OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                         OR SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
                     AND SCL.ENTRY_TYPE = 2
                     AND SCL.STATEID IN ( 2,
                                         4,8)
                     -- Time safety. We need to exclude subscriptions started in the past so they do
                     -- not
                     -- get
                     -- into the incoming balance because they will not be in the outgoing balance
                     -- of
                     -- the
                     -- previous day
                     AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME ) ) xx
 LEFT JOIN
     (
         SELECT
             ch.person_center,
             ch.person_ID,
             TO_CHAR(longtodateTZ(MAX(ch.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS CHECKIN_TIME
         FROM
             CHECKINS ch
         GROUP BY
             ch.person_center,
             ch.person_ID) last_chkin
 ON
     last_chkin.person_center =xx.center
     AND last_chkin.person_ID = xx.id
 LEFT JOIN
     (
         SELECT
             p.center,
             p.id,
             qa.NUMBER_ANSWER
         FROM
             QUESTION_ANSWER QA
         JOIN
             QUESTIONNAIRE_ANSWER QUN
         ON
             QA.ANSWER_CENTER = QUN.CENTER
             AND QA.ANSWER_ID = QUN.ID
             AND QA.ANSWER_SUBID = QUN.SUBID
         JOIN
             QUESTIONNAIRE_CAMPAIGNS QC
         ON
             QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
         JOIN
             QUESTIONNAIRES Q
         ON
             q.ID = QC.QUESTIONNAIRE
         JOIN
             PERSONS p
         ON
             QUN.CENTER = P.CENTER
             AND QUN.ID = P.ID
         JOIN
             (
                 SELECT
                     p.center,
                     p.id,
                     MAX(qun.LOG_TIME) LOG_TIME
                 FROM
                     QUESTIONNAIRE_ANSWER QUN
                 JOIN
                     QUESTIONNAIRE_CAMPAIGNS QC
                 ON
                     QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
                 JOIN
                     QUESTIONNAIRES Q
                 ON
                     q.ID = QC.QUESTIONNAIRE
                 JOIN
                     PERSONS p
                 ON
                     QUN.CENTER = P.CENTER
                     AND QUN.ID = P.ID
                 WHERE
                     Q.NAME = 'Marketing Questionnaire'
                     AND qun.COMPLETED = 1
                 GROUP BY
                     p.center,
                     p.id ) max_q
         ON
             max_q.LOG_TIME = qun.LOG_TIME
             AND p.center = max_q.center
             AND p.id = max_q.id
         WHERE
             Q.NAME = 'Marketing Questionnaire'
             AND p.sex !='C'
             AND qa.QUESTION_ID = 3
             AND qun.COMPLETED = 1) Yes_PT
 ON
     Yes_PT.center = xx.center
     AND Yes_PT.id = xx.id
 LEFT JOIN
     PERSON_EXT_ATTRS newsletter
 ON
     xx.center=newsletter.PERSONCENTER
     AND xx.id=newsletter.PERSONID
     AND newsletter.name='eClubIsAcceptingEmailNewsLetters'
 LEFT JOIN
     PERSON_EXT_ATTRS offers
 ON
     xx.center=offers.PERSONCENTER
     AND xx.id=offers.PERSONID
     AND offers.name='eClubIsAcceptingThirdPartyOffers'
 GROUP BY
     xx.NAME,
     xx.FULLNAME,
     xx.FIRSTNAME,
     xx.LASTNAME,
     xx.MemberID,
     xx.ADDRESS1,
     xx.ADDRESS2,
     xx.ADDRESS3,
     xx.ZIPCODE,
     xx.PIN,
     xx.Email,
     xx.PHONEHOME,
     xx.MOBILE,
     xx.MemberSinceDate,
     last_chkin.CHECKIN_TIME,
     CASE Yes_PT.NUMBER_ANSWER WHEN 1 THEN 'yes' WHEN 2 THEN 'no' ELSE NULL END,
     newsletter.TXTVALUE,
     offers.TXTVALUE,
     xx.staff
