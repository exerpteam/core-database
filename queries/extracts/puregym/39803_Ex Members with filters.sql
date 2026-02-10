-- The extract is extracted from Exerp on 2026-02-08
-- ST-2299
-- Parameters: center(SCOPE)

SELECT distinct
    cen.NAME,
    p.CENTER || 'p' || p.ID AS Pref,
    P.FULLNAME,
    CASE  P.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE,
    trim(P.FIRSTNAME) FIRSTNAME,
    trim(P.LASTNAME) LASTNAME,
    e.IDENTITY AS PIN,
    pea_relational.TXTVALUE as TRP_RELATIONAL,
    pea_attendance.TXTVALUE as TRP_ATTENDANCE,
    P.SEX,
    P.BLACKLISTED,
    P.ADDRESS1,
    P.ADDRESS2,
    P.COUNTRY,
    P.ZIPCODE,
    P.BIRTHDATE,
    P.CITY,
    ph.txtvalue  AS phonehome,
    pm.txtvalue  AS phonemobile,
    pem.txtvalue AS email,
    p.EXTERNAL_ID,
    CASE AEM.TXTVALUE  WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END  AS "Opt in to emails",
    CASE ANL.TXTVALUE  WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END  AS "Opt in to News Letter",
    CASE  WHEN pl_mem.is_now = 0 THEN 'No' WHEN pl_mem.is_now IS NULL THEN 'No' ELSE 'Yes' END   AS "Current PLoser Member",
    CASE  WHEN pl_mem.has_ever = 0 THEN 'No' WHEN pl_mem.has_ever IS NULL THEN 'No' ELSE 'Yes' END AS "Past PLoser Member",
    CASE
        WHEN P.LAST_ACTIVE_START_DATE IS NULL
        THEN 0
        WHEN P.LAST_ACTIVE_END_DATE IS NOT NULL        
        THEN 0
        WHEN P.LAST_ACTIVE_END_DATE IS NULL
        THEN TRUNC(current_timestamp) - P.LAST_ACTIVE_START_DATE + 1
        ELSE P.MEMBERDAYS
    END "Unbroken membership days",
    CASE
        WHEN P.LAST_ACTIVE_END_DATE IS NULL
        THEN TRUNC(current_timestamp) - P.LAST_ACTIVE_START_DATE + 1 + P.ACCUMULATED_MEMBERDAYS
        ELSE P.ACCUMULATED_MEMBERDAYS + P.MEMBERDAYS
    END     "Accumulated membership days",
    checkin_center.shortname as "Last visited club name",
    s.end_date as "Last membership end date",
    longtodateTZ(checkin.checkin_time,  'Europe/London') as "Last club visted",
    CASE ATPO.TXTVALUE  WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END  AS "Opt in to Marketing"
FROM
    PERSONS P -- current member
JOIN
    PERSONS p2 --all the transferred members and the current member
ON
    p2.CURRENT_PERSON_CENTER = p.CENTER
    AND p2.CURRENT_PERSON_ID = p.ID
JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
    AND ar.customerid = p.id
 AND ar.ar_type = 4
JOIN
    payment_accounts pa
ON
    pa.center = ar.center
    AND pa.id = ar.id
JOIN
    payment_agreements pag
ON
    pag.center = pa.active_agr_center
    AND pag.id = pa.active_agr_id
    AND pag.subid = pa.active_agr_subid
    AND pag.state = 7
JOIN
    agreement_change_log acl
ON
    acl.agreement_center = pag.center
    AND acl.agreement_id = pag.id
    AND acl.agreement_subid = pag.subid
    AND acl.state = 7
    AND TRUNC(longtodateC(acl.entry_time, acl.agreement_center)) = TRUNC(ADD_MONTHS (current_timestamp, -2))    
LEFT JOIN
    person_ext_attrs ph
ON
    ph.personcenter = p.center
    AND ph.personid = p.id
    AND ph.name = '_eClub_PhoneHome'
LEFT JOIN
    person_ext_attrs pem
ON
    pem.personcenter = p.center
    AND pem.personid = p.id
    AND pem.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs pm
ON
    pm.personcenter = p.center
    AND pm.personid = p.id
    AND pm.name = '_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS AEM
ON
    AEM.PERSONCENTER = p.CENTER
    AND AEM.PERSONID = p.ID
    AND AEM.NAME = '_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS ANL
