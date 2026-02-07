 SELECT DISTINCT
     "Club",
     "ID Member",
     "Full Name",
     "Subs",
     "Type",
     "Campaign Code",
     "From Date",
     "To Date",
     "Assigned Date",
     "Subscription Start Date",
     "Binding End Date"
 FROM
     (
         SELECT
             c.name                                AS "Club",
             s.OWNER_CENTER||'p'|| s.OWNER_ID      AS "ID Member",
             p.FULLNAME                            AS "Full Name",
             pr.name                               AS "Subs",
             'Startup Campaign'                    AS "Type",
             cc.code                               AS "Campaign Code",
             TO_CHAR(srp.START_DATE,'yyyy-MM-dd')  AS "From Date",
             TO_CHAR( srp.END_DATE,'yyyy-MM-dd')   AS "To Date",
             longtodateC(s.CREATION_TIME,s.center) AS "Assigned Date",
             s.START_DATE                          AS "Subscription Start Date",
             s.BINDING_END_DATE                    AS "Binding End Date"
         FROM
             SUBSCRIPTIONS s
         JOIN
             SUBSCRIPTION_REDUCED_PERIOD srp -- Free periods assigned by a startup campaign, as a use of the free days that were stored.
         ON
             srp.SUBSCRIPTION_CENTER = s.center
             AND srp.SUBSCRIPTION_ID = s.id
             AND (( (
                         s.STUP_FREE_PERIOD_TYPE = 'BEFORE_BINDING'
                         AND srp.END_DATE = s.BINDING_END_DATE)
                     OR (
                         s.STUP_FREE_PERIOD_TYPE = 'AFTER_BINDING'
                         AND srp.START_DATE = s.BINDING_END_DATE) )
                 AND srp.type = 'SAVED_FREE_DAYS_USE')
         JOIN
             STARTUP_CAMPAIGN sc
         ON
             sc.id = s.STARTUP_FREE_PERIOD_ID
         LEFT JOIN
             CAMPAIGN_CODES cc
         ON
             cc.id = s.CAMPAIGN_CODE_ID
         JOIN
             PRODUCTS pr
         ON
             pr.center = s.SUBSCRIPTIONTYPE_CENTER
             AND pr.id = s.SUBSCRIPTIONTYPE_ID
         JOIN
             centers c
         ON
             c.id = s.center
         JOIN
             PERSONS p
         ON
             p.center = s.OWNER_CENTER
             AND p.id = s.OWNER_ID
         WHERE
             s.CREATION_TIME BETWEEN $$from_time$$ AND ($$to_time$$ + 24*3600*1000)
             AND s.center IN ($$scope$$)
             AND s.BINDING_END_DATE < add_months(to_date(getcentertime(s.center),'YYYY-MM-DD'),1) -- for used free days coming from a startup campaign
         UNION ALL
         SELECT
             c.name                           AS "Club",
             s.OWNER_CENTER||'p'|| s.OWNER_ID AS "ID Member",
             p.FULLNAME                       AS "Full Name",
             pr.name                          AS "Subs",
             'Startup Campaign'               AS "Type",
             cc.code                          AS "Campaign Code",
             CASE
                 WHEN s.STUP_FREE_PERIOD_TYPE = 'AFTER_BINDING'
                 THEN TO_CHAR(s.BINDING_END_DATE+1,'yyyy-MM-dd')
                 WHEN s.STUP_FREE_PERIOD_TYPE = 'BEFORE_BINDING'
                     AND s.STUP_FREE_PERIOD_UNIT = 1
                 THEN TO_CHAR(s.BINDING_END_DATE +1 - s.STUP_FREE_PERIOD_VALUE,'yyyy-MM-dd')
                 WHEN s.STUP_FREE_PERIOD_TYPE = 'BEFORE_BINDING'
                     AND s.STUP_FREE_PERIOD_UNIT = 2
                 THEN TO_CHAR(add_months(s.BINDING_END_DATE+1,-1*s.STUP_FREE_PERIOD_VALUE ),'yyyy-MM-dd')
             END AS "From Date",
             CASE
                 WHEN s.STUP_FREE_PERIOD_TYPE = 'AFTER_BINDING'
                     AND s.STUP_FREE_PERIOD_UNIT = 1
                 THEN TO_CHAR(s.BINDING_END_DATE + s.STUP_FREE_PERIOD_VALUE,'yyyy-MM-dd')
                 WHEN s.STUP_FREE_PERIOD_TYPE = 'AFTER_BINDING'
                     AND s.STUP_FREE_PERIOD_UNIT = 2
                 THEN TO_CHAR(add_months(s.BINDING_END_DATE,s.STUP_FREE_PERIOD_VALUE ),'yyyy-MM-dd')
                 WHEN s.STUP_FREE_PERIOD_TYPE = 'BEFORE_BINDING'
                 THEN TO_CHAR(s.BINDING_END_DATE,'yyyy-MM-dd')
             END                                   AS "To Date",
             longtodateC(s.CREATION_TIME,s.center) AS "Assigned Date",
             s.START_DATE                          AS "Subscription Start Date",
             s.BINDING_END_DATE                    AS "Binding End Date"
         FROM
             SUBSCRIPTIONS s
         JOIN
             STARTUP_CAMPAIGN sc
         ON
             sc.id = s.STARTUP_FREE_PERIOD_ID
         LEFT JOIN
             CAMPAIGN_CODES cc
         ON
             cc.id = s.CAMPAIGN_CODE_ID
         JOIN
             PRODUCTS pr
         ON
             pr.center = s.SUBSCRIPTIONTYPE_CENTER
             AND pr.id = s.SUBSCRIPTIONTYPE_ID
         JOIN
             centers c
         ON
             c.id = s.center
         JOIN
             PERSONS p
         ON
             p.center = s.OWNER_CENTER
             AND p.id = s.OWNER_ID
         WHERE
             s.STUP_FREE_PERIOD_UNIT IS NOT NULL
             AND s.BINDING_END_DATE >= add_months(to_timestamp(getcentertime(s.center),'YYYY-MM-DD HH24:MI:SS'),1) -- for free period days from campaign that are not used yet
             AND s.CREATION_TIME BETWEEN $$from_time$$ AND ($$to_time$$ + 24*3600*1000)
             AND s.center IN ($$scope$$)
         UNION ALL
         SELECT
             c.name                                AS "Club",
             s.OWNER_CENTER||'p'|| s.OWNER_ID      AS "ID Member",
             p.FULLNAME                            AS "Full Name",
             pr.name                               AS "Subs",
             'Startup Campaign'                    AS "Type",
             cc.code                               AS "Campaign Code",
             TO_CHAR(sp.FROM_DATE,'yyyy-MM-dd')    AS "From Date",
             TO_CHAR(sp.TO_DATE,'yyyy-MM-dd')      AS "To Date",
             longtodateC(s.CREATION_TIME,s.center) AS "Assigned Date",
             s.START_DATE                          AS "Subscription Start Date",
             s.BINDING_END_DATE                    AS "Binding End Date"
         FROM
             PRIVILEGE_USAGES pu
         JOIN
             PRIVILEGE_GRANTS pg
         ON
             pg.ID = pu.GRANT_ID
         LEFT JOIN
             CAMPAIGN_CODES cc
         ON
             cc.id = pu.CAMPAIGN_CODE_ID
         JOIN
             SUBSCRIPTION_PRICE sp -- All periods of PRICE = 0 created by a startup campaign
         ON
             sp.ID = pu.TARGET_ID
             AND sp.PRICE = 0
         JOIN
             SUBSCRIPTIONS s
         ON
             s.center = sp.SUBSCRIPTION_CENTER
             AND s.id = sp.SUBSCRIPTION_ID
         JOIN
             PRODUCTS pr
         ON
             pr.center = s.SUBSCRIPTIONTYPE_CENTER
             AND pr.id = s.SUBSCRIPTIONTYPE_ID
         JOIN
             centers c
         ON
             c.id = s.center
         JOIN
             PERSONS p
         ON
             p.center = s.OWNER_CENTER
             AND p.id = s.OWNER_ID
         WHERE
             pu.TARGET_SERVICE = 'SubscriptionPrice'
             AND pg.GRANTER_SERVICE = 'StartupCampaign'
             AND s.CREATION_TIME BETWEEN $$from_time$$ AND ($$to_time$$ + 24*3600*1000)
             AND s.center IN ($$scope$$)
             AND sp.TYPE != 'PRORATA'
         UNION ALL
         SELECT
             c.name                               AS "Club",
             s.OWNER_CENTER||'p'|| s.OWNER_ID     AS "ID Member",
             p.FULLNAME                           AS "Full Name",
             pr.name                              AS "Subs",
             'Manual'                             AS "Type",
             NULL                                 AS "Campaign Code",
             TO_CHAR(srp.START_DATE,'yyyy-MM-dd') AS "From Date",
             TO_CHAR( srp.END_DATE,'yyyy-MM-dd')  AS "To Date",
             longtodateC(srp.ENTRY_TIME,s.center) AS "Assigned Date",
             s.START_DATE                         AS "Subscription Start Date",
             s.BINDING_END_DATE                   AS "Binding End Date"
         FROM
             SUBSCRIPTIONS s
         JOIN
             SUBSCRIPTION_REDUCED_PERIOD srp -- all manually assigned free periods
         ON
             srp.SUBSCRIPTION_CENTER = s.center
             AND srp.SUBSCRIPTION_ID = s.id
             AND srp.type = 'FREE_ASSIGNMENT'
         JOIN
             PRODUCTS pr
         ON
             pr.center = s.SUBSCRIPTIONTYPE_CENTER
             AND pr.id = s.SUBSCRIPTIONTYPE_ID
         JOIN
             centers c
         ON
             c.id = s.center
         JOIN
             PERSONS p
         ON
             p.center = s.OWNER_CENTER
             AND p.id = s.OWNER_ID
         WHERE
             srp.ENTRY_TIME BETWEEN $$from_time$$ AND ($$to_time$$ + 24*3600*1000)
             AND s.center IN ($$scope$$)
             AND add_months(srp.START_DATE,1) + INTERVAL '-1' DAY <= srp.END_DATE
        ) t
