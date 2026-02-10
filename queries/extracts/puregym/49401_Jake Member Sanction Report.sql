-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4787
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR(:StartDate, 'YYYY-MM-dd HH24:MI'), 'Europe/London')                   AS StartDateLong,
            (datetolongTZ(TO_CHAR(:EndDate, 'YYYY-MM-dd HH24:MI'), 'Europe/London')+ 86400 * 1000)-1 AS EndDateLong
        FROM
            dual
    )
    
SELECT
        cpParticipant.EXTERNAL_ID AS "External ID",
        part.PARTICIPANT_CENTER || 'p' || part.PARTICIPANT_ID AS "P#",
        p.CENTER || 'p' || p.ID AS "P# who booked",  
        (CASE 
                WHEN s.CENTER IS NOT NULL THEN s.CENTER || 'ss' || s.ID 
                ELSE NULL
        END) AS "ss#",
        pr.NAME AS "Subscription name",
        part.CENTER AS "Gym ID",
        b.NAME AS "Class name",
        to_char(longtodateC(part.CREATION_TIME, part.CENTER),'YYYY-MM-DD HH24:MI:SS') AS "Date&time class booked",
        to_char(longtodateC(part.START_TIME, part.CENTER),'YYYY-MM-DD HH24:MI:SS') AS "Date&time of class",
        to_char(longtodateC(part.CANCELATION_TIME, part.CENTER),'YYYY-MM-DD HH24:MI:SS') AS "Date&time class was cancelled",
        (CASE
                WHEN pu.MISUSE_STATE='PUNISHED' THEN pp.NAME
                ELSE NULL
        END) AS "Sanction",
        pu.MISUSE_STATE AS "State",
        participant.BIRTHDATE AS "Date of Birth",
        participant.SEX AS "Gender",
		(CASE a.ACTIVITY_TYPE
               WHEN 2 THEN 'Class'
               WHEN 3 THEN 'Resource booking'
               WHEN 4 THEN 'Staff booking'
               WHEN 5 THEN 'Meeting'
               WHEN 6 THEN 'Staff availability'
               ELSE 'Unknown'
        END) AS "Activity type",
        decode (participant.status, 0,'Lead', 1,'Active', 2,'Inactive', 3,'Temporary Inactive', 4,'Transfered', 
                5,'Duplicate', 6,'Prospect', 7,'Deleted',8, 'Anonymized', 9, 'Contact', 'Unknown') as "Participant Person status",
        --pg.GRANTER_SERVICE,
        --prg.NAME "Campaign from Privilege",
        --mpr.CACHED_PRODUCTNAME "ProductName from Privilege",
        (CASE
                WHEN part.ON_WAITING_LIST=1 THEN 'YES'
                ELSE 'NO'
        END) "Waiting List",
        part.CANCELATION_REASON
FROM
        PARTICIPATIONS part 
CROSS JOIN
            params
JOIN
        PERSONS p ON p.CENTER = part.OWNER_CENTER AND p.ID = part.OWNER_ID 
JOIN
        PERSONS participant ON participant.CENTER = part.PARTICIPANT_CENTER AND participant.ID = part.PARTICIPANT_ID    
JOIN 
        PERSONS cpParticipant ON cpParticipant.CENTER = participant.TRANSFERS_CURRENT_PRS_CENTER AND cpParticipant.ID = participant.TRANSFERS_CURRENT_PRS_ID
JOIN
        PRIVILEGE_USAGES pu ON pu.target_service = 'Participation' AND pu.target_center = part.center AND pu.target_id = part.id
JOIN
        PRIVILEGE_GRANTS pg ON pg.ID = pu.GRANT_ID
JOIN 
        BOOKINGS b ON b.CENTER = part.BOOKING_CENTER AND b.ID = part.BOOKING_ID 
JOIN 
        ACTIVITY a ON a.ID = b.ACTIVITY
JOIN    
        PRIVILEGE_PUNISHMENTS pp ON pp.ID = pg.PUNISHMENT
--LEFT JOIN
--        MASTERPRODUCTREGISTER mpr ON mpr.ID = pg.GRANTER_ID AND pg.GRANTER_SERVICE = 'GlobalSubscription'
--LEFT JOIN
 --       PRIVILEGE_RECEIVER_GROUPS prg ON prg.ID = pg.GRANTER_ID AND pg.GRANTER_SERVICE = 'ReceiverGroup'
LEFT JOIN
        SUBSCRIPTIONS s ON part.PARTICIPANT_CENTER = s.OWNER_CENTER AND part.PARTICIPANT_ID = s.OWNER_ID 
                AND s.START_DATE <= longtodateC(part.START_TIME, part.CENTER)
                AND (s.END_DATE IS NULL OR s.END_DATE+1 >= longtodateC(part.START_TIME, part.CENTER))
LEFT JOIN
        PRODUCTS pr ON pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND pr.ID = s.SUBSCRIPTIONTYPE_ID                
WHERE
        part.CANCELATION_TIME IS NOT NULL
        AND 
        (
                part.CANCELATION_REASON = 'NO_SHOW'
                OR
                part.CANCELATION_TIME >= part.START_TIME - (1000*60*60*6)
        )
        AND part.START_TIME >= params.StartDateLong
        AND part.START_TIME <= params.EndDateLong
        AND part.CENTER IN (:Scope)