ON
    ANL.PERSONCENTER = p.CENTER
    AND ANL.PERSONID = p.ID
    AND ANL.NAME = 'eClubIsAcceptingEmailNewsLetters'
LEFT JOIN 
    PERSON_EXT_ATTRS pea_attendance
ON
    pea_attendance.personcenter = p.center
    AND pea_attendance.personid = p.id
    AND pea_attendance.NAME = 'ATTENDANCE_NPS'
LEFT JOIN 
    PERSON_EXT_ATTRS pea_relational
ON
    pea_relational.personcenter = p.center
    AND pea_relational.personid = p.id
    AND pea_relational.NAME = 'RELATIONAL_NPS'
LEFT JOIN
    PERSON_EXT_ATTRS ATPO
ON
    ATPO.PERSONCENTER = p.CENTER
    AND ATPO.PERSONID = p.ID
    AND ATPO.NAME = 'eClubIsAcceptingThirdPartyOffers'               
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
    (
        SELECT
            ap.CURRENT_PERSON_CENTER,
            ap.CURRENT_PERSON_ID,
            SUM(
                CASE
                    WHEN pl.STATE IN (2,4,8)
                    THEN 1
                    ELSE 0
                END)                          AS is_now,
            SUM(CASE pl.CENTER WHEN null THEN 0 ELSE 1 END) AS has_ever
        FROM
            SUBSCRIPTIONS pl
        JOIN
            PERSONS ap
        ON
            ap.CENTER = pl.OWNER_CENTER
            AND ap.id = pl.OWNER_ID
        JOIN
            PRODUCTS pl_pr
        ON
            pl_pr.CENTER = pl.SUBSCRIPTIONTYPE_CENTER
            AND pl_pr.ID = pl.SUBSCRIPTIONTYPE_ID
        WHERE
            pl_pr.GLOBALID='PURE_LOSER'
        GROUP BY
            ap.CURRENT_PERSON_CENTER,
            ap.CURRENT_PERSON_ID) pl_mem
ON
    pl_mem.CURRENT_PERSON_CENTER = p.CENTER
    AND pl_mem.CURRENT_PERSON_ID = p.ID
LEFT JOIN
    (
        SELECT
            op.CURRENT_PERSON_CENTER,
            op.CURRENT_PERSON_ID,
            MAX(s.START_DATE) START_DATE
        FROM
            SUBSCRIPTIONS s
        JOIN
            PERSONS op
        ON
            op.CENTER = s.OWNER_CENTER
            AND op.id = s.OWNER_ID
        WHERE
            s.STATE != 5
        GROUP BY
            op.CURRENT_PERSON_CENTER,
            op.CURRENT_PERSON_ID) last_sub
ON
    last_sub.CURRENT_PERSON_CENTER = p.CENTER
    AND last_sub.CURRENT_PERSON_ID = p.id
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p2.CENTER
    AND s.OWNER_ID = p2.id
    AND s.START_DATE = last_sub.START_DATE
LEFT JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    PRODUCTS pr
ON
    pr.CENTER = st.CENTER
    AND pr.id = st.ID
LEFT JOIN
   ( select ci.person_center,
            ci.person_id,
            MAX(ci.checkin_time) as last_checkin_time
     from
        checkins ci
     group by 
        ci.person_center,
        ci.person_id
   ) last_checkin
ON
    last_checkin.person_center = p.CENTER
    AND last_checkin.person_id = p.ID    
LEFT JOIN
    checkins checkin
ON
    checkin.person_center = p.center
    AND checkin.person_id = p.id
    AND checkin.checkin_time = last_checkin.last_checkin_time
LEFT JOIN
    centers checkin_center
ON
    checkin_center.id = checkin.checkin_center

WHERE
    P.CENTER IN ($$center$$)
    AND P.STATUS = 2
    AND P.PERSONTYPE != 2
    AND (
        st.ST_TYPE = 1
        OR pr.GLOBALID = 'PURE_LOSER')
    AND EXISTS
    (
        SELECT
            1
        FROM
            account_receivables ar,
            payment_requests pr
        WHERE
            ar.customercenter = p.center
            AND ar.customerid = p.id
            AND ar.center = pr.center
            AND ar.id = pr.id
            AND ar.ar_type = 4
            AND pr.request_type = 1
            AND pr.state IN (3,4)
            AND pr.req_date > ADD_MONTHS (s.end_date, -6)
        HAVING COUNT(1) > 5) 