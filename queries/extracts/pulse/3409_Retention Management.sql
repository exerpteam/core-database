SELECT
    test.clubid,
    test.memnum,
    test."memnum (appendedw/hyphen)",
    test.lname,
    test.fname,
    test.dob,
    test.jdate,
    test.hphone,
    test.email,
    test.status,
    test.freeze,
    test.memtype,
    test.lastvisit,
    test.renewal,
    test.expdate,
    test.visits
FROM
    (
        SELECT
            p.CENTER                                      AS clubid,
            p.CENTER || 'p' || p.ID                       AS memnum,
            p.CENTER || 'p' || p.ID                       AS "memnum (appendedw/hyphen)",
            NVL(p.LASTNAME,' ')                                    AS lname,
            NVL(p.FIRSTNAME,' ')                                   AS fname,
            NVL(TO_CHAR(p.BIRTHDATE,'mm/dd/yyyy'),' ')    AS dob,
            NVL(TO_CHAR(p.FIRST_ACTIVE_START_DATE,'mm/dd/yyyy'),' ') AS jdate,
            CASE
                WHEN home_phone.PERSONCENTER IS NOT NULL
                THEN NVL(home_phone.TXTVALUE,' ')
                ELSE NVL(mobile.TXTVALUE,' ')
            END                                                                                                                                              AS hphone,
            NVL(email.TXTVALUE,' ')                                                                                                                                   AS email,
            DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') AS status,
            CASE
                WHEN DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') = 'TEMPORARYINACTIVE'
                THEN 'yes'
                ELSE 'no'
            END       AS freeze,
            prod.NAME AS memtype,
            NVL(TO_CHAR(
            (
                SELECT
                    longToDate(MAX(cins.CHECKIN_TIME))
                FROM
                    CHECKINS cins
                WHERE
                    cins.PERSON_CENTER = p.CENTER
                    AND cins.PERSON_ID = p.id
            )
            ,'mm/dd/yyyy'),' ')                                               AS lastvisit,
            DECODE(st.ST_TYPE,0,'paidinfull',1,'auto-renew','UNKNOWN') AS renewal,
            NVL(TO_CHAR(s.END_DATE,'mm/dd/yyyy'),' ')                             AS expdate,
            (
                SELECT
                    COUNT(c.id)
                FROM
                    CHECKINS c
                WHERE
                    c.PERSON_CENTER = p.CENTER
                    AND c.PERSON_ID = p.ID
                    /* Uses durrent date and backs up one week starting monday and
                    leaving sunday night. This according to normal swedish weeks */
                    AND c.CHECKIN_TIME BETWEEN dateToLong(TO_CHAR(TRUNC(sysdate-6-to_number(TO_CHAR((sysdate),'D'))),'YYYY-MM-dd
HH24') || ':00')
                    AND dateToLong(TO_CHAR(TRUNC(sysdate+1-to_number(TO_CHAR((sysdate),'D'))),'YYYY-MM-dd
HH24') || ':00')
            ) AS visits
        FROM
            PERSONS p
        LEFT JOIN SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.STATE IN (2,4,6)
        LEFT JOIN SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.ID = s.SUBSCRIPTIONTYPE_ID
        JOIN PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.id = s.SUBSCRIPTIONTYPE_ID
        JOIN MASTERPRODUCTREGISTER mpr
        ON
            mpr.GLOBALID = prod.GLOBALID
        JOIN PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_ID = mpr.ID
        JOIN PRIVILEGE_SETS ps
        ON
            ps.ID = pg.PRIVILEGE_SET
        JOIN BOOKING_PRIVILEGES bp
        ON
            bp.PRIVILEGE_SET = ps.ID
        JOIN BOOKING_PRIVILEGE_GROUPS bpg
        ON
            bp.GROUP_ID = bpg.ID
        LEFT JOIN PERSON_EXT_ATTRS email
        ON
            email.PERSONCENTER = p.CENTER
            AND email.PERSONID = p.ID
            AND email.NAME = '_eClub_Email'
        LEFT JOIN PERSON_EXT_ATTRS mobile
        ON
            mobile.PERSONCENTER = p.CENTER
            AND mobile.PERSONID = p.ID
            AND mobile.NAME = '_eClub_PhoneSMS'
        LEFT JOIN PERSON_EXT_ATTRS home_phone
        ON
            home_phone.PERSONCENTER = p.CENTER
            AND home_phone.PERSONID = p.ID
            AND home_phone.NAME = '_eClub_PhoneHome'
        WHERE
            p.STATUS IN (1,3)
            AND p.CENTER IN (205)
            /* only include the subscriptions that gives access to fitness */
            AND bp.GROUP_ID IN (1)
            AND pg.VALID_FROM <= dateToLong(TO_CHAR(sysdate, 'YYYY-MM-dd HH24:MI'))
            AND
            (
                pg.VALID_TO >= dateToLong(TO_CHAR(sysdate, 'YYYY-MM-dd HH24:MI'))
                OR pg.VALID_TO IS NULL
            )
    )
    test
GROUP BY
    test.clubid,
    test.memnum,
    test."memnum (appendedw/hyphen)",
    test.lname,
    test.fname,
    test.dob,
    test.jdate,
    test.hphone,
    test.email,
    test.status,
    test.freeze,
    test.memtype,
    test.lastvisit,
    test.renewal,
    test.expdate,
    test.visits