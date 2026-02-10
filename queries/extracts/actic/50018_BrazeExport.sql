-- The extract is extracted from Exerp on 2026-02-08
-- Braze Export. Used to export data for parsing and import to external MA-system
WITH
    PARAMS AS materialized
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI') - 30), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86399000 AS cutDate,
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')) AS todaysDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
    p.center,
    p.id,
    pea_creationdate.txtvalue                                    AS CreationDate,
    p.center || 'p' || p.id                                      AS PersonId,
    pea_email.txtvalue                                           AS Email,
    --DECODE(current_sub.MaxKort, 1, 'TRUE', 'FALSE')              AS AccessMaxkort,
	CASE current_sub.MaxKort  WHEN 2024 THEN  'MAKXORT' WHEN 13024 THEN 'LETS DEAL'  ELSE 'OTHER' END           AS AccessMaxkort,
    CASE p.sex  WHEN 'M' THEN  'MALE'  WHEN 'F' THEN  'FEMALE' END                    AS Gender,
    (COALESCE(per_par.par_count,0) + COALESCE(per_booked_par.par_count,0)) AS TotalBookedClasses,
    longtodate(per_par.LAST_START_TIME)                          AS LatestPastClassParticipated,
    longtodate(per_booked_par.FIRST_START_TIME)                  AS NextFutureClassBooked,
    COALESCE(per_att.att_count, 0)                                    AS TotalCheckIns,
    longtodate(per_att.max_start_time)                           AS LatestCheckIn,
    -- per_att.count_30_days as TotalCheckInsInLast30Days,
    CASE current_sub.MaxStType  WHEN 0 THEN  'CASH'  WHEN 1 THEN  'EFT'  ELSE NULL END                                                                                         AS MembershipType,
    CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED'  WHEN 9 THEN 'CONTACT'  ELSE 'UNKNOWN' END AS PersonStatus,
	-- sub.START_DATE, sub.END_DATE,
    CASE
        WHEN current_sub.MaxEndDate = to_date('2100-01-01', 'YYYY-MM-DD')
        THEN NULL
        WHEN current_sub.MaxEndDate IS NOT NULL
        THEN current_sub.MaxEndDate
        ELSE p.LAST_ACTIVE_END_DATE
    END                                                                                                                                                     AS SusbcriptionStopDate,
    CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE,
    p.FIRSTNAME,
    p.LASTNAME,
    pea_mobile.txtvalue   AS Phone,
    current_sub.MaxSubSalesDate, --
    current_sub.MaxSubStartDate,  --
	CASE  current_sub.Extended  WHEN 1 THEN 'TRUE'  ELSE 'FALSE' END AS SubscriptionExtended,

	pea_loyaltyLevel.txtvalue AS loyaltyLevel,
	pea_loyaltyLevelName.txtvalue AS loyaltyLevelName,
	pea_loyaltyPoints.txtvalue AS loyaltyPoints,
	actic_anywhere.txtvalue AS ACTIC_ANYWHERE,
	p.EXTERNAL_ID AS EXTERNAL_ID,
	current_sub.BINDING_END_DATE AS SubscriptionBindingEndDate,
	REPLACE(center.NAME, ',','')			  	 AS CenterName,
	p.BIRTHDATE					 AS BIRTHDATE,
	p.CITY						 AS CITY,
	pea_newsletter.txtvalue      AS ACCEPTING_NEWSLETTER,
	center.COUNTRY AS COUNTRY,
	p.ADDRESS1 AS STREET_ADRESS,
	p.ZIPCODE AS ZIPCODE

FROM
    persons p
JOIN PARAMS params ON params.CenterID = p.CENTER
LEFT JOIN PERSON_EXT_ATTRS pea_creationdate
ON
    pea_creationdate.PERSONCENTER = p.center
AND pea_creationdate.PERSONID = p.id
AND pea_creationdate.NAME = 'CREATION_DATE'
LEFT JOIN PERSON_EXT_ATTRS pea_email
ON
    pea_email.PERSONCENTER = p.center
AND pea_email.PERSONID = p.id
AND pea_email.NAME = '_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS pea_home
ON
    pea_home.PERSONCENTER = p.center
AND pea_home.PERSONID = p.id
AND pea_home.NAME = '_eClub_PhoneHome'
LEFT JOIN PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = p.center
AND pea_mobile.PERSONID = p.id
AND pea_mobile.NAME = '_eClub_PhoneSMS'

LEFT JOIN PERSON_EXT_ATTRS pea_loyaltyLevel
ON
    pea_loyaltyLevel.PERSONCENTER = p.center
AND pea_loyaltyLevel.PERSONID = p.id
AND pea_loyaltyLevel.NAME = 'loyaltyLevel'

LEFT JOIN PERSON_EXT_ATTRS pea_loyaltyLevelName
ON
    pea_loyaltyLevelName.PERSONCENTER = p.center
AND pea_loyaltyLevelName.PERSONID = p.id
AND pea_loyaltyLevelName.NAME = 'loyaltyLevelName'

LEFT JOIN PERSON_EXT_ATTRS pea_loyaltyPoints
ON
    pea_loyaltyPoints.PERSONCENTER = p.center
AND pea_loyaltyPoints.PERSONID = p.id
AND pea_loyaltyPoints.NAME = 'loyaltyPoints'

LEFT JOIN PERSON_EXT_ATTRS actic_anywhere
ON
     actic_anywhere.PERSONCENTER = p.center
AND  actic_anywhere.PERSONID = p.id
AND  actic_anywhere.NAME = 'TWIIKID'

LEFT JOIN PERSON_EXT_ATTRS pea_newsletter
ON
     pea_newsletter.PERSONCENTER = p.center
