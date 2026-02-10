-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4731
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$FromDate$$                                                                                 AS StartDate,
             $$ToDate$$                                                                                 AS EndDate,
             datetolongTZ(TO_CHAR($$FromDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/London')                   AS StartDateLong,
             (datetolongTZ(TO_CHAR($$ToDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/London')+ 86400 * 1000)-1 AS EndDateLong
         
     )
 SELECT
     t.PersonId  AS "Person Id",
     t.Status    AS "Person Status",
     t.SubName   AS "Subscription Name",
     t.SubId     AS "Subscription Id",
     t.SubCenter AS "Subscription home Center",
     COUNT(*)    AS "No of Attends to Corso Como",
     t.Email     AS "Email Address",
     t.Mobile    AS "Mobile Number"
 FROM
     (
         SELECT DISTINCT
             p.center || 'p' || p.id                                                                                                                                                         AS PersonId,
             CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS Status,
             pd.name                                                                                                                                                                         AS SubName,
             s.center || 'ss' || s.id                                                                                                                                                        AS SubId,
             center.NAME                                                                                                                                                                     AS SubCenter,
             email.txtvalue                                                                                                                                                                  AS Email,
             mobile.txtvalue                                                                                                                                                                 AS Mobile,
             att.start_time                                                                                                                                                                  AS StartTime
         FROM
             persons p
         CROSS JOIN
             params
         JOIN
             subscriptions s
         ON
             s.owner_center = p.center
             AND s.owner_id = p.id
         JOIN
             CENTERS center
         ON
             center.id = s.center
         JOIN
             products pd
         ON
             pd.center = s.subscriptiontype_center
             AND pd.id = s.subscriptiontype_id
         JOIN
             MASTERPRODUCTREGISTER mpr
         ON
             mpr.globalid = pd.GLOBALID
         JOIN
             PRIVILEGE_GRANTS pg
         ON
             pg.granter_id = mpr.ID
             AND pg.GRANTER_SERVICE = 'GlobalSubscription'
         JOIN
             PRIVILEGE_SETS ps
         ON
             ps.ID = pg.PRIVILEGE_SET
             AND ps.name = 'Premium Plus'
         JOIN
             attends att
         ON
             att.person_center = p.center
             AND att.person_id = p.id
             AND att.center = 209
             /* Attend to Milano Corso Como club */
         JOIN
             STATE_CHANGE_LOG SCL
         ON
             (
                 SCL.CENTER = s.CENTER
                 AND SCL.ID = s.ID
                 AND SCL.ENTRY_TYPE = 2
                 AND SCL.STATEID IN (2,4, 8)
                 AND SCL.ENTRY_START_TIME <= att.start_time
                 AND (
                     SCL.ENTRY_END_TIME IS NULL
                     OR SCL.ENTRY_END_TIME > att.start_time )
                         )
         LEFT JOIN
             PERSON_EXT_ATTRS mobile
         ON
             p.center=mobile.PERSONCENTER
             AND p.id=mobile.PERSONID
             AND mobile.name='_eClub_PhoneSMS'
         LEFT JOIN
             PERSON_EXT_ATTRS email
         ON
             p.center=email.PERSONCENTER
             AND p.id=email.PERSONID
             AND email.name='_eClub_Email'
         WHERE
             p.center IN ($$Scope$$)
             AND att.start_time BETWEEN params.StartDateLong AND params.EndDateLong ) t
 GROUP BY
     t.PersonId,
     t.Status,
     t.SubName,
     t.SubId,
     t.SubCenter,
     t.Email,
     t.Mobile
