SELECT
    p.center ||'p'||p.id AS memberid,
    p.FULLNAME,
    longtodate(s.CREATION_TIME) AS SUBSCRIPTION_CREATIONTIME,
    s.START_DATE AS SUBSCRIPTION_STARTDATE,
    s.state                                                                   AS subscription_state,
    DECODE (s.state, 2,'Active', 3,'Ended', 4,'Frozen', 7,'Window', 8,'Created','Unknown') AS
    "Subscription State",
    s.SUB_STATE,
    DECODE (SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,
    'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED',10,'CHANGED', 'UNKNOWN')
                              AS "SUB STATE " ,
    emp.CENTER||'emp'||emp.id AS emp,
    p2.FULLNAME               AS employee,
    C.COUNTRY
FROM
    persons p
JOIN
    VA.SUBSCRIPTIONS s
ON
    p.CENTER = s.OWNER_CENTER
AND p.id = s.OWNER_ID
JOIN
    VA.SUBSCRIPTION_SALES ss
ON
    ss.SUBSCRIPTION_CENTER = s.CENTER
AND ss.SUBSCRIPTION_ID = s.id
JOIN
    VA.JOURNALENTRIES je
ON
    je.PERSON_CENTER = p.CENTER
AND je.PERSON_ID = p.id
AND je.JETYPE = 1
AND je.REF_CENTER = s.CENTER
AND je.REF_ID = s.id
LEFT JOIN
    VA.JOURNALENTRY_SIGNATURES jes
ON
    jes.JOURNALENTRY_ID = je.ID
LEFT JOIN
    VA.CENTERS c
ON
    p.CENTER = c.id
LEFT JOIN
    VA.EMPLOYEES emp
ON
    s.CREATOR_CENTER = emp.CENTER
AND s.CREATOR_ID = emp.id
LEFT JOIN
    persons p2
ON
    emp.PERSONCENTER = p2.CENTER
AND emp.PERSONID = p2.id


WHERE
    1=1
    --and    TRUNC(longtodate(s.CREATION_TIME) ) < s.START_DATE
AND jes.id IS NULL
ORDER BY
    c.country,
    p2.FULLNAME,
    SUBSCRIPTION_CREATIONTIME