AND  pea_newsletter.PERSONID = p.id
AND  pea_newsletter.NAME = 'eClubIsAcceptingEmailNewsLetters'


LEFT JOIN CENTERS center ON
	p.CENTER = center.ID
	

LEFT JOIN
    (
        SELECT
            sub.owner_center,
            sub.owner_id,
	    sub.BINDING_END_DATE,
            MAX(COALESCE(sub.end_date, to_date('2100-01-01', 'YYYY-MM-DD'))) AS MaxEndDate,
            MAX(
                CASE
                    WHEN st.ST_TYPE = 0
                    THEN 0
                    WHEN sub.BINDING_END_DATE IS NULL
                     OR params.todaysDate > sub.BINDING_END_DATE
                    THEN sub.SUBSCRIPTION_PRICE
                    ELSE sub.BINDING_PRICE
                END) AS MaxEFTPrice,
            MAX(
                CASE
                    WHEN st.ST_TYPE = 1
                    THEN 0
                    ELSE sub.SUBSCRIPTION_PRICE
                END)        AS MaxCashPrice,
            MAX(st.st_type) AS MaxStType,
            MAX(
                CASE
                    WHEN pgl.PRODUCT_CENTER IS NOT NULL
                    THEN pgl.PRODUCT_GROUP_ID
                    ELSE 0
                END) AS MaxKort,
            MAX(SS.sales_date) as MaxSubSalesDate, --
            MAX(SS.start_date) as MaxSubStartDate,  --
			MAX(
				CASE
					WHEN sub.sub_state = 5
					THEN 1
					ELSE 0
				END) AS Extended
        FROM
            SUBSCRIPTIONS sub
		JOIN PARAMS params ON params.CenterID = sub.CENTER
        JOIN SUBSCRIPTIONTYPES st
        ON
            st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
        AND st.id = sub.SUBSCRIPTIONTYPE_ID
        LEFT JOIN PRODUCT_AND_PRODUCT_GROUP_LINK pgl
        ON
            pgl.PRODUCT_CENTER = st.center
        AND pgl.PRODUCT_ID = st.id
        AND pgl.PRODUCT_GROUP_ID IN (2024, 13024)
        join subscription_sales ss               -- 
        on                                             -- 
            sub.center = ss.subscription_center        -- 
        and sub.id = ss.subscription_id                -- 
        WHERE
            sub.STATE IN (2,4,8)
        GROUP BY
            sub.owner_center,
            sub.owner_id,
			sub.BINDING_END_DATE
    )
    current_sub
ON
    current_sub.owner_center = p.center
AND current_sub.owner_id = p.id
LEFT JOIN
    (
        SELECT
            mxpdt.center,
            COUNT(*) AS CNT
        FROM
            products mxpdt
        WHERE
            mxpdt.GLOBALID = 'EFT_12_M_AREA'
        AND mxpdt.BLOCKED = 0
        GROUP BY
            mxpdt.center
    )
    CENTER_MAX_KORT
ON
    CENTER_MAX_KORT.center = p.center
LEFT JOIN
    (
        SELECT
            checkins.person_center,
            checkins.person_id,
            COUNT(*)                AS att_count,
            MAX(checkins.checkin_time) AS max_start_time
        FROM
            checkins
        GROUP BY
            checkins.person_center,
            checkins.person_id
    )
    per_att
ON
    per_att.person_center = p.center
AND per_att.person_id = p.id
LEFT JOIN
    (
        SELECT
            checkins.person_center,
            checkins.person_id,
            COUNT(*) AS att_count
        FROM
            checkins
		JOIN PARAMS params ON params.CenterID = checkins.CHECKIN_CENTER
        WHERE 
			checkins.checkin_time > params.cutDate
        GROUP BY
            checkins.person_center,
            checkins.person_id
    )
    latest_att
ON
    latest_att.person_center = p.center
AND latest_att.person_id = p.id
LEFT JOIN
    (
        SELECT
            COUNT(*) par_count,
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID,
            MAX(par.START_TIME) LAST_START_TIME
        FROM
            PARTICIPATIONS par
        JOIN BOOKINGS bk
        ON
            bk.center = par.BOOKING_CENTER
        AND bk.id = par.BOOKING_ID
        JOIN ACTIVITY act
        ON
            bk.ACTIVITY = act.ID
        WHERE
            par.STATE IN ('PARTICIPATION')
        AND act.ACTIVITY_TYPE = 2
        GROUP BY
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID
    )
    per_par
ON
    per_par.PARTICIPANT_CENTER = p.CENTER
AND per_par.PARTICIPANT_ID = p.ID
LEFT JOIN
    (
        SELECT
            COUNT(*) par_count,
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID,
            MIN(par.START_TIME) FIRST_START_TIME,
            MAX(par.START_TIME) LAST_START_TIME
        FROM
            PARTICIPATIONS par
        JOIN BOOKINGS bk
        ON
            bk.center = par.BOOKING_CENTER
        AND bk.id = par.BOOKING_ID
        JOIN ACTIVITY act
        ON
            bk.ACTIVITY = act.ID
        WHERE
            par.STATE IN ('BOOKED')
        AND act.ACTIVITY_TYPE = 2
        GROUP BY
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID
    )
    per_booked_par
ON
    per_booked_par.PARTICIPANT_CENTER = p.CENTER
	AND per_booked_par.PARTICIPANT_ID = p.ID
WHERE
    p.sex != 'C'

AND p.status NOT IN(4,5,7)

AND p.center IN (:scope)
AND p.PERSONTYPE NOT IN (8,9)

AND pea_email.txtvalue IS NOT NULL

