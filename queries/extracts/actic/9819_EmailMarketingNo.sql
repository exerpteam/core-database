WITH
    PARAMS AS
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
    p.PINCODE                                                    AS PINCode,
    pea_email.txtvalue                                           AS Email,
    p.center                                                     AS CenterId,
    DECODE(p.sex, 'M', 'MALE', 'F', 'FEMALE')                    AS Gender,
    (NVL(per_par.par_count,0) + NVL(per_booked_par.par_count,0)) AS TotalBookedClasses,
    longtodate(per_par.LAST_START_TIME)                          AS LatestPastClassParticipated,
    longtodate(per_booked_par.FIRST_START_TIME)                  AS NextFutureClassBooked,
    NVL(per_att.att_count, 0)                                    AS TotalCheckIns,
    longtodate(per_att.max_start_time)                           AS LatestCheckIn,
    -- per_att.count_30_days as TotalCheckInsInLast30Days,
    latest_att.att_count                                                                                                                             AS TotalCheckInsInLast30Days,
    DECODE(current_sub.MaxStType, 0, 'CASH', 1, 'EFT', NULL)                                                                                         AS MembershipType,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') AS PersonStatus,
    -- sub.START_DATE, sub.END_DATE,
    CASE
        WHEN current_sub.MaxEndDate = to_date('2100-01-01', 'YYYY-MM-DD')
        THEN NULL
        WHEN current_sub.MaxEndDate IS NOT NULL
        THEN current_sub.MaxEndDate
        ELSE p.LAST_ACTIVE_END_DATE
    END                                                                                                                                                     AS SusbcriptionStopDate,
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    p.FIRSTNAME,
    p.LASTNAME,
    pea_home.txtvalue   AS Phone,
    pea_mobile.txtvalue AS Mobile,
    p.ADDRESS1          AS Address1,
    p.ADDRESS2          AS Address2,
    p.CITY              AS City,
    p.ZIPCODE           AS Postcode,
    current_sub.MaxSubSalesDate, --
    current_sub.MaxSubStartDate,  --
	DECODE (current_sub.Extended, 1,'TRUE') AS SubscriptionExtended,
	actic_anywhere.txtvalue AS ACTIC_ANYWHERE
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

LEFT JOIN PERSON_EXT_ATTRS actic_anywhere
ON
     actic_anywhere.PERSONCENTER = p.center
AND  actic_anywhere.PERSONID = p.id
AND  actic_anywhere.NAME = 'TWIIKID'


LEFT JOIN
    (
        SELECT
            sub.owner_center,
            sub.owner_id,
            MAX(NVL(sub.end_date, to_date('2100-01-01', 'YYYY-MM-DD'))) AS MaxEndDate,
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
        join subscription_sales ss               -- 
        on                                             -- 
            sub.center = ss.subscription_center        -- 
        and sub.id = ss.subscription_id                -- 
        WHERE
            sub.STATE IN (2,4,8)
        GROUP BY
            sub.owner_center,
            sub.owner_id
    )
    current_sub
ON
    current_sub.owner_center = p.center
AND current_sub.owner_id = p.id
LEFT JOIN
    (
        SELECT
            attends.person_center,
            attends.person_id,
            COUNT(*)                AS att_count,
            MAX(attends.start_time) AS max_start_time
        FROM
            attends
        WHERE
            attends.state = 'ACTIVE'
        GROUP BY
            attends.person_center,
            attends.person_id
    )
    per_att
ON
    per_att.person_center = p.center
AND per_att.person_id = p.id
LEFT JOIN
    (
        SELECT
            attends.person_center,
            attends.person_id,
            COUNT(*) AS att_count
        FROM
            attends
		JOIN PARAMS params ON params.CenterID = attends.CENTER
        WHERE
            attends.state = 'ACTIVE'
        AND attends.start_time > params.cutDate
        GROUP BY
            attends.person_center,
            attends.person_id
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
AND p.status < 4
AND p.center IN (:scope)
AND p.PERSONTYPE NOT IN (2,8,9)
AND pea_email.txtvalue IS NOT NULL