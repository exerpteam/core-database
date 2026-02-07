-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-6128
SELECT
        t1.MemberID AS "Member ID",
        t1.PCenter || 'p' || t1.PId AS "Person ID",
        t1.ExternalID AS "External ID",
        t1.First_name AS "First_name",
        t1.Last_name AS "Last_name",
        t1.Center AS "Center",
        t1.MembershipName AS "Membership1",
        t1.MembershipName2 AS "Membership2",
        t1.MembershipName3 AS "Membership3",
        t1.MembershipName4 AS "Membership4",
        t1.LastLogin AS "Log date", 
		t3.NewLastAttendance AS "Last_attendance",
        t3.AttendanceCenter AS "Last_attendance_Center",
        t2.NewLastCheckin AS "Last_checkin",
        t2.CheckinCenter AS "Last_checkin_Center"
       
FROM
(
        WITH
        v_main AS
        (
                SELECT
                        e.CENTER || 'emp' || e.ID AS MemberID,
                        p.CENTER as PCenter,
                        p.ID AS PId,
                        p.EXTERNAL_ID AS ExternalID,
                        p.FIRSTNAME AS First_name, 
                        p.LASTNAME AS Last_name,
                        c.NAME AS Center,
                        pr.NAME AS MembershipName,
                        e.LAST_LOGIN AS LastLogin
                         
                FROM
                        PERSONS p
                JOIN 
                        EMPLOYEES e ON p.CENTER = e.PERSONCENTER AND p.ID = e.PERSONID
                LEFT JOIN 
                        SUBSCRIPTIONS s ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID AND s.STATE IN (2,4,8)
                LEFT JOIN 
                        FW.SUBSCRIPTIONTYPES st ON s.SUBSCRIPTIONTYPE_CENTER = st.CENTER AND s.SUBSCRIPTIONTYPE_ID = st.ID
                LEFT JOIN
                        FW.PRODUCTS pr ON st.CENTER = pr.CENTER AND st.ID = pr.ID
                LEFT JOIN
                        CENTERS c ON p.CENTER = c.ID
                WHERE
                        p.PERSONTYPE = 2
                        AND e.BLOCKED = 0
                        AND
                        (
                                e.PASSWD_NEVER_EXPIRES = 0
                                OR
                                e.PASSWD_NEVER_EXPIRES = 1 AND 
                                                                (
                                                                e.PASSWD_EXPIRATION IS NULL
                                                                OR        
                                                                e.PASSWD_EXPIRATION > exerpsysdate()
                                                                )
                        )
        ),
        v_pivot AS
        (
                SELECT
                        v_main.*,
                        LEAD(MembershipName,1) OVER (PARTITION BY MemberID,PCenter,PId,ExternalID,First_name,Last_name,Center,LastLogin ORDER BY PCenter,PId) AS MembershipName2,
                        LEAD(MembershipName,2) OVER (PARTITION BY MemberID,PCenter,PId,ExternalID,First_name,Last_name,Center,LastLogin ORDER BY PCenter,PId) AS MembershipName3,
                        LEAD(MembershipName,3) OVER (PARTITION BY MemberID,PCenter,PId,ExternalID,First_name,Last_name,Center,LastLogin ORDER BY PCenter,PId) AS MembershipName4,
                        ROW_NUMBER() OVER (PARTITION BY MemberID,PCenter,PId,ExternalID,First_name,Last_name,Center,LastLogin ORDER BY PCenter,PId) AS ADDONSEQ
                FROM
                        v_main
        )
        
        SELECT
                v_pivot.MemberID,
                v_pivot.PCenter,
                v_pivot.PId,
                v_pivot.ExternalID,
                v_pivot.First_name,
                v_pivot.Last_name,
                v_pivot.Center,
                v_pivot.MembershipName,
                v_pivot.MembershipName2,
                v_pivot.MembershipName3,
                v_pivot.MembershipName4,
                v_pivot.LastLogin
                   
        FROM
                v_pivot
        WHERE
                ADDONSEQ=1
) t1
LEFT JOIN
(
        SELECT
                a2.PERSON_CENTER,
                a2.PERSON_ID,
                LONGTODATE(a2.START_TIME) AS NewLastAttendance,
                cen.NAME AS AttendanceCenter
        FROM
        (
                SELECT
                        p.CENTER,
                        p.ID,
                        MAX(a.START_TIME) AS LastAttendance
                FROM
                        PERSONS p
                LEFT JOIN        
                        FW.ATTENDS a ON p.CENTER = a.PERSON_CENTER AND p.ID = a.PERSON_ID
                WHERE
                        p.PERSONTYPE = 2
                GROUP BY 
                        p.CENTER,
                        p.ID
         ) s2
         JOIN FW.ATTENDS a2 ON s2.CENTER = a2.PERSON_CENTER AND s2.ID = a2.PERSON_ID AND s2.LastAttendance = a2.START_TIME
         JOIN CENTERS cen ON cen.ID = a2.CENTER
) t3 ON t1.PCenter = t3.PERSON_CENTER AND t1.PId = t3.PERSON_ID
LEFT JOIN
(
        SELECT
                c2.PERSON_CENTER,
                c2.PERSON_ID,
                LONGTODATE(c2.CHECKIN_TIME) AS NewLastCheckin,
                cen.NAME AS CheckinCenter
        FROM
        (
                SELECT
                        p.CENTER,
                        p.ID,
                        MAX(c.CHECKIN_TIME) AS LastCheckin
                FROM
                        PERSONS p
                LEFT JOIN        
                        FW.CHECKINS c ON p.CENTER = c.PERSON_CENTER AND p.ID = c.PERSON_ID
                WHERE
                        p.PERSONTYPE = 2
                GROUP BY 
                        p.CENTER,
                        p.ID
         ) s1
         JOIN FW.CHECKINS c2 ON s1.CENTER = c2.PERSON_CENTER AND s1.ID = c2.PERSON_ID AND s1.LastCheckin = c2.CHECKIN_TIME
         JOIN CENTERS cen ON cen.ID = c2.CHECKIN_CENTER
) t2
ON t1.PCenter = t2.PERSON_CENTER AND t1.PId = t2.PERSON_ID