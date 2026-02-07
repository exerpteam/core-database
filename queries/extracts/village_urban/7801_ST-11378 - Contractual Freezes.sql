SELECT
    s.owner_center || 'p' || s.owner_id                           AS PersonId,
    s.center || 'ss' || s.id                                      AS SubscriptionId,
    s.start_date                                                  AS SUBSCRIPTION_STARTDATE,
    s.end_date                                                    AS SUBSCRIPTION_ENDDATE,
    sfp.TYPE                                                      AS SUBSCRIPTION_FREEZE_TYPE,
    sfp.start_date                                                AS FREEZE_START_DATE,
    sfp.end_date                                                  AS FREEZE_END_DATE,
    sfp.TEXT                                                      AS FREEZE_TEXT,
    utl_raw.cast_to_varchar2(dbms_lob.substr(je.BIG_TEXT,2000,1)) AS JOURNAL_NOTE
FROM
    subscriptions s
JOIN
    SUBSCRIPTION_FREEZE_PERIOD sfp
ON
    s.CENTER = sfp.SUBSCRIPTION_CENTER
AND s.ID = sfp.SUBSCRIPTION_ID
JOIN
    VU.JOURNALENTRIES je
ON
    s.OWNER_CENTER = je.PERSON_CENTER
AND s.owner_id = je.PERSON_ID
WHERE
    sfp.start_date BETWEEN to_date('12-03-2020','dd-mm-yyyy') AND to_date('30-06-2020','dd-mm-yyyy'
    )
AND sfp.end_date BETWEEN to_date('12-03-2020','dd-mm-yyyy') AND to_date('30-06-2020','dd-mm-yyyy')
AND sfp.STATE = 'ACTIVE'
AND sfp.TYPE = 'CONTRACTUAL'
AND je.name = 'CV19 F'