 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$From_Date$$                     AS FromDate,
             ($$To_Date$$ + 86400 * 1000) - 1 AS ToDate,
             CAST(extract(epoch from interval '8 days') * 1000 AS BIGINT)                 AS EightDays
         
     )
 SELECT
     personCenterName   AS "Home Club Name",
     chekinCenterName   AS "Checkin Club Name",
     SUM(total_checkin) AS total_checkin
 FROM
     (
         SELECT
             p.center,
             p.id,
             p.fullname,
             per_checkin.total_checkin,
             per_checkin.checkin_center AS checkinCenter,
             perCenter.shortname        AS personCenterName,
             checkinCenter.shortname    AS chekinCenterName
         FROM
             persons p
         JOIN
             (
                 SELECT
                     person_center,
                     person_id,
                     checkin_center,
                     COUNT(*) AS total_checkin
                 FROM
                     (
                         SELECT DISTINCT
                             ch.person_center,
                             ch.person_id,
                             ch.checkin_center,
                             ch.checkin_time
                         FROM
                             checkins ch
                         CROSS JOIN
                             params
                         WHERE
                             ch.checkin_result IN (0,1,2)
                             AND ch.checkin_time >= params.FromDate
                             AND ch.checkin_time <= params.ToDate
                             /* If attend to class required then time difference between participantion and checkin must be less than 1 hour*/
                             AND (
                                 $$att_req$$ = 0
                                 OR EXISTS
                                 (
                                     SELECT
                                         1
                                     FROM
                                         participations part
                                     WHERE
                                         part.participant_center = ch.person_center
                                         AND part.participant_id = ch.person_id
                                         AND part.start_time >= params.FromDate
                                         AND part.start_time <= params.ToDate
                                         AND part.state = 'PARTICIPATION'
                                         AND ((
                                                 TRUNC(longtodate(part.start_time), 'MI') - TRUNC(longtodate(ch.checkin_time), 'MI'))*24*60) BETWEEN 0 AND 60) )
                             /* If booking in advance required then there must be a participations created 8 days before the participantion taken place*/
                             AND (
                                 $$booking_req$$ = 0
                                 OR EXISTS
                                 (
                                     SELECT
                                         1
                                     FROM
                                         participations part
                                     WHERE
                                         part.participant_center = ch.person_center
                                         AND part.participant_id = ch.person_id
                                         AND part.start_time >= params.FromDate
                                         AND part.start_time <= params.ToDate
                                         AND part.state = 'PARTICIPATION'
                                         AND part.start_time >= part.creation_time + params.EightDays) )
                             /* If exlcude mulitple visit enable then more than one checkin per day per club consider to be only one count in the checkins*/
                             AND (
                                 $$exclude_multi_visit$$ = 0
                                 OR NOT EXISTS
                                 (
                                     SELECT
                                         1
                                     FROM
                                         checkins ch1
                                     WHERE
                                         ch1.person_center = ch.person_center
                                         AND ch1.person_id = ch.person_id
                                         AND ch1.checkin_center = ch.checkin_center
                                         AND ch1.checkin_time > ch.checkin_time
                                         AND TRUNC(longtodatec(ch1.checkin_time, ch1.person_center)) = TRUNC(longtodatec(ch.checkin_time, ch.person_center))) ) ) t
                 GROUP BY
                     person_center,
                     person_id,
                     checkin_center ) per_checkin
         ON
             per_checkin.person_center = p.center
             AND per_checkin.person_id = p.id
         JOIN
             centers perCenter
         ON
             perCenter.id = p.center
         JOIN
             centers checkinCenter
         ON
             checkinCenter.id = per_checkin.checkin_center
         WHERE
             p.center IN ($$Scope$$)
             AND (
                 0 IN ($$SubscriptionType$$)
                 OR EXISTS
                 (
                     SELECT
                         1
                     FROM
                         subscriptions s,
                         subscriptiontypes st,
                         products prod
                     WHERE
                         s.owner_center = p.center
                         AND s.owner_id = p.id
                         AND st.center = s.subscriptiontype_center
                         AND st.id = s.subscriptiontype_id
                         AND prod.center = st.center
                         AND prod.id = st.id
                         AND ( (
                                 1 IN ($$SubscriptionType$$)
                                 AND prod.globalid LIKE 'EXTRA%')
                             OR (
                                 2 IN ($$SubscriptionType$$)
                                 AND prod.globalid LIKE 'MULTI%')
                             OR (
                                 3 IN ($$SubscriptionType$$)
                                 AND prod.globalid LIKE 'BUDDY%')
                             OR (
                                 4 IN ($$SubscriptionType$$)
                                 AND prod.globalid LIKE 'DD_TIER%')
                             OR (
                                 5 IN ($$SubscriptionType$$)
                                 AND prod.globalid NOT LIKE 'EXTRA%'
                                 AND prod.globalid NOT LIKE 'MULTI%'
                                 AND prod.globalid NOT LIKE 'BUDDY%'
                                 AND prod.globalid NOT LIKE 'DD_TIER%') ))) ) t1
 GROUP BY
     personCenterName,
     chekinCenterName
 ORDER BY
     1, 2
