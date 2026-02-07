 SELECT DISTINCT
     s.center || 'ss' || s.id                                                                                                                                                             AS "Subscription ID",
     p.center || 'p' || p.id                                                                                                                                                              AS "Person ID",
     CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END                            AS "Person Type",
     pd.name                                                                                                                                                                              AS "Subscription Name",
     p.fullname                                                                                                                                                                           AS "Full Name",
     floor(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE) / 12)                                                                                                                                     AS "Age",
     p.sex                                                                                                                                                                                AS "Sex",
     TO_CHAR(p.birthdate, 'DD-MM-YYYY')                                                                                                                                                   AS "Birthday",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END      AS "Person Status",
     CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END                                                                                               AS "Subscription Status",
     CASE  s.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'UNKNOWN' END AS "Subscription Sub State",
     TO_CHAR(s.start_date, 'DD-MM-YYYY')                                                                                                                                                  AS "Subscription Start Date",
     TO_CHAR(s.end_date, 'DD-MM-YYYY')                                                                                                                                                    AS "Subscription Stop Date",
     TO_CHAR(s.binding_end_date, 'DD-MM-YYYY')                                                                                                                                            AS "Binding End Date",
     s.subscription_price                                                                                                                                                                 AS "Subscription Price",
     TO_CHAR(longtodatec(att.latest, att.person_center), 'DD-MM-YYYY')                                                                                                                    AS "Date of Last Access",
     attcenter.name                                                                                                                                                                       AS "Home Center Last Access",
     subcenter.name                                                                                                                                                                       AS "Subscription Home Center",
     email.txtvalue                                                                                                                                                                       AS "Email",
     mobile.txtvalue                                                                                                                                                                      AS "Mobile",
     TO_CHAR(longtodatec(par.start_time, par.center), 'DD-MM-YYYY HH24:MI')                                                                                                               AS "Time Booking",
     parcenter.name                                                                                                                                                                       AS "Center Booking",
     b.name                                                                                                                                                                               AS "Activity Name",
     par.state                                                                                                                                                                            AS "Participation Status",
     pu.misuse_state                                                                                                                                                                      AS "Misuse Status",
     CASE  par.USER_INTERFACE_TYPE  WHEN 0 THEN 'OTHER'  WHEN 1 THEN 'CLIENT' WHEN 2 THEN 'WEB' WHEN 3 THEN 'KIOSK' WHEN 4 THEN 'SCRIPT' WHEN 5 THEN 'API' WHEN 6 THEN 'MOBILE API' ELSE 'UNKNOWN' END                                                                AS "Interface"
 FROM
     participations par
 JOIN
     centers parcenter
 ON
     parcenter.id = par.center
 JOIN
     bookings b
 ON
     par.booking_center = b.center
     AND par.booking_id = b.id
 JOIN
     privilege_usages pu
 ON
     pu.target_service = 'Participation'
     AND pu.target_center = par.center
     AND pu.target_id = par.id
 JOIN
     persons p
 ON
     p.center = par.participant_center
     AND p.id = par.participant_id
 JOIN
     subscriptions s
 ON
     s.owner_center = p.center
     AND s.owner_id = p.id
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     s.SUBSCRIPTIONTYPE_CENTER=st.center
     AND s.SUBSCRIPTIONTYPE_ID=st.id
 JOIN
     PRODUCTS pd
 ON
     st.center=pd.center
     AND st.id=pd.id
 JOIN
     CENTERS subcenter
 ON
     subcenter.id = s.center
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
 LEFT JOIN
     (
         SELECT
             a.person_center,
             a.person_id,
             MAX(a.center)     AS attend_center,
             MAX(a.start_time) AS latest
         FROM
             attends a
         JOIN
             booking_resources br
         ON
             br.center = a.booking_resource_center
             AND br.id = a.booking_resource_id
             AND br.name = 'Gym Floor'
         WHERE
             a.person_center IN ($$Scope$$)
             AND a.state = 'ACTIVE'
         GROUP BY
             a.person_center,
             a.person_id ) att
 ON
     att.person_center = p.center
     AND att.person_id = p.id
 LEFT JOIN
     CENTERS attcenter
 ON
     attcenter.id = att.attend_center
 WHERE
     par.CENTER IN ($$Scope$$)
     AND par.start_time >= $$From_Datetime$$
     AND par.start_time <= $$To_Datetime$$
     AND par.state IN ($$Partcipation_Status$$)
