-- The extract is extracted from Exerp on 2026-02-08
--  
 -- Once a to-do is marked as complete, all comments pertaining to that to-do have a status of complete. Therefore, the final COMMENT_TIME is taken as the TO-DO completed time.
 SELECT
     t.PERSONCENTER || 'p' || t.PERSONID AS MEMBER_ID,
     p.FIRSTNAME || ' ' || p.LASTNAME    AS NAME,
     c.NAME                              AS CENTER_NAME,
     c.ID                                AS CENTER_ID,
     --    t.TODO_GROUP_ID,
     longtodatec(t.CREATION_TIME, t.CENTER)     AS DATE_LOGGED,
     longtodatec(t.DEADLINE,t.CENTER)           AS DEADLINE,
     t.CREATORCENTER || 'p' || t.CREATORID       AS CREATED_BY,
     t.ASSIGNEDTOCENTER || 'p' || t.ASSIGNEDTOID AS ASSIGNED_TO,
     t.SUBJECT,
     (CASE t.TODO_GROUP_ID
        WHEN 1 THEN '10 - Request to Stop Membership'
        WHEN 2 THEN '11 - Request to Freeze'
        WHEN 3 THEN '06 - Payment Query'
        WHEN 4 THEN '05 - Debt Query'
        WHEN 5 THEN '01 - Upgrade Membership'
        WHEN 6 THEN '12 - Downgrade Membership'
        WHEN 7 THEN '03 - Renewal Query'
        WHEN 8 THEN '07 - Request for Refund'
        WHEN 9 THEN '08 - Bank Detail Query'
        WHEN 201 THEN '99 - Complimentary'
        WHEN 202 THEN '99 - Staff'
        WHEN 401 THEN '14 - Transfer to another club'
        WHEN 601 THEN '15 - Online Access Query'
        WHEN 602 THEN '09 - Complaint'
        WHEN 801 THEN '13 - Pending'
        WHEN 1001 THEN '16 - Retention'
        WHEN 1002 THEN '17 - Stop Dispute'
        WHEN 1003 THEN '04 - Cancel Stop'
        WHEN 1004 THEN '02 - Request to Unfreeze'
        WHEN 1201 THEN '18 - Call Back'
        WHEN 1202 THEN '19 - Correspondence'
        WHEN 1401 THEN '20 - Facebook Feedback'
        WHEN 1402 THEN '20 - Facebook Feedback'
        WHEN 1601 THEN '21 - Free Period  [Non Comp]'
        WHEN 1801 THEN 'VW - Change to Discounted Gym Rate'
        WHEN 1802 THEN 'VW - Request to Stop'
        WHEN 1803 THEN 'VW - Subscription Change'
        WHEN 1804 THEN 'VW - Request for Refund'
        WHEN 1805 THEN 'VW - Payment Query'
     END) AS TODO_GROUP,
     (CASE t.STATUS
        WHEN 1 THEN 'Not started'
        WHEN 2 THEN 'In progress'
        WHEN 3 THEN 'Completed'
        WHEN 4 THEN 'Awaiting External Input'
        WHEN 5 THEN 'Rejected'
        WHEN 6 THEN 'Deleted'
     END) AS TODO_STATUS,
     longtodatec(TC.COMMENT_TIME, t.CENTER) AS COMMENT_DATE,
     tc.COMENT AS TODO_COMMENT
 FROM
     TODOS t
 JOIN
     TODOCOMMENTS tc
 ON
     t.CENTER = tc.CENTER
 AND t.ID = tc.ID
 JOIN
     PERSONS p
 ON
     t.PERSONCENTER = p.CENTER
 AND t.PERSONID = p.ID
 JOIN
     CENTERS c
 ON
     t.PERSONCENTER = c.ID
 WHERE
     t.SUBJECT LIKE '% '
