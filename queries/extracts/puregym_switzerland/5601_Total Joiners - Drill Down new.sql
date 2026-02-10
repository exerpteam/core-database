-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS materialized
    (SELECT
            /*+ materialize */
            ce.id AS CENTER ,
            CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate , 'DDD'), 'YYYY-MM-DD HH24:MI'),
            'Europe/Zurich') AS BIGINT) AS STARTTIME ,
            CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate +1, 'DDD'), 'YYYY-MM-DD HH24:MI'),
            'Europe/Zurich') AS BIGINT) AS ENDTIME,
            CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate +2, 'DDD'), 'YYYY-MM-DD HH24:MI'),
            'Europe/Zurich') AS BIGINT) AS HARDCLOSETIME
        FROM
            (
                SELECT
                    CAST(:date AS DATE) AS currentdate ) t
                    cross join centers ce
                    where ce.id in (:scope)
    )
Select
   p.FULLNAME,
    p.FIRSTNAME,
    p.LASTNAME,
    p.center||'p'||p.id AS MemberID,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    e.IDENTITY                                                             AS PIN,
    email.TXTVALUE                                                         AS Email,
    home.TXTVALUE                                                          AS PHONEHOME,
    mobile.TXTVALUE                                                        AS MOBILE,
   t2.creation_time                                           as "Subscription creation time",    
    TO_CHAR(longtodateTZ(MAX(ch.CHECKIN_TIME), 'Europe/Zurich'), 'YYYY-MM-DD HH24:MI') AS CHECKIN_TIME,
    newsletter.TXTVALUE                              AS "Newsletter",
    offers.TXTVALUE                                  AS "3rd party offers" ,
    staff.FULLNAME                                   AS Sale_Staff
    
--t2.*    
    
From    




(    
SELECT
    /*+ NO_BIND_AWARE */
           OWNER_CENTER||'p'|| OWNER_ID as memberid, 
           OWNER_CENTER,
           OWNER_ID,
            center,
            CREATOR_CENTER||'emp'|| CREATOR_ID as "Employee ID",
            CREATOR_CENTER,
            CREATOR_ID,
            longtodate(CREATION_TIME) as creation_time 
FROM
     (
        -- Outoing balance members
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID, 
            su.center,
            su.CREATOR_CENTER,
            su.CREATOR_ID,
            su.CREATION_TIME
        FROM
            PARAMS
        JOIN
            STATE_CHANGE_LOG SCL
        ON
            ( SCL.CENTER = PARAMS.CENTER
                -- Time safety. We need to exclude subscriptions started in the past so they do not
                -- get
                -- into the incoming balance because they will not be in the outgoing balance of
                -- the
                -- previous day
            AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
            AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
            AND ( SCL.BOOK_END_TIME IS NULL
                OR  SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                OR  SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
            AND SCL.ENTRY_TYPE = 2
            AND SCL.STATEID IN ( 2,
                                4,8))
        INNER JOIN
            SUBSCRIPTIONS SU
        ON
            ( SCL.CENTER = SU.CENTER
            AND SCL.ID = SU.ID
            AND SCL.ENTRY_TYPE = 2 )
        LEFT JOIN
            cashcollectioncases ccc
        ON
            ccc.personcenter = su.owner_center
        AND ccc.personid = su.owner_id
        AND ccc.missingpayment
        AND ccc.currentstep_type = 4
        AND (NOT(ccc.closed)
            OR  ccc.closed_datetime > params.ENDTIME)
        JOIN
            puregym_switzerland.product_and_product_group_link ppgl
        ON
            ppgl.product_center = su.subscriptiontype_center
        AND ppgl.product_id = su.subscriptiontype_id
        AND ppgl.product_group_id in  (601,602,603)
        WHERE
            ccc.center IS NULL -- exclude members in external debt
        EXCEPT
        -- That are not in incoming balance
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID, su.center,
            su.CREATOR_CENTER,
            su.CREATOR_ID,
            su.CREATION_TIME
        FROM
            PARAMS
        JOIN
            STATE_CHANGE_LOG SCL
        ON
            ( SCL.CENTER = PARAMS.CENTER
                -- Time safety. We need to exclude subscriptions started in the past so they do not
                -- get
                -- into the incoming balance because they will not be in the outgoing balance of
                -- the
                -- previous day
            AND SCL.BOOK_START_TIME < PARAMS.STARTTIME
            AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME
            AND ( SCL.BOOK_END_TIME IS NULL
                OR  SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                OR  SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
            AND SCL.ENTRY_TYPE = 2
            AND SCL.STATEID IN ( 2,
                                4,8))
        INNER JOIN
            SUBSCRIPTIONS SU
        ON
            ( SCL.CENTER = SU.CENTER
            AND SCL.ID = SU.ID
            AND SCL.ENTRY_TYPE = 2 )
        LEFT JOIN
            cashcollectioncases ccc
        ON
            ccc.personcenter = su.owner_center
        AND ccc.personid = su.owner_id
        AND ccc.missingpayment
        AND ccc.currentstep_type = 4
        AND (NOT(ccc.closed)
            OR  ccc.closed_datetime > params.STARTTIME)
        JOIN
            puregym_switzerland.product_and_product_group_link ppgl
        ON
            ppgl.product_center = su.subscriptiontype_center
        AND ppgl.product_id = su.subscriptiontype_id
        AND ppgl.product_group_id in  (601,602,603)
    ) t )t2
join persons p
on t2.OWNER_CENTER = p.center
and t2.OWNER_ID = p.id    

LEFT JOIN
    PERSON_EXT_ATTRS newsletter
ON
    t2.OWNER_CENTER=newsletter.PERSONCENTER
    AND t2.OWNER_ID=newsletter.PERSONID
    AND newsletter.name='eClubIsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS offers
ON
    t2.OWNER_CENTER=offers.PERSONCENTER
    AND t2.OWNER_ID=offers.PERSONID
    AND offers.name='eClubIsAcceptingThirdPartyOffers'
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
    EMPLOYEES emp
ON
    emp.center = t2.CREATOR_CENTER
    AND emp.id = t2.CREATOR_ID    
left join persons staff
on
emp.personcenter = p.center
and
emp.personid = p.id
LEFT JOIN
    CHECKINS ch
ON
    p.center = ch.PERSON_CENTER
    AND p.id = ch.PERSON_ID
 
GROUP BY
    p.FULLNAME,
    p.FIRSTNAME,
    p.LASTNAME,
    p.center||'p'||p.id ,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    e.IDENTITY ,
    email.TXTVALUE ,
    home.TXTVALUE ,
    mobile.TXTVALUE ,
    --NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea.txtvalue),
   -- Yes_PT.NUMBER_ANSWER,
    newsletter.TXTVALUE,
    offers.TXTVALUE,
    staff.FULLNAME,
    t2.creation_time   