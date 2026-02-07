SELECT
    p.CENTER||'p'||p.ID                                  MEMBER_ID,
    p.FULLNAME                                           MEMBER_NAME,
    c.SHORTNAME                                          HOME_CENTER,
    s.CENTER || 'ss' || s.ID                             SUBSCRIPTION,
    pr.NAME                                              SUBSCRIPTION_NAME,
    DECODE(ST_TYPE,0,'Cash',1,'EFT',2,'Clipcard',3,'Course') as SUBSCRIPTION_CATEGORY,
    to_char(s.START_DATE,'YYYY-MM-DD')                   START_DATE,
    longtodateC(scStop.STOP_DATETIME, s.center) AS       TERMINATION_DATE,
    to_char(s.END_DATE,'YYYY-MM-DD')                     SUBCRIPTION_END_DATE,
    scStop.CENTER||'p'||scStop.ID                        CANCELLATION_EMPLOYEE,
    staff.FULLNAME                                	 CANCELLATION_EMPLOYEE_NAME,
    cc.SHORTNAME                            		 CANCELLATION_EMPLOYEE_HOME
FROM
    SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    p.center = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN 
    CENTERS c
ON
    c.ID = p.CENTER
JOIN
    PRODUCTS pr
ON
    s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = pr.ID
LEFT JOIN -- Workaround to avoid bug including duplicate scStop entries
    (
        SELECT
            OLD_SUBSCRIPTION_CENTER,
            OLD_SUBSCRIPTION_ID,
            STOP_DATETIME,
            STOP_CANCEL_DATETIME,
            ID,CENTER,
            STOP_PERSON_ID
        FROM
            (
                SELECT
                    scStop.OLD_SUBSCRIPTION_CENTER,
                    scStop.OLD_SUBSCRIPTION_ID,
                    scStop.CHANGE_TIME AS STOP_DATETIME,
                    scStop.CANCEL_TIME AS STOP_CANCEL_DATETIME,
                    scStopstaff.CENTER,
                    scStopstaff.ID,
                    CASE
                        WHEN (scStopstaff.CENTER != scStopstaff.TRANSFERS_CURRENT_PRS_CENTER
                                OR scStopstaff.id != scStopstaff.TRANSFERS_CURRENT_PRS_ID )
                        THEN
                            (
                                SELECT
                                    EXTERNAL_ID
                                FROM
                                    PERSONS
                                WHERE
                                    CENTER = scStopstaff.TRANSFERS_CURRENT_PRS_CENTER
                                    AND ID = scStopstaff.TRANSFERS_CURRENT_PRS_ID)
                        ELSE scStopstaff.EXTERNAL_ID
                    END                                                                                                                    AS STOP_PERSON_ID,
                    rank() over (partition BY scStop.OLD_SUBSCRIPTION_CENTER, scStop.OLD_SUBSCRIPTION_ID ORDER BY scStop.CHANGE_TIME DESC) AS rnk
                FROM
                    SUBSCRIPTION_CHANGE scStop
                LEFT JOIN
                    employees escStopEmp
                ON
                    escStopEmp.center = scStop.EMPLOYEE_CENTER
                    AND escStopEmp.id = scStop.EMPLOYEE_ID
                LEFT JOIN
                    PERSONS scStopstaff
                ON
                    escStopEmp.PERSONCENTER = scStopstaff.center
                    AND escStopEmp.PERSONID =scStopstaff.id
                WHERE
                    scStop.TYPE = 'END_DATE' ) x
        WHERE
            rnk = 1) scStop
ON
    scStop.OLD_SUBSCRIPTION_CENTER = s.CENTER
    AND scStop.OLD_SUBSCRIPTION_ID = s.ID
LEFT JOIN
    centers cc
ON
    cc.ID = scStop.Center
LEFT JOIN
    persons staff
ON
    staff.CENTER = scStop.Center
    AND staff.ID = scStop.ID 
WHERE
    s.center in (:Scope)
    AND s.sub_state not in (3,4,5,6,10)
    AND scStop.STOP_DATETIME >= :From_Date
    AND scStop.STOP_DATETIME < :Until_Date + 24*60*60*1000
