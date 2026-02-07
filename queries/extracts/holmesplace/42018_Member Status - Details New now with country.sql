WITH
    PARAMS AS
    (
        SELECT
            CAST (datetolong(TO_CHAR(DATE_TRUNC('day', d1.currentdate), 'YYYY-MM-DD HH24:MI')) -1 AS BIGINT) AS STARTTIME ,
            CAST (datetolong(TO_CHAR(DATE_TRUNC('day', d1.currentdate +1), 'YYYY-MM-DD HH24:MI')) -1 AS BIGINT) AS ENDTIME,
            CAST (datetolong(TO_CHAR(DATE_TRUNC('day', d1.currentdate +2), 'YYYY-MM-DD HH24:MI')) -1 AS BIGINT) AS STATUSFIELDTIME,
            CAST (datetolong(TO_CHAR(DATE_TRUNC('day', d1.currentdate +1), 'YYYY-MM-DD HH24:MI')) -1 AS BIGINT) AS STATUSFIELDTIMEEXTRA,
            CURRENTDATE,
            'DEBTOR' AS SELECTED_STATUS
        FROM
            (
                SELECT
                    CAST(to_date(:for_date,'YYYY-MM-DD') AS DATE) AS currentdate
            ) d1
    ) 
SELECT
    P.CENTER,
    P.CENTER ||'p'|| P.ID as "Member",
    STATUSES.*,
    CASE
        WHEN (P.BIRTHDATE IS NOT NULL
                AND extract(YEAR FROM age(PARAMS.currentdate, P.BIRTHDATE))  < 16)
        THEN 'true'
        ELSE NULL
    END AS KIDS,
    CASE
        WHEN COALESCE(STATUSES.Debtor,'false') = 'true'
        THEN 'DEBTOR'
        WHEN COALESCE(STATUSES.LateStart,'false') = 'true'
        THEN 'LATESTART'
        WHEN COALESCE(STATUSES.Frozen,'false') = 'true'
        THEN 'FROZEN'
        WHEN COALESCE(STATUSES.Extra,'false') = 'true'
        THEN 'EXTRA'
        WHEN (P.BIRTHDATE IS NOT NULL
                AND extract(YEAR FROM age(PARAMS.currentdate, P.BIRTHDATE)) < 16)
        THEN 'KIDS'
        ELSE 'LIVE'
    END AS STATUS,
cen.country AS COUNTRY

FROM
    (
        SELECT DISTINCT --LC
            SU.OWNER_CENTER ,
            SU.OWNER_ID
        FROM
            PARAMS,
            SUBSCRIPTIONS SU
        JOIN
            SUBSCRIPTIONTYPES ST
        ON
            (
                SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID )
        WHERE
            SU.CENTER IN (:scope)
			
            -- Only EFT AND ST.ST_TYPE IN (1)
            -- Add your SubscriptionProduct filters here
            -- COMPs: Exclude FREE memberships product group
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppg
                WHERE
                    ppg.product_center = ST.CENTER
                    AND ppg.product_id = ST.ID
                    AND ppg.PRODUCT_GROUP_ID = 1201 )
            -- Exclude add-on memberships
            AND st.IS_ADDON_SUBSCRIPTION = 0
           
            AND EXISTS
            (
                -- Has at least one creatd,active,temp_inactive subscription at the end of day
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG SCL
                WHERE
                    SCL.CENTER = SU.CENTER
                    AND SCL.ID = SU.ID
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                    AND (
                        SCL.BOOK_END_TIME IS NULL
                        --                        OR  SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME --??
                        --                    OR  (SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME and SCL.BOOK_START_TIME  < SCL.BOOK_END_TIME) --??
                        OR SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
                    AND (
                        SCL.ENTRY_END_TIME IS NULL
                        OR SCL.ENTRY_END_TIME >= PARAMS.ENDTIME)
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.STATEID IN ( 2, 4,8)
                    -- Time safety. We need to exclude subscriptions started in the past so they do
                    -- not get into the incoming balance because they will not be in the outgoing
                    -- balance
                    -- of the previous day
                    AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME )
            AND NOT EXISTS
            (
                -- Not person type staff at end of day
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG SCL
                WHERE
                    SCL.CENTER = SU.OWNER_CENTER
                    AND SCL.ID = SU.OWNER_ID
                    AND SCL.ENTRY_TYPE = 3
                    AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                    AND (
                        SCL.BOOK_END_TIME IS NULL
                        --OR  SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                        OR SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
                    AND SCL.ENTRY_TYPE = 3
                    -- Not staff
                    AND SCL.STATEID = 2
                    -- Time safety
                    AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME ) ) MEMBERS
CROSS JOIN
    PARAMS
JOIN
    PERSONS P
ON
    P.CENTER = MEMBERS.OWNER_CENTER
    AND P.ID = MEMBERS.OWNER_ID

LEFT JOIN
	CENTERS CEN
ON 
	cen.ID = P.CENTER

LEFT JOIN
(

select
ranking.PERSON_CENTER,
ranking.PERSON_ID,
MAX(CASE ranking.CHANGE_ATTRIBUTE WHEN 'STATUS_DEBTOR' THEN COALESCE(ranking.new_value,'false') END)     AS Debtor,
MAX(CASE ranking.CHANGE_ATTRIBUTE WHEN 'STATUS_LATE_START' THEN COALESCE(ranking.new_value,'false') END)  AS LateStart,
MAX(CASE ranking.CHANGE_ATTRIBUTE WHEN 'STATUS_FROZEN' THEN COALESCE(ranking.new_value,'false') END)  AS Frozen,
MAX(CASE ranking.CHANGE_ATTRIBUTE WHEN 'STATUSEXTRA2' THEN COALESCE(ranking.new_value,'false') END)  AS Extra   


from

(

SELECT
          rank() over(partition by pcl1.PERSON_ID, pcl1.PERSON_CENTER, pcl1.CHANGE_ATTRIBUTE  ORDER BY pcl1.ENTRY_TIME  DESC) as rnk,
            pcl1.PERSON_CENTER,
            pcl1.PERSON_ID,
            pcl1.CHANGE_ATTRIBUTE,
            pcl1.new_value as oldvalue,
            longtodate(pcl2.ENTRY_TIME),
            longtodate(pcl1.ENTRY_TIME),
            pcl1.new_value as new_value
            
          
        FROM
            PERSON_CHANGE_LOGS pcl1
        CROSS JOIN
            PARAMS
        LEFT JOIN
            PERSON_CHANGE_LOGS pcl2
        ON
            pcl2.PREVIOUS_ENTRY_ID = pcl1.id
        WHERE
            pcl1.CHANGE_ATTRIBUTE IN ('STATUS_DEBTOR',
                                      'STATUS_FROZEN',
                                      'STATUS_LATE_START',
                                      'STATUSEXTRA2')
           --AND pcl2.ENTRY_TIME <= PARAMS.STATUSFIELDTIME
           AND pcl1.ENTRY_TIME <= PARAMS.STATUSFIELDTIME
            AND (
                pcl2.id IS NULL
                OR pcl2.ENTRY_TIME > PARAMS.STATUSFIELDTIME)
           AND pcl1.PERSON_CENTER in (:scope) 
             ) ranking
where rnk = 1


 GROUP BY
            ranking.PERSON_CENTER,
            ranking.PERSON_ID
 )STATUSES
ON
    STATUSES.PERSON_CENTER = MEMBERS.OWNER_CENTER
    AND STATUSES.PERSON_ID = MEMBERS.OWNER_ID     

WHERE 
cen.country IN ('DE', 'AT', 'CH')          