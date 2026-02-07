        SELECT
            TO_CHAR(longToDate(sp.CANCELLED_ENTRY_TIME),'YYYY-MM-DD')                                                                                        cancelled,
            sp.SUBSCRIPTION_CENTER || 'ss' || sp.SUBSCRIPTION_ID                                                                                                     sid,
            DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN')                                                                   AS SUBSCRIPTION_STATE,
            DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
            nvl2(m.CENTER,1,0)                                                                                                                                          MESSAGE ,
            sp.FROM_DATE,
            sp.TO_DATE,
            sp.TYPE,
            longToDate(m.SENTTIME)                                                                                                                              message_created,
            m.SUBJECT,
            m.DELIVERYCODE
        FROM
            SUBSCRIPTION_PRICE sp
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sp.SUBSCRIPTION_CENTER
            AND s.id = sp.SUBSCRIPTION_ID
        JOIN
            PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.ID = s.OWNER_ID
        LEFT JOIN
            MESSAGES m
        ON
            --    m.DELIVERYCODE = 0
            --    AND m.DELIVERYMETHOD = 5
            --    AND m.TEMPLATETYPE = 64
            --    AND m.MESSAGE_TYPE_ID = 116
            --    AND m.SUBJECT = 'Important news about your Classic membership'
            --    AND
            m.REFERENCE = 'sp' || sp.ID
        WHERE
            sp.CANCELLED_EMPLOYEE_CENTER = 4
            AND sp.CANCELLED_EMPLOYEE_ID = 1
            --AND s.STATE IN (2,4,8)
            --and sp.id =  725873
            --AND m.CENTER IS NOT NULL
            AND TO_CHAR(longToDate(sp.CANCELLED_ENTRY_TIME),'YYYY-MM-DD') IN ('2015-04-13',
                                                                                      '2015-04-14')
